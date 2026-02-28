import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firebase service for authentication and Firestore user storage.
///
/// Singleton — use `FirebaseService()` everywhere.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  factory FirebaseService() => _instance;
  FirebaseService._();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get firestore => _firestore;

  /// Currently signed-in user (null if signed out).
  User? get currentUser => _auth?.currentUser;
  bool get isSignedIn => currentUser != null;
  String? get userId => currentUser?.uid;

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════

  /// Initialize Firebase core + Auth + Firestore.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      debugPrint('✅ FirebaseService initialized');
    } catch (e) {
      debugPrint('⚠️ FirebaseService init failed: $e');
      // App can still run without Firebase
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════

  /// Create a new account with email + password.
  ///
  /// On success, also saves the user profile to Firestore `users/{uid}`.
  /// Returns the [UserCredential].
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _ensureInitialized();

    final credential = await _auth!.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update Firebase Auth display name
    await credential.user?.updateDisplayName(displayName.trim());
    await credential.user?.reload();

    // Save profile to Firestore
    await _saveUserToFirestore(
      uid: credential.user!.uid,
      displayName: displayName.trim(),
      email: email.trim(),
    );

    debugPrint('✅ Sign up successful: ${credential.user?.email}');
    return credential;
  }

  /// Sign in with email + password.
  ///
  /// Updates `lastLoginAt` in Firestore on success.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    _ensureInitialized();

    final credential = await _auth!.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update last login timestamp
    try {
      await _firestore!.collection('users').doc(credential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // User doc may not exist (legacy account) — create it
      await _saveUserToFirestore(
        uid: credential.user!.uid,
        displayName: credential.user!.displayName ?? 'User',
        email: credential.user!.email ?? email.trim(),
      );
    }

    debugPrint('✅ Sign in successful: ${credential.user?.email}');
    return credential;
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    _ensureInitialized();
    await _auth!.signOut();
    debugPrint('✅ Signed out');
  }

  /// Send password reset email.
  Future<void> resetPassword(String email) async {
    _ensureInitialized();
    await _auth!.sendPasswordResetEmail(email: email.trim());
    debugPrint('✅ Password reset email sent to $email');
  }

  // ═══════════════════════════════════════════════════════════════
  // FIRESTORE — USER PROFILE
  // ═══════════════════════════════════════════════════════════════

  /// Save user profile document to `users/{uid}`.
  Future<void> _saveUserToFirestore({
    required String uid,
    required String displayName,
    required String email,
  }) async {
    try {
      await _firestore!.collection('users').doc(uid).set(
        {
          'uid': uid,
          'displayName': displayName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // Don't overwrite if exists
      );
      debugPrint('📦 User profile saved to Firestore: $uid');
    } catch (e) {
      debugPrint('⚠️ Failed to save user to Firestore: $e');
    }
  }

  /// Read user profile from Firestore.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    _ensureInitialized();
    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('⚠️ Failed to read user profile: $e');
      return null;
    }
  }

  /// Update specific fields on the user profile.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    _ensureInitialized();
    await _firestore!.collection('users').doc(uid).update(data);
  }

  /// Listen to auth state changes (stream).
  Stream<User?> get authStateChanges {
    _ensureInitialized();
    return _auth!.authStateChanges();
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  void _ensureInitialized() {
    if (!_isInitialized || _auth == null) {
      throw StateError(
        'FirebaseService not initialized. Call initialize() first.',
      );
    }
  }

  /// Convert FirebaseAuthException to user-friendly message.
  static String friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
