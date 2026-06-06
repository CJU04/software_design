import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';


class AppInitProvider extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;

  AppInitProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Initialize only if not already initialized by `main()`.
      // This provider primarily tracks init errors and provides a loading state.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      errorMessage = null;
    } on FirebaseException catch (e) {
      errorMessage = 'Firebase Error: ${e.message}';
      debugPrint('Firebase init error: $errorMessage');
    } catch (e) {
      errorMessage = 'Initialization Error: $e';
      debugPrint('Firebase init error: $errorMessage');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

