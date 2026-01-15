package iq.aau.babylai_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Intent
import android.app.Activity
import iq.aau.babylai.android.babylaisdk.BabylAI
import iq.aau.babylai.android.babylaisdk.core.enums.BabylAILocale
import iq.aau.babylai.android.babylaisdk.config.EnvironmentConfig
import iq.aau.babylai.android.babylaisdk.config.ThemeConfig
import iq.aau.babylai.android.babylaisdk.core.errors.BabylAIError
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import android.os.Handler
import android.os.Looper

/** BabylaiFlutterPlugin */
class BabylaiFlutterPlugin :
    FlutterPlugin,
    ActivityAware,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var tokenCallback: ((suspend () -> String))? = null

    companion object {
        @Volatile
        private var instance: BabylaiFlutterPlugin? = null
        
        fun getInstance(): BabylaiFlutterPlugin? = instance
        
        fun getMethodChannel(): MethodChannel? = instance?.channel
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "babylai_flutter")
        channel.setMethodCallHandler(this)
        instance = this
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "initialize" -> handleInitialize(call, result)
            "setTokenCallback" -> handleSetTokenCallback(result)
            "launchChat" -> handleLaunch(call, result, isDirect = false)
            "launchActiveChat" -> handleLaunch(call, result, isDirect = true)
            "updateTheme" -> handleUpdateTheme(call, result)
            "updateLocale" -> handleUpdateLocale(call, result)
            "getLocale" -> handleGetLocale(result)
            "reset" -> { BabylAI.shared.reset(); result.success(null) }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        instance = null
    }

    // ActivityAware
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() { activity = null }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: run {
            result.error("INVALID_ARGUMENTS", "Invalid args", null); return
        }
        val enableLogging = args["enableLogging"] as? Boolean ?: (args["environment"] == "development")
        val env = when (args["environment"]) {
            "production" -> EnvironmentConfig.production(enableLogging = enableLogging)
            else -> EnvironmentConfig.development(enableLogging = enableLogging)
        }
        val locale = when (args["locale"]) {
            "arabic" -> BabylAILocale.ARABIC
            else -> BabylAILocale.ENGLISH
        }
        val userInfo = (args["userInfo"] as? Map<*, *>)?.mapNotNull {
            val k = it.key as? String ?: return@mapNotNull null
            k to it.value as Any
        }?.toMap() ?: emptyMap()

        val themeMap = args["themeConfig"] as? Map<*, *>
        val themeConfig = themeMap?.let {
            val headerLogoName = it["headerLogo"] as? String
            val logoSymbolName = it["logoSymbol"] as? String
            var headerLogoResId: Int? = null
            var logoSymbolResId: Int? = null
            
            val ctx = activity ?: run {
                result.error("NO_ACTIVITY", "Activity not available for resource lookup", null); return@let null
            }
            
            // Helper function to find drawable resource by name
            fun findDrawableResource(name: String?): Int? {
                if (name == null) return null
                val resId = ctx.resources.getIdentifier(name, "drawable", ctx.packageName)
                if (resId == 0) {
                    android.util.Log.w("BabylaiFlutter", "Resource '$name' not found in drawable resources. " +
                        "Please add it to android/app/src/main/res/drawable/")
                    return null
                }
                return resId
            }
            
            headerLogoResId = findDrawableResource(headerLogoName)
            logoSymbolResId = findDrawableResource(logoSymbolName)

            ThemeConfig(
                primaryColorHex = it["primaryColorHex"] as? String,
                secondaryColorHex = it["secondaryColorHex"] as? String,
                primaryColorDarkHex = it["primaryColorDarkHex"] as? String,
                secondaryColorDarkHex = it["secondaryColorDarkHex"] as? String,
                headerLogoRes = headerLogoResId,
                logoSymbolRes = logoSymbolResId
            )
        }

        val ctx = activity ?: run {
            result.error("NO_ACTIVITY", "Activity not available", null); return
        }

        BabylAI.shared.initialize(
            context = ctx.applicationContext,
            config = env,
            locale = locale,
            userInfo = userInfo,
            themeConfig = themeConfig,
            onErrorReceived = { err ->
                channel.invokeMethod("onError", mapOf(
                    "code" to (err.javaClass.simpleName),
                    "message" to (err.toString()),
                    "details" to ""
                ))
            }
        )
        result.success(null)
    }

    private fun handleSetTokenCallback(result: Result) {
        BabylAI.shared.setTokenCallback {
            suspendCancellableCoroutine { cont ->
                Handler(Looper.getMainLooper()).post {
                    channel.invokeMethod("getToken", null, object : Result {
                        override fun success(result: Any?) {
                            val token = result as? String ?: ""
                            cont.resume(token)
                        }
                        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            cont.resume("")
                        }
                        override fun notImplemented() {
                            cont.resume("")
                        }
                    })
                }
            }
        }
        result.success(null)
    }

    private fun handleLaunch(call: MethodCall, result: Result, isDirect: Boolean) {
        val args = call.arguments as? Map<*, *> ?: run { result.error("INVALID_ARGUMENTS", "Invalid args", null); return }
        val screenId = args["screenId"] as? String ?: run { result.error("MISSING", "screenId required", null); return }
        val themeStr = args["theme"] as? String
        val theme = if (themeStr == "dark") "dark" else "light"
        val act = activity ?: run { result.error("NO_ACTIVITY", "Activity not available", null); return }
        val intent = Intent(act, BabylAIHostActivity::class.java).apply {
            putExtra(BabylAIHostActivity.EXTRA_SCREEN_ID, screenId)
            putExtra(BabylAIHostActivity.EXTRA_IS_DIRECT, isDirect)
            putExtra(BabylAIHostActivity.EXTRA_THEME, theme)
        }
        act.startActivity(intent)
        result.success(null)
    }

    private fun handleUpdateTheme(call: MethodCall, result: Result) {
        // The native SDK doesn't have a direct updateTheme method.
        // Theme is passed when presenting, so this is a no-op for now.
        result.success(null)
    }

    private fun handleUpdateLocale(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *> ?: run { result.error("INVALID_ARGUMENTS", "Invalid args", null); return }
        val locale = when (args["locale"]) {
            "arabic" -> BabylAILocale.ARABIC
            else -> BabylAILocale.ENGLISH
        }
        BabylAI.shared.setLocale(locale)
        result.success(null)
    }

    private fun handleGetLocale(result: Result) {
        val l = BabylAI.shared.getLocale()
        result.success(if (l == BabylAILocale.ARABIC) "arabic" else "english")
    }
}
