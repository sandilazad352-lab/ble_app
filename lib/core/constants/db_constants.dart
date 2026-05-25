class DbConstants {
  static const String dbName = 'supermini.db';
  static const int dbVersion = 2;

  static const String mailTable = 'mail_history';
  static const String configTable = 'device_config';
  static const String connectionTable = 'connection_history';
  static const String statsTable = 'device_stats';

  static const String columnId = 'id';
  static const String columnCount = 'count';
  static const String columnTimestamp = 'timestamp';
  static const String columnRssi = 'rssi';
  static const String columnBattery = 'battery_pct';
  static const String columnBatteryMv = 'battery_mv';
  static const String columnEvent = 'event';
  static const String columnRawJson = 'raw_json';
  static const String columnConnectedAt = 'connected_at';
  static const String columnDisconnectedAt = 'disconnected_at';
  static const String columnDuration = 'duration';
  static const String columnDeviceId = 'device_id';
  static const String columnDeviceName = 'device_name';
  static const String columnMtu = 'mtu';
  static const String columnKey = 'config_key';
  static const String columnValue = 'config_value';
  static const String columnDate = 'date';
  static const String columnTotalMail = 'total_mail';
}