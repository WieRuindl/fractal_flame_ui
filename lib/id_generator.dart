import 'package:device_info_plus/device_info_plus.dart';

class IdGenerator {
  static Future<String> generateId() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.id;
    } catch (e) {
      print("error: $e");
      return "0";
    }
  }
}