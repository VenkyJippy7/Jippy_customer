import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'play_integrity_plugin_method_channel.dart';

abstract class PlayIntegrityPluginPlatform extends PlatformInterface {
  /// Constructs a PlayIntegrityPluginPlatform.
  PlayIntegrityPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static PlayIntegrityPluginPlatform _instance = MethodChannelPlayIntegrityPlugin();

  /// The default instance of [PlayIntegrityPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelPlayIntegrityPlugin].
  static PlayIntegrityPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PlayIntegrityPluginPlatform] when
  /// they register themselves.
  static set instance(PlayIntegrityPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
