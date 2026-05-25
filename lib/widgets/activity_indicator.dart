import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ActivityIndicator extends StatefulWidget {
  final bool isActive;
  final String? label;

  const ActivityIndicator({
    super.key,
    required this.isActive,
    this.label,
  });

  @override
  State<ActivityIndicator> createState() => _ActivityIndicatorState();
}

class _ActivityIndicatorState extends State<ActivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(ActivityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isActive ? AppTheme.neonGreen : AppTheme.textSecondary,
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.neonGreen.withValues(alpha: 0.5 + 0.5 * _controller.value),
                          blurRadius: 8 + 8 * _controller.value,
                          spreadRadius: 1 + 2 * _controller.value,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        if (widget.label != null) ...[
          const SizedBox(width: 6),
          Text(
            widget.label!,
            style: TextStyle(
              color: widget.isActive ? AppTheme.neonGreen : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}