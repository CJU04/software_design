import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.teal);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        surface: Colors.grey.shade900,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }
}

