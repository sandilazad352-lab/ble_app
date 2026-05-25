import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MailCounter extends StatefulWidget {
  final int count;
  final bool isActive;

  const MailCounter({
    super.key,
    required this.count,
    this.isActive = false,
  });

  @override
  State<MailCounter> createState() => _MailCounterState();
}

class _MailCounterState extends State<MailCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(MailCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _controller.forward(from: 0.0);
    }
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.darkCard,
              border: Border.all(
                color: widget.isActive
                    ? AppTheme.neonCyan.withValues(alpha: _glowAnimation.value)
                    : AppTheme.neonCyan.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.neonCyan.withValues(alpha: 0.4 * _glowAnimation.value),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.neonCyan.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    color: AppTheme.neonCyan,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: widget.isActive
                        ? [
                            Shadow(
                              color: AppTheme.neonCyan.withValues(alpha: 0.8),
                              blurRadius: 20,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'MAIL',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}