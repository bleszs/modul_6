import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:modul_6/services/auth/auth_services.dart';

class AuthNotifier with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<User?> signUp(String email, String password) async {
    _setLoading(true);
    try {
      return await _authService.signUp(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signIn(String email, String password) async {
    _setLoading(true);
    try {
      return await _authService.signIn(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
