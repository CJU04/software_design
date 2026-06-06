import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth/auth_service.dart';
import '../services/firestore/user_service.dart';
import '../models/user_role.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  AuthProvider({
    AuthService? authService,
    UserService? userService,
  })  : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService();

  User? firebaseUser;
  UserRole? role;

  bool isLoading = false;
  String? errorMessage;

  bool get isSignedIn => firebaseUser != null;

  Future<void> syncCurrentUser() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        role = null;
        return;
      }
      role = await _userService.getUserRole(firebaseUser!.uid);
    } catch (e) {
      errorMessage = fDebugPrint('Auth sync error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailPassword(email: email, password: password);
      firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        role = await _userService.getUserRole(firebaseUser!.uid);
      }
    } catch (e) {
      errorMessage = fDebugPrint('Sign-in error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerWithEmailPassword(email: email, password: password);
      final uid = _authService.currentUser?.uid;

      if (uid == null) {
        throw Exception('User UID not found after registration.');
      }

      await _userService.createUserProfile(
        uid: uid,
        name: name,
        email: email,
        role: role,
      );

      firebaseUser = _authService.currentUser;
      this.role = role;
    } catch (e) {
      errorMessage = fDebugPrint('Registration error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email: email);
    } catch (e) {
      errorMessage = fDebugPrint('Reset error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      firebaseUser = null;
      role = null;
    } catch (e) {
      errorMessage = fDebugPrint('Sign-out error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

String fDebugPrint(Object e) => e.toString();

