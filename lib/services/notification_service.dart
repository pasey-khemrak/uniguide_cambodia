import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/university.dart';
import 'auth_service.dart';

class NotificationService {
  NotificationService._();

  static CollectionReference<Map<String, dynamic>>? _notificationsRef([
    String? uid,
  ]) {
    final userId = uid ?? AuthService.currentUser?.uid;
    if (userId == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  static Stream<List<AppNotification>> notifications() {
    final ref = _notificationsRef();
    if (ref == null) {
      return Stream.value(const []);
    }

    return ref.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return AppNotification.fromMap(doc.id, doc.data());
        }).toList();
      },
    );
  }

  static Stream<List<AppNotification>> newUniversityNotifications() {
    return FirebaseFirestore.instance
        .collection('universities')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final university = University.fromMap(data, id: doc.id);
        return AppNotification.fromMap('university-${doc.id}', {
          'title': 'New university added',
          'message': '${university.name} is now available in UniGuide Cambodia.',
          'type': 'university',
          'universityId': university.id,
          'createdAt': data['createdAt'],
        });
      }).toList();
    }).handleError((_) => const <AppNotification>[]);
  }

  static Future<void> profileUpdated() {
    return addForCurrentUser(
      title: 'Profile updated',
      message: 'Your profile information was updated successfully.',
      type: 'profile',
    );
  }

  static Future<void> reviewAdded(String universityId) async {
    await addForCurrentUser(
      title: 'Review added',
      message: 'Your review was posted successfully.',
      type: 'review',
      universityId: universityId,
    );
  }

  static Future<void> universityAdded(University university) {
    return addForCurrentUser(
      title: 'New university added',
      message: '${university.name} is now available in UniGuide Cambodia.',
      type: 'university',
      universityId: university.id,
    );
  }

  static Future<void> savedUniversityReviewed({
    required String universityId,
    required String universityName,
    required String reviewerId,
  }) async {
    final favorites = await FirebaseFirestore.instance
        .collectionGroup('favorites')
        .where('id', isEqualTo: universityId)
        .get();

    for (final favorite in favorites.docs) {
      final userDoc = favorite.reference.parent.parent;
      final uid = userDoc?.id;

      if (uid == null || uid == reviewerId) {
        continue;
      }

      await addForUser(
        uid: uid,
        title: 'New review on saved university',
        message: '$universityName received a new student review.',
        type: 'saved_review',
        universityId: universityId,
      );
    }
  }

  static Future<void> addForCurrentUser({
    required String title,
    required String message,
    required String type,
    String universityId = '',
  }) async {
    final ref = _notificationsRef();
    if (ref == null) {
      return;
    }

    await ref.add({
      'title': title,
      'message': message,
      'type': type,
      'universityId': universityId,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  static Future<void> addForUser({
    required String uid,
    required String title,
    required String message,
    required String type,
    String universityId = '',
  }) async {
    final ref = _notificationsRef(uid);
    if (ref == null) {
      return;
    }

    await ref.add({
      'title': title,
      'message': message,
      'type': type,
      'universityId': universityId,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}
