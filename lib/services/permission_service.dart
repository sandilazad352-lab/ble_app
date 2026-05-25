import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestBlePermissions() async {
    if (Platform.isAndroid) {
      final bluetoothScan = await Permission.bluetoothScan.request();
      final bluetoothConnect = await Permission.bluetoothConnect.request();
      final location = await Permission.location.request();

      return bluetoothScan.isGranted &&
          bluetoothConnect.isGranted &&
          location.isGranted;
    } else if (Platform.isIOS) {
      final bluetooth = await Permission.bluetooth.request();
      return bluetooth.isGranted;
    }
    return true;
  }

  static Future<bool> checkBlePermissions() async {
    if (Platform.isAndroid) {
      return await Permission.bluetoothScan.isGranted &&
          await Permission.bluetoothConnect.isGranted &&
          await Permission.location.isGranted;
    } else if (Platform.isIOS) {
      return await Permission.bluetooth.isGranted;
    }
    return true;
  }
}
