import 'package:flutter/material.dart';
import 'package:vetcare_connect/models/user.dart';
import 'package:vetcare_connect/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  User? _currentUser;

  List<User> get users => _users;
  User? get currentUser => _currentUser;

  Future<void> loadUsers() async {
    _users = await DatabaseService().getUsers();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    await loadUsers();
    _currentUser = _users.firstWhere(
      (user) => user.username == username && user.password == password,
      orElse: () => User(username: '', password: '', fullname: '', usertype: '', contactNumber: '', email: '', address: '', status: ''),
    );
    if (_currentUser!.username.isNotEmpty) {
      await _saveCurrentUser();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUser();
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    await DatabaseService().insertUser(user);
    await loadUsers();
  }

  Future<void> updateUser(User user) async {
    await DatabaseService().updateUser(user);
    await loadUsers();
    _currentUser = user;
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    await DatabaseService().deleteUser(id);
    await loadUsers();
  }

  Future<bool> isUsernameExists(String username) async {
    return await DatabaseService().isUsernameExists(username);
  }

  Future<bool> isEmailExists(String email) async {
    return await DatabaseService().isEmailExists(email);
  }

  Future<void> _saveCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setInt('currentUserId', _currentUser!.userid!);
    } else {
      await prefs.remove('currentUserId');
    }
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('currentUserId');
    if (userId != null) {
      await loadUsers();
      _currentUser = _users.firstWhere(
        (user) => user.userid == userId,
        orElse: () => User(username: '', password: '', fullname: '', usertype: '', contactNumber: '', email: '', address: '', status: ''),
      );
      if (_currentUser!.username.isEmpty) {
        _currentUser = null;
      }
      notifyListeners();
    }
  }
}

