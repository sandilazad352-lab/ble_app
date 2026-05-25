import '../../core/constants/db_constants.dart';

class MailRecord {
  final int? id;
  final int count;
  final DateTime timestamp;
  final int? rssi;
  final int? batteryPct;
  final int? batteryMv;

  MailRecord({
    this.id,
    required this.count,
    required this.timestamp,
    this.rssi,
    this.batteryPct,
    this.batteryMv,
  });

  factory MailRecord.fromMap(Map<String, dynamic> map) => MailRecord(
        id: map[DbConstants.columnId] as int?,
        count: map[DbConstants.columnCount] as int,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            map[DbConstants.columnTimestamp] as int),
        rssi: map[DbConstants.columnRssi] as int?,
        batteryPct: map[DbConstants.columnBattery] as int?,
        batteryMv: map[DbConstants.columnBatteryMv] as int?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) DbConstants.columnId: id,
        DbConstants.columnCount: count,
        DbConstants.columnTimestamp: timestamp.millisecondsSinceEpoch,
        DbConstants.columnRssi: rssi,
        DbConstants.columnBattery: batteryPct,
        DbConstants.columnBatteryMv: batteryMv,
      };

  MailRecord copyWith({
    int? id,
    int? count,
    DateTime? timestamp,
    int? rssi,
    int? batteryPct,
    int? batteryMv,
  }) =>
      MailRecord(
        id: id ?? this.id,
        count: count ?? this.count,
        timestamp: timestamp ?? this.timestamp,
        rssi: rssi ?? this.rssi,
        batteryPct: batteryPct ?? this.batteryPct,
        batteryMv: batteryMv ?? this.batteryMv,
      );
}
