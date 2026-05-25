import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/connection_info.dart';

class ConnectionIndicator extends StatefulWidget {
  final ConnectionStatus status;
  final String? deviceName;
  final int? rssi;

  const ConnectionIndicator({
    super.key,
    required this.status,
    this.deviceName,
    this.rssi,
  });

  @override
  State<ConnectionIndicator> createState() => _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends State<ConnectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return AppTheme.neonGreen;
      case ConnectionStatus.connecting:
      case ConnectionStatus.scanning:
        return AppTheme.neonCyan;
      case ConnectionStatus.disconnected:
        return AppTheme.textSecondary;
      case ConnectionStatus.error:
        return AppTheme.dangerRed;
    }
  }

  String get _statusText {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.scanning:
        return 'Scanning...';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  bool get _shouldAnimate =>
      widget.status == ConnectionStatus.connecting ||
      widget.status == ConnectionStatus.scanning ||
      widget.status == ConnectionStatus.connected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _statusColor,
                boxShadow: _shouldAnimate
                    ? [
                        BoxShadow(
                          color: _statusColor.withValues(alpha: _pulseAnimation.value),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _statusText,
              style: TextStyle(
                color: _statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            if (widget.deviceName != null && widget.status == ConnectionStatus.connected)
              Text(
                widget.deviceName!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        if (widget.rssi != null && widget.status == ConnectionStatus.connected) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _rssiColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rssiColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${widget.rssi} dBm',
              style: TextStyle(
                color: _rssiColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color get _rssiColor {
    final rssi = widget.rssi ?? -100;
    if (rssi >= -50) return AppTheme.neonGreen;
    if (rssi >= -70) return AppTheme.neonCyan;
    if (rssi >= -85) return AppTheme.warningYellow;
    return AppTheme.dangerRed;
  }
}