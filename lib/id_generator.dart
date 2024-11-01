import 'package:device_info_plus/device_info_plus.dart';

class IdGenerator {
  static Future<String> generateId() async {
    final deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }
}