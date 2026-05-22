import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  static Future<UserCredential> createAccount({
    required String name,
    required String email,
    required String password,
    required int graduationYear,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await credential.user?.updateDisplayName(name.trim());
    await _saveUserProfile(
      user: credential.user,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'graduationYear': graduationYear,
        'provider': 'password',
      },
    );

    return credential;
  }

  static Future<UserCredential> signInWithGoogle() async {
    UserCredential credential;

    if (kIsWeb) {
      credential = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw const AuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      credential = await _auth.signInWithCredential(googleCredential);
    }

    await _saveUserProfile(
      user: credential.user,
      data: {
        'name': credential.user?.displayName ?? '',
        'email': credential.user?.email ?? '',
        'photoUrl': credential.user?.photoURL,
        'provider': 'google.com',
      },
    );

    return credential;
  }

  static Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      if (!kIsWeb) GoogleSignIn().signOut(),
    ]);
  }

  static String messageForAuthError(Object error) {
    if (error is AuthCancelledException) {
      return 'Google sign-in was cancelled.';
    }

    if (error is! FirebaseAuthException) {
      return 'Something went wrong. Please try again.';
    }

    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please use a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked to another sign-in method.';
      case 'popup-closed-by-user':
        return 'Google sign-in was closed before it finished.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  static Future<void> _saveUserProfile({
    required User? user,
    required Map<String, Object?> data,
  }) async {
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    await userDoc.set({
      ...data,
      'uid': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}
