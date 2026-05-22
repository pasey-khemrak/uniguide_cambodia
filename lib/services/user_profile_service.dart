import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class UserProfileService {
  UserProfileService._();

  static DocumentReference<Map<String, dynamic>>? _profileRef() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static Stream<UserProfile?> currentProfile() {
    final ref = _profileRef();
    final user = AuthService.currentUser;

    if (ref == null || user == null) {
      return Stream.value(null);
    }

    return ref.snapshots().map((snapshot) {
      final data = snapshot.data() ?? {};
      return UserProfile.fromMap({
        ...data,
        'uid': user.uid,
        'name': data['name'] ?? user.displayName ?? 'UniGuide Student',
        'email': data['email'] ?? user.email ?? '',
        'photoUrl': data['photoUrl'] ?? user.photoURL ?? '',
      });
    });
  }

  static Future<void> updateProfile(UserProfile profile) async {
    final ref = _profileRef();
    if (ref == null) {
      return;
    }

    await ref.set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).timeout(const Duration(seconds: 15));

    await AuthService.currentUser
        ?.updateDisplayName(profile.name)
        .timeout(const Duration(seconds: 10));
    if (profile.photoUrl.isNotEmpty) {
      await AuthService.currentUser
          ?.updatePhotoURL(profile.photoUrl)
          .timeout(const Duration(seconds: 10));
    }

    await NotificationService.profileUpdated();
  }

  static Future<String> uploadProfilePhoto(XFile image) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      return '';
    }

    final bytes = await image.readAsBytes();
    final ref = FirebaseStorage.instance
        .ref()
        .child('user-photos')
        .child('$uid-${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putData(bytes).timeout(const Duration(seconds: 20));
    return ref.getDownloadURL().timeout(const Duration(seconds: 10));
  }
}
