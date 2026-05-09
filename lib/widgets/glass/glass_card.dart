// Create a custom container card with solid styling and animations.

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Provide interface component for Glass Card.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? glowColor;
  final double glowOpacity;
  final VoidCallback? onTap;
  final bool animate;
  final Color? accentColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.blur = 0,
    this.glowColor,
    this.glowOpacity = 0.15,
    this.onTap,
    this.animate = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveAccent = accentColor ?? glowColor;

    Widget card = Container(
      decoration: AppTheme.solidCard(
        isDark: isDark,
        borderRadius: borderRadius,
        accentColor: effectiveAccent,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (effectiveAccent != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: effectiveAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    ),
                  ),
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor:
              (effectiveAccent ?? AppTheme.primaryCyan).withOpacity(0.08),
          highlightColor:
              (effectiveAccent ?? AppTheme.primaryCyan).withOpacity(0.04),
          child: card,
        ),
      );
    }

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        builder: (_, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        ),
        child: card,
      );
    }

    return card;
  }
}
