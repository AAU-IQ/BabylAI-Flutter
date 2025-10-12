import 'dart:async';
import 'package:flutter/services.dart';
import 'babylai_flutter_platform_interface.dart';
import 'models/theme_config.dart';
import 'models/environment_config.dart';

// Export models and enums for external use
export 'babylai_flutter_platform_interface.dart'
    show BabylAILocale, BabylAITheme;
export 'models/environment_config.dart'
    show BabylAIEnvironment, EnvironmentConfig;

/// Main BabylAI Flutter plugin class
class BabylaiFlutter {
  static const MethodChannel _channel = MethodChannel('babylai_flutter');

  static Future<String> Function()? _tokenCallback;
  static void Function(String message)? _messageCallback;
  static void Function(String code, String message, String details)?
  _errorCallback;

  static bool _isInitialized = false;
  static String? _currentScreenId;
  static BabylAITheme _currentTheme = BabylAITheme.light;

  /// Initialize the plugin and set up method call handler
  static Future<void> _setupMethodCallHandler() async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'getToken':
          if (_tokenCallback != null) {
            try {
              final token = await _tokenCallback!();
              return token;
            } catch (e) {
              throw PlatformException(
                code: 'TOKEN_ERROR',
                message: 'Failed to get token: $e',
              );
            }
          }
          throw PlatformException(
            code: 'NO_TOKEN_CALLBACK',
            message: 'Token callback not set',
          );

        case 'onMessageReceived':
          if (_messageCallback != null && call.arguments is Map) {
            final args = call.arguments as Map;
            final message = args['message'] as String?;
            if (message != null) {
              _messageCallback!(message);
            }
          }
          break;

        case 'onError':
          if (_errorCallback != null && call.arguments is Map) {
            final args = call.arguments as Map;
            final code = args['code'] as String? ?? 'UNKNOWN';
            final message = args['message'] as String? ?? 'Unknown error';
            final details = args['details'] as String? ?? '';
            _errorCallback!(code, message, details);
          }
          break;
      }
    });
  }

  /// Get platform version (for testing)
  static Future<String?> getPlatformVersion() {
    return BabylaiFlutterPlatform.instance.getPlatformVersion();
  }

  /// Initialize BabylAI SDK
  ///
  /// Must be called before using any other methods.
  ///
  /// [environmentConfig]: The environment configuration (use EnvironmentConfig.production() or EnvironmentConfig.development())
  /// [locale]: The language to use (english or arabic)
  /// [userInfo]: Optional user information
  /// [tokenCallback]: Required callback that returns authentication token
  /// [onMessageReceived]: Optional callback for handling new messages
  /// [onError]: Optional callback for handling errors
  /// [themeConfig]: Optional theme configuration for custom branding
  static Future<void> initialize({
    required EnvironmentConfig environmentConfig,
    required BabylAILocale locale,
    Map<String, dynamic> userInfo = const {},
    required Future<String> Function() tokenCallback,
    void Function(String message)? onMessageReceived,
    void Function(String code, String message, String details)? onError,
    ThemeConfig? themeConfig,
  }) async {
    // Setup method call handler first
    await _setupMethodCallHandler();

    // Store callbacks
    _tokenCallback = tokenCallback;
    _messageCallback = onMessageReceived;
    _errorCallback = onError;
    _currentScreenId = null;

    // Initialize on native side
    await BabylaiFlutterPlatform.instance.initialize(
      environmentConfig: environmentConfig,
      locale: locale,
      userInfo: userInfo,
      themeConfig: themeConfig,
    );

    // Set token callback on native side
    await BabylaiFlutterPlatform.instance.setTokenCallback();

    _isInitialized = true;
  }

  /// Launch BabylAI chat interface
  ///
  /// [screenId]: Optional screen ID, defaults to the one provided in initialize
  /// [theme]: Optional theme, defaults to light
  /// [onMessageReceived]: Optional callback to override the global one
  static Future<void> launchChat({
    String? screenId,
    BabylAITheme? theme,
    void Function(String message)? onMessageReceived,
  }) async {
    _checkInitialized();

    if (onMessageReceived != null) {
      _messageCallback = onMessageReceived;
    }

    final effectiveScreenId = screenId ?? _currentScreenId;
    if (effectiveScreenId == null) {
      throw Exception(
        'screenId must be provided either in initialize() or launchChat()',
      );
    }

    final effectiveTheme = theme ?? _currentTheme;
    _currentTheme = effectiveTheme;

    await BabylaiFlutterPlatform.instance.launchChat(
      screenId: effectiveScreenId,
      theme: effectiveTheme,
    );
  }

  /// Launch active chat directly
  ///
  /// Opens the active chat conversation directly without showing the chat list.
  ///
  /// [screenId]: Optional screen ID, defaults to the one provided in initialize
  /// [theme]: Optional theme, defaults to light
  /// [onMessageReceived]: Optional callback to override the global one
  static Future<void> launchActiveChat({
    String? screenId,
    BabylAITheme? theme,
    void Function(String message)? onMessageReceived,
  }) async {
    _checkInitialized();

    if (onMessageReceived != null) {
      _messageCallback = onMessageReceived;
    }

    final effectiveScreenId = screenId ?? _currentScreenId;
    if (effectiveScreenId == null) {
      throw Exception(
        'screenId must be provided either in initialize() or launchActiveChat()',
      );
    }

    final effectiveTheme = theme ?? _currentTheme;
    _currentTheme = effectiveTheme;

    await BabylaiFlutterPlatform.instance.launchActiveChat(
      screenId: effectiveScreenId,
      theme: effectiveTheme,
    );
  }

  /// Update the theme dynamically
  ///
  /// [theme]: The new theme to apply
  static Future<void> updateTheme(BabylAITheme theme) async {
    _checkInitialized();
    _currentTheme = theme;
    await BabylaiFlutterPlatform.instance.updateTheme(theme);
  }

  /// Update the locale/language dynamically
  ///
  /// [locale]: The new locale to apply
  static Future<void> updateLocale(BabylAILocale locale) async {
    _checkInitialized();
    await BabylaiFlutterPlatform.instance.updateLocale(locale);
  }

  /// Get the current locale
  static Future<BabylAILocale> getLocale() async {
    _checkInitialized();
    return await BabylaiFlutterPlatform.instance.getLocale();
  }

  /// Reset the SDK
  ///
  /// Terminates any active chat sessions and cleans up resources.
  static Future<void> reset() async {
    _checkInitialized();
    await BabylaiFlutterPlatform.instance.reset();
  }

  /// Update the token callback
  ///
  /// Allows changing the token callback after initialization.
  static void setTokenCallback(Future<String> Function() callback) {
    _tokenCallback = callback;
  }

  /// Update the message received callback
  ///
  /// Allows changing the message callback after initialization.
  static void setMessageCallback(void Function(String message) callback) {
    _messageCallback = callback;
  }

  /// Update the error callback
  ///
  /// Allows changing the error callback after initialization.
  static void setErrorCallback(
    void Function(String code, String message, String details) callback,
  ) {
    _errorCallback = callback;
  }

  /// Check if SDK is initialized
  static bool get isInitialized => _isInitialized;

  static void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'BabylaiFlutter is not initialized. Call initialize() first.',
      );
    }
  }
}
