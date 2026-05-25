import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = AppTheme.neonCyan,
    this.isLoading = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isPressed ? widget.color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed ? widget.color : widget.color.withValues(alpha: 0.6),
            width: _isPressed ? 2 : 1.5,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.color,
                ),
              )
            else if (widget.icon != null)
              Icon(widget.icon, color: widget.color, size: 18),
            if (widget.icon != null || widget.isLoading) const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}