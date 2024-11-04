import 'package:device_info_plus/device_info_plus.dart';

class IdGenerator {
  static Future<String> generateId() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.id;
  }
}