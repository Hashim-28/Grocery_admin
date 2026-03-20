import 'package:flutter/material.dart';

enum UserRole { admin, staff, none }

class AuthProvider extends ChangeNotifier {
  UserRole _role = UserRole.none;
  bool _isLoading = false;

  UserRole get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _role != UserRole.none;

  Future<void> login(UserRole role, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Mock API call
    await Future.delayed(const Duration(seconds: 1));

    _role = role;
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _role = UserRole.none;
    notifyListeners();
  }
}
