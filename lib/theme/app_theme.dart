import 'package:flutter/material.dart';

class AppTheme {
  // Palet Warna Naelora (Clean Sky & Modern Blue)
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color accentCyan = Color(0xFF00ACC1);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      surface: surfaceLight,
    ),
    scaffoldBackgroundColor: surfaceLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
      iconTheme: IconThemeData(color: Color(0xFF1E293B)),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEEF2F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
        letterSpacing: -1.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Color(0xFF475569),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF64748B),
      ),
    ),
  );
}
