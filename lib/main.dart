import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'config/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/app_init_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/medical_history_provider.dart';
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
      // Note: In this project’s firebase_app_check version, passing a WebProvider to
      // `activate()` isn’t supported (webProvider is required, but WebProvider isn’t exposed).
      // To avoid runtime crashes on web, we attempt activation and ignore failures.
      await FirebaseAppCheck.instance.activate();
    } else {
      // Android: Play Integrity.
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
      );
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
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => MedicalHistoryProvider()),
      ],
      child: const VetCareConnectApp(),
    ),
  );
}

class VetCareConnectApp extends StatelessWidget {
  const VetCareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VetCare Connect',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRouter.splashRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}


