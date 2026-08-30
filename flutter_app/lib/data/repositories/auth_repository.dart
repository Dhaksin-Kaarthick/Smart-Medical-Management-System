import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Repository managing real Firebase Authentication, Cloud Firestore profile synchronization,
/// session states, and role-based access control.
class AuthRepository extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _auth.currentUser != null;

  AuthRepository() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authStateSubscription = _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        await _fetchUserProfile(firebaseUser.uid);
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!, documentId: doc.id);
      } else {
        final fbUser = _auth.currentUser;
        if (fbUser != null) {
          _currentUser = UserModel(
            userId: fbUser.uid,
            name: fbUser.displayName ?? (fbUser.email?.split('@').first ?? 'User'),
            email: fbUser.email ?? '',
            phone: fbUser.phoneNumber ?? '',
            role: 'patient',
            createdAt: DateTime.now(),
          );
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[AuthRepo] Error fetching user profile: $e');
    }
  }

  /// Real Firebase Sign In with email and password
  /// Verifies credentials directly against Google Firebase Authentication.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        _errorMessage = 'Authentication failed. Please try again.';
        _setLoading(false);
        return false;
      }

      // Fetch user profile from Cloud Firestore at users/{uid} with fallback
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          _currentUser = UserModel.fromMap(doc.data()!, documentId: doc.id);
        } else {
          _currentUser = UserModel(
            userId: user.uid,
            name: user.displayName ?? (email.split('@').first),
            email: email.trim(),
            phone: '',
            role: 'patient',
            createdAt: DateTime.now(),
          );
        }
      } catch (firestoreErr) {
        debugPrint('[AuthRepo] Firestore blocked or offline, using fallback: $firestoreErr');
        _currentUser = UserModel(
          userId: user.uid,
          name: user.displayName ?? (email.split('@').first),
          email: email.trim(),
          phone: '',
          role: 'patient',
          createdAt: DateTime.now(),
        );
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
      _currentUser = null;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _currentUser = null;
      _setLoading(false);
      return false;
    }
  }

  /// Real Firebase Registration and Cloud Firestore profile creation
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    DateTime? dateOfBirth,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        _errorMessage = 'Registration failed. User could not be created.';
        _setLoading(false);
        return false;
      }

      // Update Firebase Auth display name
      try {
        await user.updateDisplayName(name);
      } catch (_) {}

      final now = DateTime.now();
      final userProfile = {
        'uid': user.uid,
        'userId': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
      };

      // Save user document in Cloud Firestore under users/{uid}
      try {
        await _firestore.collection('users').doc(user.uid).set(userProfile);
      } catch (firestoreError) {
        debugPrint('[AuthRepo] Firestore profile save warning: $firestoreError');
      }

      _currentUser = UserModel(
        userId: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: role.toLowerCase(),
        createdAt: now,
        dateOfBirth: dateOfBirth,
      );

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
      _currentUser = null;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Registration error: ${e.toString()}';
      _currentUser = null;
      _setLoading(false);
      return false;
    }
  }

  /// Send real password reset email via Firebase Auth
  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Could not send reset email.';
      _setLoading(false);
      return false;
    }
  }

  /// Real Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('[AuthRepo] Error during signOut: $e');
    } finally {
      _currentUser = null;
      notifyListeners();
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found. Please register first.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in your Firebase Console. Please enable it under Authentication > Sign-in method.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
