import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'config/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/app_init_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/firebase_user_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/medical_history_provider.dart';
import 'providers/product_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/sale_item_provider.dart';
import 'providers/inventory_log_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check should be initialized AFTER Firebase initialization.
  // This prevents "No AppCheckProvider installed" warnings.
  try {
    if (kIsWeb) {
      // Note: In this project's firebase_app_check version, passing a WebProvider to
      // `activate()` isn't supported (webProvider is required, but WebProvider isn't exposed).
      // To avoid runtime crashes on web, we attempt activation and ignore failures.
      await FirebaseAppCheck.instance.activate();
    } else {
      // Android: App Check with Play Integrity (default).
      await FirebaseAppCheck.instance.activate();
    }
  } catch (e) {
    debugPrint('App Check activation failed: $e');
    // Keep development running even if App Check isn't fully configured yet.
  }

  // If App Check activation failed on web (missing required WebProvider), the app
  // will still run; full proper web App Check requires configuring it in Firebase Console.

  // continue startup
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppInitProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseUserProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => MedicalHistoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => SaleItemProvider()),
        ChangeNotifierProvider(create: (_) => InventoryLogProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const VetCareConnectApp(),
    ),
  );
}

class VetCareConnectApp extends StatelessWidget {
  const VetCareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'VetCare Connect',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.themeMode,
          initialRoute: AppRouter.splashRoute,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
