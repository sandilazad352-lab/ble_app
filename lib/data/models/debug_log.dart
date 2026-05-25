class DebugLog {
  final int? id;
  final String direction;
  final String data;
  final DateTime timestamp;

  DebugLog({
    this.id,
    required this.direction,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  static const String directionSent = 'sent';
  static const String directionReceived = 'received';
  static const String directionSystem = 'system';

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'direction': direction,
        'data': data,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory DebugLog.fromMap(Map<String, dynamic> map) => DebugLog(
        id: map['id'] as int?,
        direction: map['direction'] as String,
        data: map['data'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      );
}