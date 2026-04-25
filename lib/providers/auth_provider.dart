import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  AuthProvider() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null) {
        _user = null;
        notifyListeners();
      } else {
        loadUserProfile();
      }
    });
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _error = null;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadUserProfile();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'An error occurred during sign in';
      return false;
    } on FirebaseException catch (e) {
      _error = e.message ?? 'A Firebase error occurred';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required double heightCm,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      // Step 1: Create Firebase Auth account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        // Step 2: Create user model
        _user = UserModel(
          id: firebaseUser.uid,
          email: email,
          name: name,
          age: age,
          heightCm: heightCm,
        );

        // Step 3: Save profile to Firestore
        try {
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(_user!.toMap());
        } catch (firestoreError) {
          // Auth succeeded but Firestore write failed.
          // Still let the user proceed — profile can be retried later.
          debugPrint('Firestore profile write failed: $firestoreError');
          _error = 'Account created but profile save failed. '
              'Check your Firestore security rules.';
        }
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'An error occurred during sign up';
      return false;
    } on FirebaseException catch (e) {
      _error = e.message ?? 'A Firebase error occurred';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile in Firestore and local state.
  Future<bool> updateProfile({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    int? notificationHour,
    int? notificationMinute,
  }) async {
    if (_user == null || currentUserId == null) return false;
    _setLoading(true);
    _error = null;
    try {
      _user = _user!.copyWith(
        name: name,
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
      );
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update(_user!.toMap());
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      debugPrint('Profile update error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> logout() async => signOut();

  Future<void> loadUserProfile() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          debugPrint('No user profile found in Firestore for uid: ${firebaseUser.uid}');
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to load user profile: $e');
        _error = 'Failed to load profile: ${e.toString()}';
        notifyListeners();
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

