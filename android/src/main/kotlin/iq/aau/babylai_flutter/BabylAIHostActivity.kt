package iq.aau.babylai_flutter

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import io.flutter.plugin.common.MethodChannel
import iq.aau.babylai.android.babylaisdk.BabylAI
import iq.aau.babylai.android.babylaisdk.BabylAITheme
import iq.aau.babylai.android.babylaisdk.core.errors.BabylAIError

class BabylAIHostActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val screenId = intent.getStringExtra(EXTRA_SCREEN_ID) ?: ""
        val isDirect = intent.getBooleanExtra(EXTRA_IS_DIRECT, false)
        val theme = if (intent.getStringExtra(EXTRA_THEME) == "dark") BabylAITheme.DARK else BabylAITheme.LIGHT

        // Create error handler that reports back to Flutter via method channel
        val errorHandler: (BabylAIError) -> Unit = { error ->
            // Get method channel from plugin instance and report error back to Flutter
            val methodChannel = BabylaiFlutterPlugin.getMethodChannel()
            if (methodChannel != null) {
                Handler(Looper.getMainLooper()).post {
                    methodChannel.invokeMethod("onError", mapOf(
                        "code" to error.javaClass.simpleName,
                        "message" to error.userFriendlyMessage,
                        "details" to error.recoverySuggestion
                    ))
                }
            }
        }

        setContent {
            if (isDirect) {
                BabylAI.shared.presentActiveChat(
                    theme = theme,
                    screenId = screenId,
                    onErrorReceived = errorHandler,
                    onDismiss = { finish() }
                )
            } else {
                BabylAI.shared.viewer(
                    theme = theme,
                    isDirect = false,
                    screenId = screenId,
                    onErrorReceived = errorHandler,
                    onDismiss = { finish() }
                )
            }
        }
    }

    companion object {
        const val EXTRA_SCREEN_ID = "screen_id"
        const val EXTRA_IS_DIRECT = "is_direct"
        const val EXTRA_THEME = "theme"
    }
}


