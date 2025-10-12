import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'babylai_flutter_platform_interface.dart';
import 'models/theme_config.dart';

/// An implementation of [BabylaiFlutterPlatform] that uses method channels.
class MethodChannelBabylaiFlutter extends BabylaiFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('babylai_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> initialize({
    required EnvironmentConfig environmentConfig,
    required BabylAILocale locale,
    Map<String, dynamic> userInfo = const {},
    ThemeConfig? themeConfig,
  }) async {
    await methodChannel.invokeMethod<void>('initialize', {
      'environment': environmentConfig.environment.value,
      'enableLogging': environmentConfig.enableLogging,
      'locale': locale == BabylAILocale.arabic ? 'arabic' : 'english',
      'userInfo': userInfo,
      if (themeConfig != null) 'themeConfig': themeConfig.toMap(),
    });
  }

  @override
  Future<void> setTokenCallback() async {
    await methodChannel.invokeMethod<void>('setTokenCallback');
  }

  @override
  Future<void> launchChat({
    required String screenId,
    required BabylAITheme theme,
  }) async {
    await methodChannel.invokeMethod<void>('launchChat', {
      'screenId': screenId,
      'theme': theme == BabylAITheme.dark ? 'dark' : 'light',
    });
  }

  @override
  Future<void> launchActiveChat({
    required String screenId,
    required BabylAITheme theme,
  }) async {
    await methodChannel.invokeMethod<void>('launchActiveChat', {
      'screenId': screenId,
      'theme': theme == BabylAITheme.dark ? 'dark' : 'light',
    });
  }

  @override
  Future<void> updateTheme(BabylAITheme theme) async {
    await methodChannel.invokeMethod<void>('updateTheme', {
      'theme': theme == BabylAITheme.dark ? 'dark' : 'light',
    });
  }

  @override
  Future<void> updateLocale(BabylAILocale locale) async {
    await methodChannel.invokeMethod<void>('updateLocale', {
      'locale': locale == BabylAILocale.arabic ? 'arabic' : 'english',
    });
  }

  @override
  Future<BabylAILocale> getLocale() async {
    final result = await methodChannel.invokeMethod<String>('getLocale');
    return result == 'arabic' ? BabylAILocale.arabic : BabylAILocale.english;
  }

  @override
  Future<void> reset() async {
    await methodChannel.invokeMethod<void>('reset');
  }
}
