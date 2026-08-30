import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/local_database_service.dart';

/// Repository managing local database authentication, persistent sessions,
/// and patient user profiles.
class AuthRepository extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthRepository() {
    _initLocalSession();
  }

  Future<void> _initLocalSession() async {
    try {
      final activeUser = await _localDb.getActiveUser();
      if (activeUser != null) {
        _currentUser = activeUser;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AuthRepo] Error loading local session: $e');
    }
  }

  /// Sign in with email and password against local database
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter both email and password.';
      _setLoading(false);
      return false;
    }

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final user = await _localDb.authenticateUser(trimmedEmail, password);

      if (user == null) {
        final exists = await _localDb.userExists(trimmedEmail);
        if (!exists) {
          _errorMessage = 'No account found with this email. Please register first.';
        } else {
          _errorMessage = 'Incorrect password.';
        }
        _currentUser = null;
        _setLoading(false);
        return false;
      }

      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('Incorrect password')) {
        _errorMessage = 'Incorrect password.';
      } else {
        _errorMessage = 'Login failed. Please check your credentials.';
      }
      _currentUser = null;
      _setLoading(false);
      return false;
    }
  }

  /// Register a new Patient in the local database
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'patient',
    DateTime? dateOfBirth,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final user = await _localDb.registerUser(
        name: name.trim(),
        email: email.trim(),
        password: password,
        phone: phone.trim(),
        dateOfBirth: dateOfBirth,
      );

      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _currentUser = null;
      _setLoading(false);
      return false;
    }
  }

  /// Reset password locally
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final exists = await _localDb.userExists(email.trim());
      if (!exists) {
        _errorMessage = 'No account found with this email.';
        _setLoading(false);
        return false;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Could not reset password.';
      _setLoading(false);
      return false;
    }
  }

  /// Sign out and clear local session
  Future<void> signOut() async {
    try {
      await _localDb.clearActiveUser();
    } catch (e) {
      debugPrint('[AuthRepo] Error clearing session: $e');
    } finally {
      _currentUser = null;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
