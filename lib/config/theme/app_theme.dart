import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette: 60% primary, 30% secondary, 10% accent
  // Primary Green - Forest/Deep Green palette (60% - main brand color)
  static const Color primaryGreen = Color(0xFF2E7D32); // Forest green (60%)
  static const Color primaryGreenLight = Color(0xFF4CAF50);

  // Secondary Teal (30% - supporting color)
  static const Color secondaryTeal = Color(0xFF00897B); // Teal
  static const Color secondaryTealLight = Color(0xFF26A69A);

  // Accent Purple (10% - accent/highlight color)
  static const Color accentPurple = Color(0xFF7E57C2); // Purple accent
  static const Color backgroundMint = Color(0xFFF4F9F4); // Soft off-white/mint

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryGreen, // 60% - main actions, app bar, primary buttons
      secondary: secondaryTeal, // 30% - secondary actions, highlights
      tertiary: accentPurple, // 10% - accent highlights, special calls-to-action
      surface: backgroundMint,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: backgroundMint,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryTeal,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }
}

