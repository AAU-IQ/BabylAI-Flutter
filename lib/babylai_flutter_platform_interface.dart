import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'babylai_flutter_method_channel.dart';
import 'models/theme_config.dart';
import 'models/environment_config.dart';

export 'models/environment_config.dart';

/// Enum for BabylAI locale/language
enum BabylAILocale { english, arabic }

/// Enum for BabylAI theme
enum BabylAITheme { light, dark }

abstract class BabylaiFlutterPlatform extends PlatformInterface {
  /// Constructs a BabylaiFlutterPlatform.
  BabylaiFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BabylaiFlutterPlatform _instance = MethodChannelBabylaiFlutter();

  /// The default instance of [BabylaiFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelBabylaiFlutter].
  static BabylaiFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BabylaiFlutterPlatform] when
  /// they register themselves.
  static set instance(BabylaiFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Initialize BabylAI SDK
  Future<void> initialize({
    required EnvironmentConfig environmentConfig,
    required BabylAILocale locale,
    Map<String, dynamic> userInfo = const {},
    ThemeConfig? themeConfig,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Set token callback
  Future<void> setTokenCallback() {
    throw UnimplementedError('setTokenCallback() has not been implemented.');
  }

  /// Launch BabylAI chat
  Future<void> launchChat({
    required String screenId,
    required BabylAITheme theme,
  }) {
    throw UnimplementedError('launchChat() has not been implemented.');
  }

  /// Launch active chat directly
  Future<void> launchActiveChat({
    required String screenId,
    required BabylAITheme theme,
  }) {
    throw UnimplementedError('launchActiveChat() has not been implemented.');
  }

  /// Update theme
  Future<void> updateTheme(BabylAITheme theme) {
    throw UnimplementedError('updateTheme() has not been implemented.');
  }

  /// Update locale
  Future<void> updateLocale(BabylAILocale locale) {
    throw UnimplementedError('updateLocale() has not been implemented.');
  }

  /// Get current locale
  Future<BabylAILocale> getLocale() {
    throw UnimplementedError('getLocale() has not been implemented.');
  }

  /// Reset SDK
  Future<void> reset() {
    throw UnimplementedError('reset() has not been implemented.');
  }
}
