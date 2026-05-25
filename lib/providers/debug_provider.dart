import 'package:flutter/material.dart';

class DebugProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _logs = [];
  final List<String> _sentCommands = [];
  final List<String> _receivedPackets = [];
  final List<String> _connectionLogs = [];
  static const int maxLogs = 500;

  List<Map<String, dynamic>> get logs => List.unmodifiable(_logs);
  List<String> get sentCommands => List.unmodifiable(_sentCommands);
  List<String> get receivedPackets => List.unmodifiable(_receivedPackets);
  List<String> get connectionLogs => List.unmodifiable(_connectionLogs);

  void addLog(Map<String, dynamic> log) {
    _logs.insert(0, log);
    if (_logs.length > maxLogs) _logs.removeRange(maxLogs, _logs.length);

    final type = log['type'] as String?;
    switch (type) {
      case 'sent':
        _sentCommands.insert(0, log['command']?.toString() ?? '');
        if (_sentCommands.length > maxLogs) _sentCommands.removeRange(maxLogs, _sentCommands.length);
        break;
      case 'received':
      case 'raw':
        _receivedPackets.insert(0, log['data']?.toString() ?? '');
        if (_receivedPackets.length > maxLogs) _receivedPackets.removeRange(maxLogs, _receivedPackets.length);
        break;
      case 'system':
      case 'error':
        final msg = '${log['timestamp'] ?? ''} - ${log['message'] ?? ''}';
        _connectionLogs.insert(0, msg);
        if (_connectionLogs.length > maxLogs) _connectionLogs.removeRange(maxLogs, _connectionLogs.length);
        break;
    }
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    _sentCommands.clear();
    _receivedPackets.clear();
    _connectionLogs.clear();
    notifyListeners();
  }
}