import Flutter
import UIKit
import BabylAI

public class BabylaiFlutterPlugin: NSObject, FlutterPlugin {
    
    // MARK: - Properties
    private var channel: FlutterMethodChannel?
    private var registrar: FlutterPluginRegistrar?
    private var tokenCallback: (() async throws -> String)?
    private var messageCallback: ((String) -> Void)?
    private var errorCallback: ((BabylAIError) -> Void)?
    
    // MARK: - Plugin Registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "babylai_flutter", binaryMessenger: registrar.messenger())
        let instance = BabylaiFlutterPlugin()
        instance.channel = channel
        instance.registrar = registrar
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // MARK: - Method Channel Handler
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            handleGetPlatformVersion(result: result)
            
        case "initialize":
            handleInitialize(call: call, result: result)
            
        case "setTokenCallback":
            handleSetTokenCallback(result: result)
            
        case "launchChat":
            handleLaunchChat(call: call, result: result)
            
        case "launchActiveChat":
            handleLaunchActiveChat(call: call, result: result)
            
        case "updateTheme":
            handleUpdateTheme(call: call, result: result)
            
        case "updateLocale":
            handleUpdateLocale(call: call, result: result)
            
        case "getLocale":
            handleGetLocale(result: result)
            
        case "reset":
            handleReset(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Method Implementations
    
    private func handleGetPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let environmentString = args["environment"] as? String,
              let localeString = args["locale"] as? String else {
            result(FlutterError(code: "MISSING_PARAMS", message: "Missing required parameters", details: nil))
            return
        }
        
        // Parse environment and enableLogging
        let enableLogging = args["enableLogging"] as? Bool ?? (environmentString == "development")
        let environment: EnvironmentConfig
        if environmentString == "production" {
            environment = .production(enableLogging: enableLogging)
        } else {
            environment = .development(enableLogging: enableLogging)
        }
        
        // Parse locale
        let locale: BabylAILocale
        if localeString == "arabic" {
            locale = .arabic
        } else {
            locale = .english
        }
        
        // Parse optional userInfo
        let userInfo = args["userInfo"] as? [String: Any]
        // Parse optional theme config
        var themeConfigArg: ThemeConfig? = nil
        if let cfg = args["themeConfig"] as? [String: Any] {
            let primary = cfg["primaryColorHex"] as? String
            let secondary = cfg["secondaryColorHex"] as? String
            let primaryDark = cfg["primaryColorDarkHex"] as? String
            let secondaryDark = cfg["secondaryColorDarkHex"] as? String
            let headerLogoName = cfg["headerLogo"] as? String
            let logoSymbolName = cfg["logoSymbol"] as? String
            
            // Helper function to load image from iOS Assets or Flutter assets
            func loadImage(named name: String?) -> UIImage? {
                guard let imageName = name else { return nil }
                
                // First try to load from iOS app bundle (Assets.xcassets)
                if let image = UIImage(named: imageName) {
                    return image
                }
                
                // If not found, try to load from Flutter assets
                if let registrar = self.registrar {
                    let key = registrar.lookupKey(forAsset: imageName)
                    if let path = Bundle.main.path(forResource: key, ofType: nil),
                       let image = UIImage(contentsOfFile: path) {
                        return image
                    }
                }
                
                return nil
            }
            
            let headerLogo = loadImage(named: headerLogoName)
            let logoSymbol = loadImage(named: logoSymbolName)
            
            themeConfigArg = ThemeConfig(
                primaryColorHex: primary,
                secondaryColorHex: secondary,
                primaryColorDarkHex: primaryDark,
                secondaryColorDarkHex: secondaryDark,
                headerLogo: headerLogo,
                logoSymbol: logoSymbol
            )
        }
        
        // Setup message callback (must call Flutter on main thread)
        self.messageCallback = { [weak self] message in
            DispatchQueue.main.async {
                self?.channel?.invokeMethod("onMessageReceived", arguments: ["message": message])
            }
        }
        
        // Setup error callback (must call Flutter on main thread)
        self.errorCallback = { [weak self] error in
            DispatchQueue.main.async {
                self?.channel?.invokeMethod("onError", arguments: [
                    "code": error.errorCode,
                    "message": error.errorDescription ?? "",
                    "details": error.recoverySuggestion ?? ""
                ])
            }
        }
        
        // Initialize BabylAI SDK
        BabylAISDK.shared.initialize(
            with: environment,
            locale: locale,
            userInfo: userInfo,
            themeConfig: themeConfigArg,
            onMessageReceived: self.messageCallback,
            onErrorReceived: self.errorCallback
        )
        
        result(nil)
    }
    
    private func handleSetTokenCallback(result: @escaping FlutterResult) {
        // Set up token callback that will call back to Flutter
        BabylAISDK.shared.setTokenCallback { [weak self] in
            guard let self = self else {
                throw BabylAIError.unknownError("Plugin instance deallocated")
            }
            
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.main.async { [weak self] in
                    self?.channel?.invokeMethod("getToken", arguments: nil) { response in
                        if response is FlutterError {
                            continuation.resume(throwing: BabylAIError.authenticationFailed)
                        } else if let token = response as? String {
                            continuation.resume(returning: token)
                        } else {
                            continuation.resume(throwing: BabylAIError.invalidToken)
                        }
                    }
                }
            }
        }
        
        result(nil)
    }
    
    private func handleLaunchChat(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let screenId = args["screenId"] as? String,
              let themeString = args["theme"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing screenId or theme", details: nil))
            return
        }
        
        let theme: BabylAITheme = themeString == "dark" ? .dark : .light
        
        DispatchQueue.main.async {
            BabylAISDK.shared.present(theme: theme, screenId: screenId)
            result(nil)
        }
    }
    
    private func handleLaunchActiveChat(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let screenId = args["screenId"] as? String,
              let themeString = args["theme"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing screenId or theme", details: nil))
            return
        }
        
        let theme: BabylAITheme = themeString == "dark" ? .dark : .light
        
        DispatchQueue.main.async {
            BabylAISDK.shared.presentActiveChat(theme: theme, screenId: screenId)
            result(nil)
        }
    }
    
    private func handleUpdateTheme(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let themeString = args["theme"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing theme parameter", details: nil))
            return
        }
        
        // Note: The native SDK doesn't have a direct updateTheme method
        // Theme is passed when presenting. This is a no-op for now.
        result(nil)
    }
    
    private func handleUpdateLocale(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let localeString = args["locale"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing locale parameter", details: nil))
            return
        }
        
        let locale: BabylAILocale = localeString == "arabic" ? .arabic : .english
        BabylAISDK.shared.setLocale(locale)
        result(nil)
    }
    
    private func handleGetLocale(result: @escaping FlutterResult) {
        let locale = BabylAISDK.shared.getLocale()
        let localeString = locale == .arabic ? "arabic" : "english"
        result(localeString)
    }
    
    private func handleReset(result: @escaping FlutterResult) {
        Task { @MainActor in
            await BabylAISDK.shared.reset()
            result(nil)
        }
    }
}
