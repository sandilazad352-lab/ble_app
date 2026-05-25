import '../../core/constants/db_constants.dart';

enum ConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

class ConnectionInfo {
  final String deviceId;
  final String deviceName;
  final ConnectionStatus status;
  final DateTime? connectedAt;
  final DateTime? disconnectedAt;
  final int? rssi;
  final int? mtu;
  final String? errorMessage;

  const ConnectionInfo({
    required this.deviceId,
    this.deviceName = 'SuperMini',
    this.status = ConnectionStatus.disconnected,
    this.connectedAt,
    this.disconnectedAt,
    this.rssi,
    this.mtu,
    this.errorMessage,
  });

  ConnectionInfo copyWith({
    String? deviceId,
    String? deviceName,
    ConnectionStatus? status,
    DateTime? connectedAt,
    DateTime? disconnectedAt,
    int? rssi,
    int? mtu,
    String? errorMessage,
  }) =>
      ConnectionInfo(
        deviceId: deviceId ?? this.deviceId,
        deviceName: deviceName ?? this.deviceName,
        status: status ?? this.status,
        connectedAt: connectedAt ?? this.connectedAt,
        disconnectedAt: disconnectedAt ?? this.disconnectedAt,
        rssi: rssi ?? this.rssi,
        mtu: mtu ?? this.mtu,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  Map<String, dynamic> toMap() => {
        DbConstants.columnDeviceId: deviceId,
        DbConstants.columnDeviceName: deviceName,
        DbConstants.columnConnectedAt: connectedAt?.millisecondsSinceEpoch,
        DbConstants.columnDisconnectedAt: disconnectedAt?.millisecondsSinceEpoch,
        DbConstants.columnRssi: rssi,
        DbConstants.columnMtu: mtu,
      };

  factory ConnectionInfo.fromMap(Map<String, dynamic> map) => ConnectionInfo(
        deviceId: map[DbConstants.columnDeviceId] as String,
        deviceName: map[DbConstants.columnDeviceName] as String? ?? 'SuperMini',
        connectedAt: map[DbConstants.columnConnectedAt] != null
            ? DateTime.fromMillisecondsSinceEpoch(map[DbConstants.columnConnectedAt] as int)
            : null,
        disconnectedAt: map[DbConstants.columnDisconnectedAt] != null
            ? DateTime.fromMillisecondsSinceEpoch(map[DbConstants.columnDisconnectedAt] as int)
            : null,
        rssi: map[DbConstants.columnRssi] as int?,
        mtu: map[DbConstants.columnMtu] as int?,
      );
}
