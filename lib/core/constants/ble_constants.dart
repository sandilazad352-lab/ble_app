class BleConstants {
  static const String deviceName = 'SuperMini';
  static const String serviceUuid = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String txCharacteristicUuid = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const String rxCharacteristicUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const int requestedMtu = 247;
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const int maxReconnectAttempts = 5;
  static const Duration scanTimeout = Duration(seconds: 10);
}