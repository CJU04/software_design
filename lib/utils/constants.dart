import 'package:flutter/material.dart';

class AppColors {
  // Keep these aligned with the app's ThemeData in lib/main.dart (seeded green).
  static const Color primary = Color(0xFF2E7D32); // green.shade700
  static const Color secondary = Color(0xFFA5D6A7); // green.shade300 (approx)
  static const Color accent = Color(0xFF81C784); // green.shade400 (approx)
  static const Color error = Colors.red;
  static const Color success = Color(0xFF388E3C); // green (strong)
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF1F8E9); // light green surface-ish
}


class AppStrings {
  static const String appName = 'FurfectCare';
  static const String welcomeMessage = 'Welcome to FurfectCare';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String dashboard = 'Dashboard';
  static const String pets = 'Pets';
  static const String appointments = 'Appointments';
  static const String medicalHistory = 'Medical History';
  static const String products = 'Products';
  static const String sales = 'Sales';
  static const String inventoryLogs = 'Inventory Logs';
  static const String profileSettings = 'Profile Settings';
  static const String reports = 'Reports';
  static const String settings = 'Settings';
}

class AppConstants {
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double margin = 16.0;
  static const int lowStockThreshold = 10;
}

