import 'package:flutter/material.dart';

class AppTheme {
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonBlue = Color(0xFF0080FF);
  static const Color neonPurple = Color(0xFFB026FF);
  static const Color neonPink = Color(0xFFFF1493);
  static const Color neonOrange = Color(0xFFFF6600);
  static const Color darkBg = Color(0xFF0A0E17);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1A1F2E);
  static const Color darkBorder = Color(0xFF2A3040);
  static const Color textPrimary = Color(0xFFE8ECF1);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color dangerRed = Color(0xFFFF3B3B);
  static const Color warningYellow = Color(0xFFFFD600);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: const ColorScheme.dark(
          primary: neonCyan,
          secondary: neonPurple,
          surface: darkSurface,
          error: dangerRed,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: neonCyan,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: neonCyan),
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: darkBorder, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonCyan,
            foregroundColor: darkBg,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: neonCyan,
            side: const BorderSide(color: neonCyan),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
          headlineMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          headlineSmall: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          bodySmall: TextStyle(color: textSecondary, fontSize: 12),
          labelLarge: TextStyle(
            color: neonCyan,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: darkBorder,
          thickness: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkCard,
          selectedItemColor: neonCyan,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: neonCyan),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: neonCyan,
          inactiveTrackColor: darkBorder,
          thumbColor: neonCyan,
          overlayColor: neonCyan.withValues(alpha: 0.2),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return neonCyan;
            return textSecondary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return neonCyan.withValues(alpha: 0.4);
            return darkBorder;
          }),
        ),
      );

  static BoxDecoration get neonGlow => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonCyan.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      );

  static BoxDecoration get cardGlow => BoxDecoration(
        color: darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration pulsingGlow(Color color) => BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      );
}