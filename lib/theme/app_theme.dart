import 'package:flutter/material.dart';

class AppTheme {
  // ── Colors ──
  static const Color primary = Color(0xFF0052D0); // Vibrant Blue
  static const Color primaryLight = Color(0xFFE6F0FF); // Light tinted primary
  static const Color background = Color(0xFFF8F5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFE6E6FF);
  
  static const Color textMain = Color(0xFF272B51);
  static const Color textVariant = Color(0xFF545881);
  static const Color outline = Color(0xFF70749E);

  static const Color accentGradientStart = Color(0xFF0052D0);
  static const Color accentGradientEnd = Color(0xFF5C98FF);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentGradientStart, accentGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ──
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get dropShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
        surface: surface,
      ),
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: background,
      
      // ── Text Theme ──
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Lexend', color: textMain, fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: TextStyle(fontFamily: 'Lexend', color: textMain, fontWeight: FontWeight.bold, fontSize: 28),
        displaySmall: TextStyle(fontFamily: 'Lexend', color: textMain, fontWeight: FontWeight.bold, fontSize: 24),
        headlineMedium: TextStyle(fontFamily: 'Lexend', color: textMain, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge: TextStyle(fontFamily: 'Lexend', color: textMain, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: TextStyle(fontFamily: 'Manrope', color: textMain, fontSize: 16),
        bodyMedium: TextStyle(fontFamily: 'Manrope', color: textVariant, fontSize: 14),
      ),

      // ── AppBar Theme ──
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textMain),
        titleTextStyle: TextStyle(
          fontFamily: 'Lexend',
          color: textMain,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      // ── Button Themes ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ── Input Decoration Theme ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: outline.withOpacity(0.6), fontFamily: 'Manrope'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),



      // ── Bottom Sheet Theme ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      
      // ── Divider Theme ──
      dividerTheme: DividerThemeData(
        color: outline.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
