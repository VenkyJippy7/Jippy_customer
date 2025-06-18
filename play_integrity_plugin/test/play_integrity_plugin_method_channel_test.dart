import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_integrity_plugin/play_integrity_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelPlayIntegrityPlugin platform = MethodChannelPlayIntegrityPlugin();
  const MethodChannel channel = MethodChannel('play_integrity_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
