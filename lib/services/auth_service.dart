import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static bool get currentUserUsesPassword {
    return currentUser?.providerData.any(
          (provider) => provider.providerId == 'password',
        ) ??
        false;
  }

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
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
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());
    await _saveUserProfile(
      user: credential.user,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'emailLower': email.trim().toLowerCase(),
        'graduationYear': graduationYear,
        'provider': 'password',
      },
    );

    return credential;
  }

  static Future<UserCredential> signInWithGoogle() async {
    UserCredential credential;

    try {
      if (kIsWeb) {
        credential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await _googleSignIn.signIn();
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
    } on PlatformException catch (error) {
      throw _googlePlatformException(error);
    }

    await _saveUserProfile(
      user: credential.user,
      data: {
        'name': credential.user?.displayName ?? '',
        'email': credential.user?.email ?? '',
        'emailLower': credential.user?.email?.trim().toLowerCase() ?? '',
        'photoUrl': credential.user?.photoURL,
        'provider': 'google.com',
      },
    );

    return credential;
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim();
    final profile = await _findUserProfileByEmail(normalizedEmail);

    if (profile == null) {
      throw FirebaseAuthException(
        code: 'user-not-found-for-reset',
        message: 'No UniGuide account was found for this email.',
      );
    }

    if (profile.provider.isNotEmpty && profile.provider != 'password') {
      throw FirebaseAuthException(
        code: 'provider-not-password',
        message: 'This account uses Google sign-in.',
      );
    }

    return _auth.sendPasswordResetEmail(email: profile.email);
  }

  static Future<void> sendCurrentUserPasswordResetEmail() async {
    final email = currentUser?.email;
    if (email == null || email.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'This account does not have an email address.',
      );
    }

    if (!currentUserUsesPassword) {
      throw FirebaseAuthException(
        code: 'provider-not-password',
        message: 'This account signs in with Google.',
      );
    }

    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> changeCurrentUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    final email = user?.email;

    if (user == null || email == null || email.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'This account does not have an email address.',
      );
    }

    if (!currentUserUsesPassword) {
      throw FirebaseAuthException(
        code: 'provider-not-password',
        message: 'This account signs in with Google.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
    await user.reload();
  }

  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      if (!kIsWeb) _googleSignIn.signOut(),
    ]);
  }

  static Future<void> deleteCurrentAccount() async {
    final user = currentUser;
    if (user == null) {
      return;
    }

    final userDoc = _firestore.collection('users').doc(user.uid);
    await _deleteCollection(userDoc.collection('favorites'));
    await _deleteCollection(userDoc.collection('notifications'));
    await _deleteCollection(userDoc.collection('searchHistory'));
    await userDoc.delete();
    await user.delete();
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
      case 'user-not-found-for-reset':
        return 'No email/password UniGuide account was found for this email.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please use a stronger password.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'google-sign-in-not-configured':
        return 'Google sign-in is not fully configured for Android. Add this app SHA-1/SHA-256 in Firebase, download the new google-services.json, then rebuild.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked to another sign-in method.';
      case 'popup-closed-by-user':
        return 'Google sign-in was closed before it finished.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again, then try this security change.';
      case 'missing-email':
        return 'This account does not have an email address.';
      case 'provider-not-password':
        return 'This account signs in with Google. Change your password from your Google account settings.';
      case 'permission-denied':
        return 'The app cannot verify this email yet. Allow the password reset email lookup in Firestore rules.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  static Future<_StoredUserProfile?> _findUserProfileByEmail(
    String email,
  ) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return null;
    }

    final users = _firestore.collection('users');
    final emailLower = normalizedEmail.toLowerCase();

    final lowerSnapshot = await users
        .where('emailLower', isEqualTo: emailLower)
        .limit(1)
        .get();
    if (lowerSnapshot.docs.isNotEmpty) {
      return _StoredUserProfile.fromData(lowerSnapshot.docs.first.data());
    }

    final exactSnapshot = await users
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();
    if (exactSnapshot.docs.isNotEmpty) {
      return _StoredUserProfile.fromData(exactSnapshot.docs.first.data());
    }

    return null;
  }

  static FirebaseAuthException _googlePlatformException(
    PlatformException error,
  ) {
    final details = '${error.code} ${error.message} ${error.details}';
    if (details.contains('10:') ||
        details.contains('DEVELOPER_ERROR') ||
        details.contains('ApiException: 10')) {
      return FirebaseAuthException(
        code: 'google-sign-in-not-configured',
        message: 'Google sign-in is not configured for this Android app.',
      );
    }

    return FirebaseAuthException(
      code: error.code,
      message: error.message ?? 'Google sign-in failed.',
    );
  }

  static Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    const batchSize = 100;

    while (true) {
      final snapshot = await collection.limit(batchSize).get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  static Future<void> _saveUserProfile({
    required User? user,
    required Map<String, Object?> data,
  }) async {
    if (user == null) {
      return;
    }

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

class _StoredUserProfile {
  const _StoredUserProfile({
    required this.email,
    required this.provider,
  });

  final String email;
  final String provider;

  factory _StoredUserProfile.fromData(Map<String, dynamic> data) {
    return _StoredUserProfile(
      email: (data['email'] as String? ?? '').trim(),
      provider: data['provider'] as String? ?? '',
    );
  }
}
