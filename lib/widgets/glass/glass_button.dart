// Render a customized solid button with press animations.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Provide interface component for Glass Button.
class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;
  final LinearGradient? gradient;
  final double height;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
    this.gradient,
    this.height = 52,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

// Manage state and provide providers for Glass Button State.
class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null;
    final grad = widget.gradient ?? AppTheme.primaryGradient;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => _pressCtrl.forward(),
        onTapUp: isDisabled
            ? null
            : (_) {
                _pressCtrl.reverse();
                widget.onPressed?.call();
              },
        onTapCancel: isDisabled ? null : () => _pressCtrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: widget.height,
          decoration: widget.isPrimary
              ? BoxDecoration(
                  gradient: isDisabled
                      ? const LinearGradient(
                          colors: [Color(0xFF4A5568), Color(0xFF4A5568)],
                        )
                      : grad,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isDisabled
                      ? null
                      : [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                )
              : BoxDecoration(
                  color: isDark
                      ? AppTheme.primaryCyan.withOpacity(0.07)
                      : AppTheme.primaryCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDisabled
                        ? AppTheme.darkBorder
                        : AppTheme.primaryCyan.withOpacity(0.55),
                    width: 1.5,
                  ),
                ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: widget.isPrimary
                          ? Colors.white
                          : AppTheme.primaryCyan,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 20,
                          color: widget.isPrimary
                              ? Colors.white
                              : (isDark
                                  ? AppTheme.primaryCyan
                                  : AppTheme.primaryTeal),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.isPrimary
                              ? Colors.white
                              : (isDark
                                  ? AppTheme.primaryCyan
                                  : AppTheme.primaryTeal),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
