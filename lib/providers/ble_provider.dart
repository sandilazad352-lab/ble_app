import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/ble_event.dart';
import '../data/models/connection_info.dart';
import '../data/models/device_config.dart';
import '../data/models/mail_record.dart';
import '../data/repositories/config_repository.dart';
import '../data/repositories/mail_repository.dart';
import '../services/ble_service.dart';
import '../services/notification_service.dart';
import '../core/utils/time_utils.dart';
import 'mail_provider.dart';
import 'debug_provider.dart';

class BleProvider extends ChangeNotifier {
  final BleService _bleService = BleService();
  final MailRepository _mailRepo = MailRepository();
  final ConfigRepository _configRepo = ConfigRepository();
  MailProvider? _mailProvider;
  DebugProvider? _debugProvider;

  StreamSubscription<BleEvent>? _eventSub;
  StreamSubscription<ConnectionInfo>? _connectionSub;
  StreamSubscription<Map<String, dynamic>>? _debugSub;

  ConnectionInfo _connection = const ConnectionInfo(deviceId: '');
  DeviceConfig _deviceConfig = const DeviceConfig();
  int _totalMailCount = 0;
  int _todayMailCount = 0;
  DateTime? _lastMailTime;
  int? _batteryPercent;
  int? _batteryMv;
  int? _currentRssi;
  String _proximityStatus = 'Unknown';
  DateTime? _deviceTime;
  bool _isActivityActive = false;
  final List<BleEvent> _recentEvents = [];

  ConnectionInfo get connection => _connection;
  DeviceConfig get deviceConfig => _deviceConfig;
  int get totalMailCount => _totalMailCount;
  int get todayMailCount => _todayMailCount;
  DateTime? get lastMailTime => _lastMailTime;
  int? get batteryPercent => _batteryPercent;
  int? get batteryMv => _batteryMv;
  int? get currentRssi => _currentRssi;
  String get proximityStatus => _proximityStatus;
  DateTime? get deviceTime => _deviceTime;
  bool get isActivityActive => _isActivityActive;
  List<BleEvent> get recentEvents => List.unmodifiable(_recentEvents);
  bool get isConnected => _connection.status == ConnectionStatus.connected;

  BleProvider() {
    _init();
  }

  void _init() {
    _connectionSub = _bleService.connectionState.listen((info) {
      _connection = info;
      if (info.status == ConnectionStatus.connected) {
        _onConnected();
      }
      notifyListeners();
    });

    _eventSub = _bleService.events.listen((event) {
      _handleEvent(event);
    });

    _loadStats();
  }

  Future<void> _loadStats() async {
    _totalMailCount = await _mailRepo.getTotalCount();
    _todayMailCount = await _mailRepo.getTodayCount();
    final latest = await _mailRepo.getLatest();
    if (latest != null) {
      _lastMailTime = latest.timestamp;
    }
    _deviceConfig = await _configRepo.getConfig();
    notifyListeners();
  }

  Future<void> _onConnected() async {
    await _bleService.syncTime();
    await _bleService.syncDate();
    await Future.delayed(const Duration(milliseconds: 500));
    await _bleService.requestConfig();
    await NotificationService.showConnectionStatus(
      title: 'SuperMini Connected',
      body: 'Device connected successfully',
    );
  }

  void _handleEvent(BleEvent event) {
    debugPrint('Received BLE Event: ${event.type} - ${event.raw}');
    _recentEvents.insert(0, event);
    if (_recentEvents.length > 50) _recentEvents.removeLast();

    switch (event.type) {
      case BleEventType.ir:
        _handleIrEvent(event);
        break;
      case BleEventType.heartbeat:
        _handleHeartbeat(event);
        break;
      case BleEventType.near:
        _handleNearEvent(event);
        break;
      case BleEventType.away:
        _handleAwayEvent(event);
        break;
      case BleEventType.config:
        _handleConfigEvent(event);
        break;
      case BleEventType.configSaved:
        _handleConfigSaved(event);
        break;
      case BleEventType.configError:
        break;
      case BleEventType.log:
        break;
      case BleEventType.logCleared:
      case BleEventType.logReset:
        break;
      case BleEventType.echo:
        break;
      case BleEventType.unknown:
        break;
    }

    notifyListeners();
  }

  void _handleIrEvent(BleEvent event) {
    _isActivityActive = true;
    _totalMailCount = event.count ?? (_totalMailCount + 1);
    _todayMailCount++;
    _lastMailTime = event.receivedAt;
    _currentRssi = event.rssi;

    _mailRepo.addRecord(MailRecord(
      count: event.count ?? _totalMailCount,
      timestamp: event.receivedAt,
      rssi: event.rssi,
      batteryPct: _batteryPercent,
      batteryMv: _batteryMv,
    ));

    _mailProvider?.addRecord(MailRecord(
      count: event.count ?? _totalMailCount,
      timestamp: event.receivedAt,
      rssi: event.rssi,
      batteryPct: _batteryPercent,
      batteryMv: _batteryMv,
    ));

    NotificationService.showNewMail(
      count: _totalMailCount,
      time: TimeUtils.formatDateTime(event.receivedAt),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _isActivityActive = false;
      notifyListeners();
    });
  }

  void _handleHeartbeat(BleEvent event) {
    _batteryMv = event.batMv;
    _batteryPercent = event.batPct;
    _currentRssi = event.rssi;
  }

  void _handleNearEvent(BleEvent event) {
    _proximityStatus = 'NEAR';
    _currentRssi = event.rssi;
  }

  void _handleAwayEvent(BleEvent event) {
    _proximityStatus = 'AWAY';
    _currentRssi = event.rssi;
  }

  void _handleConfigEvent(BleEvent event) {
    _deviceConfig = DeviceConfig.fromJson(event.raw);
    _configRepo.saveConfig(_deviceConfig);
  }

  void _handleConfigSaved(BleEvent event) {
    _configRepo.saveConfig(_deviceConfig);
  }

  void startScan() => _bleService.startScan();
  void disconnect() => _bleService.disconnect();
  void setAutoReconnect(bool value) => _bleService.setAutoReconnect(value);

  Future<void> sendConfig(Map<String, dynamic> config) async {
    await _bleService.sendConfig(config);
  }

  Future<void> requestConfig() async => _bleService.requestConfig();
  Future<void> requestLog() async => _bleService.requestLog();
  Future<void> resetLog() async => _bleService.resetLog();
  Future<void> clearLog() async => _bleService.clearLog();
  Future<void> syncTime() async => _bleService.syncTime();

  Stream<Map<String, dynamic>> get debugStream => _bleService.debugStream;
  Stream<String> get rawDataStream => _bleService.rawData;
  BleService get bleService => _bleService;

  void update(MailProvider mailProvider, DebugProvider debugProvider) {
    _mailProvider = mailProvider;
    _debugProvider = debugProvider;
    
    _debugSub?.cancel();
    _debugSub = _bleService.debugStream.listen((log) {
      _debugProvider?.addLog(log);
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _connectionSub?.cancel();
    _debugSub?.cancel();
    _bleService.dispose();
    super.dispose();
  }
}