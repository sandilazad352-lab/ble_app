import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/ble_provider.dart';
import '../widgets/connection_indicator.dart';

class ProximityScreen extends StatefulWidget {
  const ProximityScreen({super.key});

  @override
  State<ProximityScreen> createState() => _ProximityScreenState();
}

class _ProximityScreenState extends State<ProximityScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _transitionController;
  String _lastStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleProvider>();
    final isNear = ble.proximityStatus == 'NEAR';
    final statusColor = isNear ? AppTheme.neonGreen : ble.proximityStatus == 'AWAY'
        ? AppTheme.neonPurple
        : AppTheme.textSecondary;

    if (ble.proximityStatus != _lastStatus && ble.proximityStatus != 'Unknown') {
      _lastStatus = ble.proximityStatus;
      _transitionController.forward(from: 0.0);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Proximity')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _transitionController]),
              builder: (context, child) {
                final pulseValue = _pulseController.value;
                final transitionValue = _transitionController.value;

                return Transform.scale(
                  scale: 1.0 + (isNear ? pulseValue * 0.05 : 0) + transitionValue * 0.1,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: 0.08),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3 + pulseValue * 0.3),
                        width: 3,
                      ),
                      boxShadow: isNear
                          ? [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.3 + pulseValue * 0.2),
                                blurRadius: 40 + pulseValue * 20,
                                spreadRadius: 5 + pulseValue * 10,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isNear ? Icons.near_me : Icons.directions_walk,
                          size: 56,
                          color: statusColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ble.proximityStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            if (ble.currentRssi != null)
              Column(
                children: [
                  Text(
                    '${ble.currentRssi} dBm',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRssiBar(ble.currentRssi ?? -100, statusColor),
                ],
              ),
            const SizedBox(height: 24),
            ConnectionIndicator(
              status: ble.connection.status,
              deviceName: ble.connection.deviceName,
            ),
            const SizedBox(height: 16),
            Text(
              ble.isConnected ? 'Monitoring proximity' : 'Connect device to monitor',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRssiBar(int rssi, Color color) {
    final normalized = ((rssi + 100).clamp(0, 70)) / 70;
    return Container(
      width: 200,
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: normalized,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}