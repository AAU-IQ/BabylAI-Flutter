import 'package:flutter_test/flutter_test.dart';
import 'package:babylai_flutter/babylai_flutter.dart';
import 'package:babylai_flutter/babylai_flutter_platform_interface.dart';
import 'package:babylai_flutter/babylai_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBabylaiFlutterPlatform
    with MockPlatformInterfaceMixin
    implements BabylaiFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BabylaiFlutterPlatform initialPlatform = BabylaiFlutterPlatform.instance;

  test('$MethodChannelBabylaiFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBabylaiFlutter>());
  });

  test('getPlatformVersion', () async {
    BabylaiFlutter babylaiFlutterPlugin = BabylaiFlutter();
    MockBabylaiFlutterPlatform fakePlatform = MockBabylaiFlutterPlatform();
    BabylaiFlutterPlatform.instance = fakePlatform;

    expect(await babylaiFlutterPlugin.getPlatformVersion(), '42');
  });
}
