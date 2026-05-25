import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide ConnectionStatus;
import '../core/constants/ble_constants.dart';
import '../core/utils/json_parser.dart';
import '../data/models/ble_event.dart';
import '../data/models/connection_info.dart';
import '../data/repositories/connection_repository.dart';

class BleService {
  final flutterReactiveBle = FlutterReactiveBle();
  final ConnectionRepository _connectionRepo = ConnectionRepository();

  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<List<int>>? _notifySubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectSub;
  String? _connectedDeviceId;

  String _lineBuffer = '';
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _connectionTimer;
  int? _currentConnectionDbId;

  final _eventController = StreamController<BleEvent>.broadcast();
  final _connectionStateController = StreamController<ConnectionInfo>.broadcast();
  final _debugController = StreamController<Map<String, dynamic>>.broadcast();
  final _rawDataController = StreamController<String>.broadcast();

  ConnectionInfo _connectionInfo = const ConnectionInfo(deviceId: '');
  bool _isScanning = false;
  bool _autoReconnect = true;

  Stream<BleEvent> get events => _eventController.stream;
  Stream<ConnectionInfo> get connectionState => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get debugStream => _debugController.stream;
  Stream<String> get rawData => _rawDataController.stream;
  ConnectionInfo get currentConnection => _connectionInfo;
  bool get isConnected => _connectionInfo.status == ConnectionStatus.connected;
  bool get isScanning => _isScanning;

  void startScan() {
    if (_isScanning) return;
    _isScanning = true;
    _connectionInfo = _connectionInfo.copyWith(status: ConnectionStatus.scanning);
    _notifyConnectionState();

    _debugController.add({'type': 'system', 'message': 'Starting broad BLE scan...'});

    _scanSubscription = flutterReactiveBle
        .scanForDevices(
          withServices: [], // Broad scan for better compatibility
          scanMode: ScanMode.lowLatency,
        )
        .listen((device) {
      final name = device.name;
      final id = device.id;
      final serviceUuids = device.serviceUuids;

      if (name.isNotEmpty) {
        final logMsg = 'Discovered: "$name" ($id) RSSI: ${device.rssi} Services: ${device.serviceUuids}';
        debugPrint(logMsg);
        _debugController.add({
          'type': 'system',
          'message': logMsg,
        });
      }

      final matchesName = name == BleConstants.deviceName || 
                         name.contains('SuperMini') || 
                         name.contains('Mini');
                         
      final matchesService = serviceUuids.any((u) => 
        u.toString().toLowerCase() == BleConstants.serviceUuid.toLowerCase());

      if (matchesName || matchesService) {
        final foundMsg = 'Target Found! Name: "$name", UUID: $id';
        debugPrint(foundMsg);
        _debugController.add({
          'type': 'system',
          'message': foundMsg,
        });
        stopScan();
        connect(id);
      }
    }, onError: (e) {
      debugPrint('Scan error: $e');
      _debugController.add({'type': 'error', 'message': 'Scan error: $e'});
      _isScanning = false;
    });

    Future.delayed(BleConstants.scanTimeout, () {
      if (_isScanning) {
        _debugController.add({'type': 'system', 'message': 'Scan timeout, restarting...'});
        stopScan();
        startScan(); // Auto-restart scan if nothing found
      }
    });
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
  }

  Future<void> connect(String deviceId) async {
    _connectedDeviceId = deviceId;
    _connectionInfo = _connectionInfo.copyWith(
      status: ConnectionStatus.connecting,
      deviceId: deviceId,
    );
    _notifyConnectionState();

    _debugController.add({'type': 'system', 'message': 'Connecting to $deviceId...'});

    _connectionTimer = Timer(BleConstants.connectionTimeout, () {
      if (_connectionInfo.status == ConnectionStatus.connecting) {
        _debugController.add({'type': 'error', 'message': 'Connection timeout'});
        disconnect();
        if (_autoReconnect) _scheduleReconnect();
      }
    });

    try {
      _connectSub = flutterReactiveBle.connectToDevice(
        id: deviceId,
        connectionTimeout: const Duration(seconds: 15),
      ).listen((update) {
        _handleConnectionStateUpdate(update);
      }, onError: (e) {
        _debugController.add({'type': 'error', 'message': 'Connection error: $e'});
        _handleDisconnect();
      });
    } catch (e) {
      _debugController.add({'type': 'error', 'message': 'Connect failed: $e'});
      _handleDisconnect();
    }
  }

