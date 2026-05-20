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

  static BoxDecoration glassDialogDecoration({required bool isDark}) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1C2438) : Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: isDark ? const Color(0xFF2A3550) : const Color(0xFFDDE4F0),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.55 : 0.12),
          blurRadius: 48,
          offset: const Offset(0, 20),
        ),
      ],
    );
  }

  static ThemeData lightTheme() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: lightBg,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: accentPurple,
        surface: lightSurface,
        error: errorRed,
        tertiary: primaryCyan,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: const Color(0xFF0D1420),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0D1420),
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: lightBorder, width: 1.5),
          foregroundColor: primaryTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        hintStyle: const TextStyle(color: Color(0xFFABB8CC)),
        labelStyle: const TextStyle(color: Color(0xFF7A8FAF)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Color(0xFF8B9AB0),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: lightBorder,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primaryTeal : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? primaryTeal.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2)),
      ),
    );
  }

  static ThemeData darkTheme() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryCyan,
      scaffoldBackgroundColor: darkBg,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: accentPurple,
        surface: darkSurface,
        error: errorRed,
        tertiary: primaryTeal,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: darkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: darkBorder, width: 1.5),
          foregroundColor: primaryCyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCyan, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        hintStyle: const TextStyle(color: Color(0xFF4A5568)),
        labelStyle: const TextStyle(color: Color(0xFF6B7A99)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryCyan,
        unselectedItemColor: Color(0xFF4A5568),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: darkBorder,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primaryCyan : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? primaryCyan.withOpacity(0.3)
                : Colors.grey.withOpacity(0.15)),
      ),
    );
  }
}
