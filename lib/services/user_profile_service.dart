import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class UserProfileService {
  UserProfileService._();

  static const _cloudinaryCloudName =
      String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const _cloudinaryUploadPreset =
      String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');

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
      'uid': profile.uid,
      'name': profile.name,
      'email': profile.email,
      'emailLower': profile.email.trim().toLowerCase(),
      'phone': profile.phone,
      'location': profile.location,
      'status': profile.status,
      'bio': profile.bio,
      'photoUrl': profile.photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await ref.set({
      'interestedMajors': profile.interestedMajors,
      'education': profile.education.map((item) => item.toMap()).toList(),
      'emailLower': profile.email.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    unawaited(_syncFirebaseAuthProfile(profile));
    unawaited(_addProfileUpdatedNotification());
  }

  static Future<void> _syncFirebaseAuthProfile(UserProfile profile) async {
    try {
      await AuthService.currentUser
          ?.updateDisplayName(profile.name)
          .timeout(const Duration(seconds: 8));
      if (profile.photoUrl.isNotEmpty) {
        await AuthService.currentUser
            ?.updatePhotoURL(profile.photoUrl)
            .timeout(const Duration(seconds: 8));
      }
    } catch (_) {
      // Firestore is the source of truth for the in-app profile.
    }
  }

  static Future<void> _addProfileUpdatedNotification() async {
    try {
      await NotificationService.profileUpdated()
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Notifications should not prevent profile edits from saving.
    }
  }

  static Future<String> uploadProfilePhoto(XFile image) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      return '';
    }

    if (_cloudinaryCloudName.isEmpty || _cloudinaryUploadPreset.isEmpty) {
      throw const CloudinaryUploadException(
        'Cloudinary is not configured. Add CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET with --dart-define.',
      );
    }

    final bytes = await image.readAsBytes();
    final uri = Uri.https(
      'api.cloudinary.com',
      '/v1_1/$_cloudinaryCloudName/image/upload',
    );
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _cloudinaryUploadPreset
      ..fields['folder'] = 'uniguide/user-profiles'
      ..fields['public_id'] = '$uid-$timestamp'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: image.name.isEmpty ? '$uid-$timestamp.jpg' : image.name,
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Cloudinary upload failed with ${response.statusCode}.';
      try {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final error = data['error'];
        if (error is Map && error['message'] is String) {
          message = error['message'] as String;
        }
      } catch (_) {
        // Keep the status-code message when Cloudinary returns non-JSON text.
      }
      throw CloudinaryUploadException(message);
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = data['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw const CloudinaryUploadException(
        'Cloudinary did not return a secure image URL.',
      );
    }

    return secureUrl;
  }
}

class CloudinaryUploadException implements Exception {
  const CloudinaryUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
