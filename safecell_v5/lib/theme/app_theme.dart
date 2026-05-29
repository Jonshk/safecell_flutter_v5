import 'package:flutter/material.dart';

class AppTheme {
  // Backend / contacto
  static const String apiBase = 'https://safecell-backend.onrender.com';
  static const String whatsapp = 'https://wa.me/+584243060437';

  // SafeCell Premium
  static const Color orange = Color(0xFFFF4F00);
  static const Color orangeDeep = Color(0xFFE63F00);
  static const Color orangeLight = Color(0xFFFFF1EA);

  static const Color black = Color(0xFF090909);
  static const Color ink = Color(0xFF15171C);
  static const Color softBlack = Color(0xFF20232A);

  static const Color grey1 = Color(0xFF4B5563);
  static const Color grey2 = Color(0xFF7B8190);
  static const Color grey3 = Color(0xFFB5B8C2);

  static const Color bgPage = Color(0xFFF3F4F7);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E8EC);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static BoxShadow softShadow([double opacity = .07]) => BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: 24,
        offset: const Offset(0, 12),
      );

  static BoxShadow cardShadow([double opacity = .055]) => BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: 18,
        offset: const Offset(0, 8),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bgPage,
        fontFamily: 'sans-serif',
        colorScheme: const ColorScheme.light(
          primary: orange,
          secondary: black,
          surface: bgCard,
          error: error,
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
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCard,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: orange, width: 1.6),
          ),
          labelStyle: const TextStyle(color: grey2),
          hintStyle: const TextStyle(color: grey3),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
            elevation: 0,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgCard,
          selectedItemColor: orange,
          unselectedItemColor: grey3,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
          displayMedium: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
          titleLarge: TextStyle(
            color: black,
            fontWeight: FontWeight.w900,
          ),
          titleMedium: TextStyle(
            color: black,
            fontWeight: FontWeight.w800,
          ),
          bodyLarge: TextStyle(color: black),
          bodyMedium: TextStyle(color: grey2),
          labelLarge: TextStyle(
            color: black,
            fontWeight: FontWeight.w800,
          ),
        ),
        dividerColor: border,
      );
}