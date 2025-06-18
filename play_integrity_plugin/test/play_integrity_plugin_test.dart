import 'package:flutter_test/flutter_test.dart';
import 'package:play_integrity_plugin/play_integrity_plugin.dart';
import 'package:play_integrity_plugin/play_integrity_plugin_platform_interface.dart';
import 'package:play_integrity_plugin/play_integrity_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPlayIntegrityPluginPlatform
    with MockPlatformInterfaceMixin
    implements PlayIntegrityPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PlayIntegrityPluginPlatform initialPlatform = PlayIntegrityPluginPlatform.instance;

  test('$MethodChannelPlayIntegrityPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPlayIntegrityPlugin>());
  });

  test('getPlatformVersion', () async {
    PlayIntegrityPlugin playIntegrityPlugin = PlayIntegrityPlugin();
    MockPlayIntegrityPluginPlatform fakePlatform = MockPlayIntegrityPluginPlatform();
    PlayIntegrityPluginPlatform.instance = fakePlatform;

    expect(await playIntegrityPlugin.getPlatformVersion(), '42');
  });
}
