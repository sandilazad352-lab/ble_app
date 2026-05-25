import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/ble_provider.dart';
import '../widgets/neon_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isEditing = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final config = context.read<BleProvider>().deviceConfig;
    _controllers['prox_near_dbm'] = TextEditingController(text: config.proxNearDbm?.toString() ?? '-70');
    _controllers['prox_far_dbm'] = TextEditingController(text: config.proxFarDbm?.toString() ?? '-80');
    _controllers['heartbeat_ms'] = TextEditingController(text: config.heartbeatMs?.toString() ?? '1000');
    _controllers['near_publish'] = TextEditingController(text: config.nearPublish?.toString() ?? '0');
    _controllers['ble_tx_power'] = TextEditingController(text: config.bleTxPower?.toString() ?? '4');
    _controllers['adv_interval_min'] = TextEditingController(text: config.advIntervalMin?.toString() ?? '32');
    _controllers['adv_interval_max'] = TextEditingController(text: config.advIntervalMax?.toString() ?? '244');
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final config = ble.deviceConfig;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Settings'),
        actions: [
          if (ble.isConnected)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit, color: AppTheme.neonCyan),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!ble.isConnected)
            _buildDisconnectedBanner(),
          _buildConfigSection('Proximity & Heartbeat', [
            _buildConfigField('prox_near_dbm', 'Near Threshold (dBm)', _controllers['prox_near_dbm']!),
            _buildConfigField('prox_far_dbm', 'Far Threshold (dBm)', _controllers['prox_far_dbm']!),
            _buildConfigField('near_publish', 'Near Publish (0/1)', _controllers['near_publish']!),
            _buildConfigField('heartbeat_ms', 'Heartbeat (ms)', _controllers['heartbeat_ms']!),
          ]),
          _buildConfigSection('BLE Parameters', [
            _buildConfigField('ble_tx_power', 'TX Power (dBm)', _controllers['ble_tx_power']!),
            _buildConfigField('adv_interval_min', 'Adv Min (0.625ms units)', _controllers['adv_interval_min']!),
            _buildConfigField('adv_interval_max', 'Adv Max (0.625ms units)', _controllers['adv_interval_max']!),
          ]),
          const SizedBox(height: 24),
          if (_isEditing && ble.isConnected) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeonButton(
                  label: 'Send Config',
                  icon: Icons.send,
                  color: AppTheme.neonGreen,
                  isLoading: _isSending,
                  onTap: () => _sendConfig(ble),
                ),
                NeonButton(
                  label: 'Refresh',
                  icon: Icons.refresh,
                  color: AppTheme.neonCyan,
                  onTap: () async {
                    await ble.requestConfig();
                    _initControllers();
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildConfigSection('Time Synchronization', []),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NeonButton(
                label: 'Sync Local Time',
                icon: Icons.access_time,
                color: AppTheme.neonCyan,
                onTap: ble.isConnected ? () => ble.syncTime() : () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildConfigSection('Hardware Log Management', []),
          const SizedBox(height: 8),
          if (ble.isConnected) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.cardGlow,
              child: Column(
                children: [
                  _buildDataRow('Persistent Count', '${config.irTotalCount ?? "Unknown"}'),
                  _buildDataRow('Last Mail', config.irLastTime ?? 'None'),
                  _buildDataRow('Last Reset', config.irResetTime ?? 'Never'),
                ],
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NeonButton(
                label: 'Refresh',
                icon: Icons.refresh,
                color: AppTheme.neonCyan,
                onTap: ble.isConnected ? () => ble.requestLog() : () {},
              ),
              NeonButton(
                label: 'Reset Count',
                icon: Icons.exposure_zero,
                color: AppTheme.warningYellow,
                onTap: ble.isConnected ? () => _confirmAction(context, 'Reset counter to 0?', ble.resetLog) : () {},
              ),
              NeonButton(
                label: 'Clear FS',
                icon: Icons.delete_sweep,
                color: AppTheme.dangerRed,
                onTap: ble.isConnected ? () => _confirmAction(context, 'Clear all logs from flash?', ble.clearLog) : () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardGlow.color,
        title: const Text('Confirm Action', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Confirm', style: TextStyle(color: AppTheme.dangerRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.dangerRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: AppTheme.dangerRed, size: 20),
          SizedBox(width: 8),
          Text(
            'Device not connected. Connect to edit settings.',
            style: TextStyle(color: AppTheme.dangerRed, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.neonCyan,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: AppTheme.cardGlow,
          padding: const EdgeInsets.all(12),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildConfigField(String key, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: _isEditing
                ? TextField(
                    controller: controller,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                  )
                : Text(
                    controller.text,
                    style: const TextStyle(
                      color: AppTheme.neonCyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendConfig(BleProvider ble) async {
    setState(() => _isSending = true);
    try {
      final config = <String, dynamic>{};
      for (final entry in _controllers.entries) {
        final value = int.tryParse(entry.value.text);
        if (value != null) config[entry.key] = value;
      }
      await ble.sendConfig(config);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Config sent successfully'),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}