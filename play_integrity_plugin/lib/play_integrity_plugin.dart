
import 'play_integrity_plugin_platform_interface.dart';

class PlayIntegrityPlugin {
  Future<String?> getPlatformVersion() {
    return PlayIntegrityPluginPlatform.instance.getPlatformVersion();
  }
}
