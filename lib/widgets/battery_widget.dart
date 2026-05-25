import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BatteryWidget extends StatelessWidget {
  final int? percentage;
  final int? voltageMv;

  const BatteryWidget({
    super.key,
    this.percentage,
    this.voltageMv,
  });

  Color get _batteryColor {
    final pct = percentage ?? 0;
    if (pct > 60) return AppTheme.neonGreen;
    if (pct > 20) return AppTheme.warningYellow;
    return AppTheme.dangerRed;
  }

  @override
  Widget build(BuildContext context) {
    final pct = percentage ?? 0;
    final mv = voltageMv ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_std, color: _batteryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'BATTERY',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    color: _batteryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(mv / 1000).toStringAsFixed(2)}V',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$mv mV',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: AppTheme.darkSurface,
              color: _batteryColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}