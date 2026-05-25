class DeviceConfig {
  final int? proxNearDbm;
  final int? proxFarDbm;
  final int? heartbeatMs;
  final int? nearPublish;
  final int? bleTxPower;
  final int? advIntervalMin;
  final int? advIntervalMax;
  final int? irTotalCount;
  final String? irLastTime;
  final String? irResetTime;

  const DeviceConfig({
    this.proxNearDbm,
    this.proxFarDbm,
    this.heartbeatMs,
    this.nearPublish,
    this.bleTxPower,
    this.advIntervalMin,
    this.advIntervalMax,
    this.irTotalCount,
    this.irLastTime,
    this.irResetTime,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> json) => DeviceConfig(
        proxNearDbm: json['prox_near_dbm'] as int?,
        proxFarDbm: json['prox_far_dbm'] as int?,
        heartbeatMs: json['heartbeat_ms'] as int?,
        nearPublish: json['near_publish'] as int?,
        bleTxPower: json['ble_tx_power'] as int?,
        advIntervalMin: json['adv_interval_min'] as int?,
        advIntervalMax: json['adv_interval_max'] as int?,
        irTotalCount: json['ir_total_count'] as int?,
        irLastTime: json['ir_last_time'] as String?,
        irResetTime: json['ir_reset_time'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (proxNearDbm != null) 'prox_near_dbm': proxNearDbm,
        if (proxFarDbm != null) 'prox_far_dbm': proxFarDbm,
        if (heartbeatMs != null) 'heartbeat_ms': heartbeatMs,
        if (nearPublish != null) 'near_publish': nearPublish,
        if (bleTxPower != null) 'ble_tx_power': bleTxPower,
        if (advIntervalMin != null) 'adv_interval_min': advIntervalMin,
        if (advIntervalMax != null) 'adv_interval_max': advIntervalMax,
        if (irTotalCount != null) 'ir_total_count': irTotalCount,
        if (irLastTime != null) 'ir_last_time': irLastTime,
        if (irResetTime != null) 'ir_reset_time': irResetTime,
      };

  String toConfigCommand() {
    final parts = toJson().entries.map((e) => '"${e.key}":${e.value}').join(',');
    return 'config {$parts}';
  }

  DeviceConfig copyWith({
    int? proxNearDbm,
    int? proxFarDbm,
    int? heartbeatMs,
    int? nearPublish,
    int? bleTxPower,
    int? advIntervalMin,
    int? advIntervalMax,
    int? irTotalCount,
    String? irLastTime,
    String? irResetTime,
  }) =>
      DeviceConfig(
        proxNearDbm: proxNearDbm ?? this.proxNearDbm,
        proxFarDbm: proxFarDbm ?? this.proxFarDbm,
        heartbeatMs: heartbeatMs ?? this.heartbeatMs,
        nearPublish: nearPublish ?? this.nearPublish,
        bleTxPower: bleTxPower ?? this.bleTxPower,
        advIntervalMin: advIntervalMin ?? this.advIntervalMin,
        advIntervalMax: advIntervalMax ?? this.advIntervalMax,
        irTotalCount: irTotalCount ?? this.irTotalCount,
        irLastTime: irLastTime ?? this.irLastTime,
        irResetTime: irResetTime ?? this.irResetTime,
      );
}