  void _handleConnectionStateUpdate(ConnectionStateUpdate update) {
    switch (update.connectionState) {
      case DeviceConnectionState.connected:
        _connectionTimer?.cancel();
        _reconnectAttempts = 0;
        _connectionInfo = _connectionInfo.copyWith(
          status: ConnectionStatus.connected,
          connectedAt: DateTime.now(),
        );
        _notifyConnectionState();
        _saveConnection();
        _requestMtu();
        _discoverAndSubscribe();
        break;
      case DeviceConnectionState.disconnected:
        _handleDisconnect();
        break;
      default:
        break;
    }
  }

  void _handleDisconnect() {
    _connectionTimer?.cancel();
    _notifySubscription?.cancel();
    _notifySubscription = null;

    final wasConnected = _connectionInfo.status == ConnectionStatus.connected;
    _connectionInfo = _connectionInfo.copyWith(
      status: ConnectionStatus.disconnected,
      disconnectedAt: DateTime.now(),
    );
    _notifyConnectionState();

    if (wasConnected && _currentConnectionDbId != null) {
      _updateConnectionEnd();
    }

    _debugController.add({'type': 'system', 'message': 'Disconnected'});

    if (_autoReconnect && wasConnected) {
      _scheduleReconnect();
    }
  }

  Future<void> _saveConnection() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    final info = ConnectionInfo(
      deviceId: _connectedDeviceId ?? '',
      connectedAt: DateTime.now(),
    );
    try {
      _currentConnectionDbId = await _connectionRepo.saveConnection(info);
    } catch (_) {}
  }

  Future<void> _updateConnectionEnd() async {
    if (_currentConnectionDbId == null) return;
    try {
      await _connectionRepo.updateDisconnection(
        _currentConnectionDbId!,
        DateTime.now(),
        0,
      );
    } catch (_) {}
  }

  Future<void> _requestMtu() async {
    if (_connectedDeviceId == null) return;
    try {
      final mtu = await flutterReactiveBle.requestMtu(
        deviceId: _connectedDeviceId!,
        mtu: BleConstants.requestedMtu,
      );
      _connectionInfo = _connectionInfo.copyWith(mtu: mtu);
      _notifyConnectionState();
      _debugController.add({'type': 'system', 'message': 'MTU negotiated: $mtu'});
    } catch (e) {
      _debugController.add({'type': 'error', 'message': 'MTU request failed: $e'});
    }
  }

  Future<void> _discoverAndSubscribe() async {
    if (_connectedDeviceId == null) return;

    try {
      debugPrint('Discovering services for $_connectedDeviceId...');
      final services = await flutterReactiveBle.discoverServices(_connectedDeviceId!);
      for (final s in services) {
        debugPrint('Discovered Service: ${s.serviceId}');
        for (final c in s.characteristics) {
          debugPrint('  Characteristic: ${c.characteristicId} [${c.isNotifiable ? "NOTIFY" : ""} ${c.isIndicatable ? "INDICATE" : ""} ${c.isWritableWithResponse ? "WRITE" : ""} ${c.isWritableWithoutResponse ? "WRITE_NO_RESP" : ""}]');
        }
      }

      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(BleConstants.serviceUuid),
        characteristicId: Uuid.parse(BleConstants.txCharacteristicUuid),
        deviceId: _connectedDeviceId!,
      );

      debugPrint('Subscribing to TX: ${BleConstants.txCharacteristicUuid}');
      _notifySubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristic)
          .listen((data) {
        try {
          final text = utf8.decode(data, allowMalformed: true);
          debugPrint('Raw BLE Data: $text');
          _processIncomingData(text);
        } catch (e) {
          debugPrint('Decode error: $e');
        }
      }, onError: (e) {
        debugPrint('Notify error: $e');
        _debugController.add({'type': 'error', 'message': 'Notify error: $e'});
      });

      _debugController.add({
        'type': 'system',
        'message': 'Subscribed to TX notifications',
      });
    } catch (e) {
      debugPrint('Discovery error: $e');
      _debugController.add({
        'type': 'error',
        'message': 'Discovery failed: $e',
      });
    }
  }

  void _processIncomingData(String data) {
    _lineBuffer += data;

    while (_lineBuffer.contains('\n')) {
      final newlineIndex = _lineBuffer.indexOf('\n');
      final line = _lineBuffer.substring(0, newlineIndex).trim();
      _lineBuffer = _lineBuffer.substring(newlineIndex + 1);

      if (line.isEmpty) continue;
      debugPrint('Processing BLE Line: $line');
      _rawDataController.add(line);

      final parsed = JsonParser.tryParse(line);
      if (parsed != null) {
        final event = BleEvent.fromJson(parsed);
        _eventController.add(event);
        _debugController.add({
          'type': 'event',
          'event': event.type.name,
          'raw': line,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        _debugController.add({
          'type': 'raw',
          'data': line,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> sendCommand(String command) async {
    if (_connectedDeviceId == null || !isConnected) {
      _debugController.add({'type': 'error', 'message': 'Not connected'});
      return;
    }

    _debugController.add({
      'type': 'sent',
      'command': command,
      'timestamp': DateTime.now().toIso8601String(),
    });

    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(BleConstants.serviceUuid),
        characteristicId: Uuid.parse(BleConstants.rxCharacteristicUuid),
        deviceId: _connectedDeviceId!,
      );

      final bytes = ('$command\n').codeUnits;
      await flutterReactiveBle.writeCharacteristicWithResponse(characteristic, value: bytes);
    } catch (e) {
      _debugController.add({'type': 'error', 'message': 'Write failed: $e'});
    }
  }

  Future<void> sendConfig(Map<String, dynamic> config) async {
    final json = jsonEncode(config);
    await sendCommand('config $json');
  }

  Future<void> requestConfig() async {
    await sendCommand('config');
  }

  Future<void> syncTime() async {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await sendCommand('time $epoch');
  }

  Future<void> syncDate() async {
    final now = DateTime.now();
    await sendCommand(
      'date ${now.year} ${now.month.toString().padLeft(2, '0')} ${now.day.toString().padLeft(2, '0')}',
    );
  }

  Future<void> requestLog() async {
    await sendCommand('log');
  }

  Future<void> resetLog() async {
    await sendCommand('log reset');
  }

  Future<void> clearLog() async {
    await sendCommand('log clear');
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= BleConstants.maxReconnectAttempts) {
      _debugController.add({
        'type': 'system',
        'message': 'Max reconnect attempts reached',
      });
      return;
    }

    _reconnectAttempts++;
    final delay = BleConstants.reconnectDelay * _reconnectAttempts;

    _debugController.add({
      'type': 'system',
      'message': 'Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    });

    _reconnectTimer = Timer(delay, () {
      startScan();
    });
  }

  void setAutoReconnect(bool value) {
    _autoReconnect = value;
    if (!value) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }
  }

  void _notifyConnectionState() {
    _connectionStateController.add(_connectionInfo);
  }

  Future<void> disconnect() async {
    _autoReconnect = false;
    _reconnectTimer?.cancel();
    _connectionTimer?.cancel();
    stopScan();
    _notifySubscription?.cancel();
    _notifySubscription = null;
    _connectSub?.cancel();
    _connectSub = null;
    _connectedDeviceId = null;
    _connectionInfo = const ConnectionInfo(deviceId: '');
    _notifyConnectionState();
  }

  Future<void> readRssi() async {
    if (_connectedDeviceId == null) return;
    try {
      final rssi = await flutterReactiveBle
          .readRssi(_connectedDeviceId!);
      _connectionInfo = _connectionInfo.copyWith(rssi: rssi);
      _notifyConnectionState();
    } catch (_) {}
  }

  void dispose() {
    disconnect();
    _eventController.close();
    _connectionStateController.close();
    _debugController.close();
    _rawDataController.close();
  }
}