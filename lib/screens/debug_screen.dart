import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/ble_provider.dart';
import '../providers/debug_provider.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commandController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _listenToDebugStream();
  }

  void _listenToDebugStream() {
    final ble = context.read<BleProvider>();
    ble.debugStream.listen((log) {
      if (mounted) {
        context.read<DebugProvider>().addLog(log);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debug = context.watch<DebugProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Console'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Raw'),
            Tab(text: 'Events'),
            Tab(text: 'Sent'),
            Tab(text: 'Logs'),
          ],
          labelColor: AppTheme.neonCyan,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.neonCyan,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRawStream(debug),
                _buildEventsStream(debug),
                _buildSentCommands(debug),
                _buildConnectionLogs(debug),
              ],
            ),
          ),
          _buildCommandInput(),
        ],
      ),
    );
  }

  Widget _buildRawStream(DebugProvider debug) {
    if (debug.logs.isEmpty) {
      return const Center(child: Text('No data yet', style: TextStyle(color: AppTheme.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: debug.logs.length,
      itemBuilder: (context, index) {
        final log = debug.logs[index];
        final type = log['type'] as String? ?? '';
        final data = log['data'] ?? log['raw'] ?? log['message'] ?? '';
        final timestamp = log['timestamp'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeChip(type),
                  const SizedBox(width: 8),
                  Text(timestamp, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                data.toString(),
                style: TextStyle(
                  color: type == 'error' ? AppTheme.dangerRed : AppTheme.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventsStream(DebugProvider debug) {
    final events = debug.logs.where((l) => l['type'] == 'event').toList();
    if (events.isEmpty) {
      return const Center(child: Text('No events yet', style: TextStyle(color: AppTheme.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final log = events[index];
        final eventName = log['event'] as String? ?? '';
        final raw = log['raw'] as String? ?? '';
        final timestamp = log['timestamp'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _getEventColor(eventName).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getEventColor(eventName).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      eventName.toUpperCase(),
                      style: TextStyle(color: _getEventColor(eventName), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(timestamp, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              Text(raw, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontFamily: 'Courier')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSentCommands(DebugProvider debug) {
    if (debug.sentCommands.isEmpty) {
      return const Center(child: Text('No commands sent', style: TextStyle(color: AppTheme.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: debug.sentCommands.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.arrow_upward, color: AppTheme.neonCyan, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  debug.sentCommands[index],
                  style: const TextStyle(color: AppTheme.neonCyan, fontFamily: 'Courier', fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectionLogs(DebugProvider debug) {
    if (debug.connectionLogs.isEmpty) {
      return const Center(child: Text('No logs', style: TextStyle(color: AppTheme.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: debug.connectionLogs.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            debug.connectionLogs[index],
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'Courier'),
          ),
        );
      },
    );
  }

  Widget _buildCommandInput() {
    final ble = context.read<BleProvider>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppTheme.darkCard,
        border: Border(top: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commandController,
                style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Courier', fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Send command...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => _sendCommand(ble),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppTheme.neonCyan),
              onPressed: () => _sendCommand(ble),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendCommand(BleProvider ble) async {
    final cmd = _commandController.text.trim();
    if (cmd.isEmpty) return;
    await ble.bleService.sendCommand(cmd);
    _commandController.clear();
  }

  Widget _buildTypeChip(String type) {
    Color color;
    switch (type) {
      case 'sent':
        color = AppTheme.neonCyan;
        break;
      case 'received':
      case 'raw':
        color = AppTheme.neonGreen;
        break;
      case 'event':
        color = AppTheme.neonPurple;
        break;
      case 'error':
        color = AppTheme.dangerRed;
        break;
      default:
        color = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(type.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Color _getEventColor(String eventName) {
    switch (eventName) {
      case 'ir':
        return AppTheme.neonCyan;
      case 'heartbeat':
        return AppTheme.neonGreen;
      case 'near':
        return AppTheme.neonGreen;
      case 'away':
        return AppTheme.neonPurple;
      case 'config':
      case 'config_saved':
        return AppTheme.neonBlue;
      case 'config_error':
        return AppTheme.dangerRed;
      default:
        return AppTheme.textSecondary;
    }
  }
}