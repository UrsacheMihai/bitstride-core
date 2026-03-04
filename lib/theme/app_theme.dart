import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Set up the styles and theme tokens for the App Theme.
class AppTheme {
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryTeal = Color(0xFF00BFA5);
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentPink = Color(0xFFE040FB);

  static const Color xpGold = Color(0xFFFFD740);
  static const Color successGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color warningOrange = Color(0xFFFFAB40);

  static const Color darkBg = Color(0xFF0A0E17);
  static const Color darkSurface = Color(0xFF10151F);
  static const Color darkCard = Color(0xFF161D2B);
  static const Color darkCard2 = Color(0xFF1C2438);
  static const Color darkBorder = Color(0xFF242D3F);

  static const Color lightBg = Color(0xFFF2F5FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF7F9FD);
  static const Color lightCard2 = Color(0xFFEEF2FB);
  static const Color lightBorder = Color(0xFFDDE4F0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient xpGradient = LinearGradient(
    colors: [Color(0xFFFFD740), Color(0xFFFF6D00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static BoxDecoration solidCard({
    bool isDark = true,
    double borderRadius = 20,
    Color? accentColor,
    bool elevated = false,
  }) {
    final base = isDark ? darkCard : lightSurface;
    final border = isDark ? darkBorder : lightBorder;
    return BoxDecoration(
      color: elevated ? (isDark ? darkCard2 : lightCard) : base,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: accentColor != null ? accentColor.withOpacity(0.35) : border,
        width: accentColor != null ? 1.5 : 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.30 : 0.06),
          blurRadius: elevated ? 24 : 12,
          offset: const Offset(0, 4),
        ),
        if (accentColor != null)
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
      ],
    );
  }

  static BoxDecoration glassCard({
    bool isDark = true,
    double borderRadius = 20,
    Color? borderColor,
  }) =>
      solidCard(isDark: isDark, borderRadius: borderRadius);

  static BoxDecoration meshBackground({required bool isDark}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF080C14),
                const Color(0xFF0D1320),
                const Color(0xFF0A0E17),
              ]
            : [
                const Color(0xFFF2F5FB),
                const Color(0xFFECF1F9),
                const Color(0xFFF2F5FB),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

}