enum BleEventType {
  ir,
  heartbeat,
  near,
  away,
  config,
  configSaved,
  configError,
  log,
  logCleared,
  logReset,
  echo,
  unknown;

  static BleEventType fromString(String value) {
    switch (value) {
      case 'ir':
        return BleEventType.ir;
      case 'heartbeat':
        return BleEventType.heartbeat;
      case 'near':
        return BleEventType.near;
      case 'away':
        return BleEventType.away;
      case 'config':
        return BleEventType.config;
      case 'config_saved':
        return BleEventType.configSaved;
      case 'config_error':
        return BleEventType.configError;
      case 'log':
        return BleEventType.log;
      case 'log_cleared':
        return BleEventType.logCleared;
      case 'log_reset':
        return BleEventType.logReset;
      case 'echo':
        return BleEventType.echo;
      default:
        return BleEventType.unknown;
    }
  }
}

class BleEvent {
  final BleEventType type;
  final Map<String, dynamic> raw;
  final DateTime receivedAt;

  BleEvent({required this.type, required this.raw, DateTime? receivedAt})
      : receivedAt = receivedAt ?? DateTime.now();

  int? get count => raw['count'] as int?;
  String? get time => raw['time'] as String?;
  int? get batMv => raw['bat_mv'] as int?;
  int? get batPct => raw['bat_pct'] as int?;
  int? get rssi => raw['rssi'] as int?;
  String? get message => raw['message'] as String?;
  String? get error => raw['error'] as String?;

  factory BleEvent.fromJson(Map<String, dynamic> json) {
    final eventStr = json['event'] as String? ?? '';
    return BleEvent(
      type: BleEventType.fromString(eventStr),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => {
        ...raw,
        'received_at': receivedAt.toIso8601String(),
      };

  @override
  String toString() => 'BleEvent(type: $type, raw: $raw)';
}