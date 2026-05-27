import 'package:flutter/material.dart';

class AppTheme {
  // ⚠️ CAMBIAR a tu URL real del backend
  static const String apiBase = 'https://safecell-backend.onrender.com';
  static const String whatsapp = 'https://wa.me/+584243060437';

  // Colores
  static const Color orange    = Color(0xFFFF4F00);
  static const Color orangeLight = Color(0xFFFFF5F0);
  static const Color black     = Color(0xFF0A0A0A);
  static const Color grey1     = Color(0xFF555E6E);
  static const Color grey2     = Color(0xFF888888);
  static const Color grey3     = Color(0xFFBBBBBB);
  static const Color bgPage    = Color(0xFFF7F7F7);
  static const Color bgCard    = Color(0xFFFFFFFF);
  static const Color border    = Color(0xFFEDEDED);
  static const Color success   = Color(0xFF22C55E);
  static const Color error     = Color(0xFFEF4444);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgPage,
    fontFamily: 'sans-serif',
    colorScheme: const ColorScheme.light(
      primary:   orange,
      secondary: black,
      surface:   bgCard,
      error:     error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgCard,
      foregroundColor: black,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: black,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
        color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: orange, width: 1.5),
      ),
      labelStyle: const TextStyle(color: grey2),
      hintStyle: const TextStyle(color: grey3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCard,
      selectedItemColor: orange,
      unselectedItemColor: grey3,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(color: black, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(color: black, fontWeight: FontWeight.w700),
      titleLarge:    TextStyle(color: black, fontWeight: FontWeight.w800),
      titleMedium:   TextStyle(color: black, fontWeight: FontWeight.w700),
      bodyLarge:     TextStyle(color: black),
      bodyMedium:    TextStyle(color: grey2),
      labelLarge:    TextStyle(color: black, fontWeight: FontWeight.w700),
    ),
    dividerColor: border,
  );
}
