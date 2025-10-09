import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyUploadHost = 'upload_host';

  // Domyślny host dla emulatora Androida:
  static const defaultHost = 'http://10.0.2.2';

  static Future<String> getUploadHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUploadHost) ?? defaultHost;
  }

  static Future<void> setUploadHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUploadHost, host);
  }
}
