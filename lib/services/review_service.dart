import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/university_review.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class ReviewService {
  ReviewService._();

  static CollectionReference<Map<String, dynamic>> _reviewsRef(
    String universityId,
  ) {
    return FirebaseFirestore.instance
        .collection('universities')
        .doc(universityId)
        .collection('reviews');
  }

  static Stream<List<UniversityReview>> reviewsFor(String universityId) {
    return _reviewsRef(universityId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UniversityReview.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  static double averageRating(List<UniversityReview> reviews) {
    if (reviews.isEmpty) {
      return 0;
    }

    final total = reviews.fold<double>(
      0,
      (runningTotal, review) => runningTotal + review.rating,
    );

    return total / reviews.length;
  }

  static Future<void> addReview({
    required String universityId,
    required double rating,
    required String feedback,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) {
      return;
    }

    final profile = await _currentReviewerProfile();
    final userName = profile?.name.trim().isNotEmpty == true
        ? profile!.name.trim()
        : user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'Student';

    await _reviewsRef(universityId).add({
      'userId': user.uid,
      'userName': userName,
      'userPhotoUrl': profile?.photoUrl.trim().isNotEmpty == true
          ? profile!.photoUrl.trim()
          : user.photoURL ?? '',
      'rating': rating,
      'feedback': feedback.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await NotificationService.reviewAdded(universityId);
    try {
      await NotificationService.savedUniversityReviewed(
        universityId: universityId,
        universityName: await _universityName(universityId),
        reviewerId: user.uid,
      );
    } on FirebaseException catch (error) {
      if (error.code != 'failed-precondition') {
        rethrow;
      }
    }
  }

  static Future<void> updateReview({
    required String universityId,
    required String reviewId,
    required double rating,
    required String feedback,
  }) async {
    final profile = await _currentReviewerProfile();

    await _reviewsRef(universityId).doc(reviewId).update({
      if (profile != null) ...{
        'userName':
            profile.name.trim().isEmpty ? 'Student' : profile.name.trim(),
        'userPhotoUrl': profile.photoUrl.trim(),
      },
      'rating': rating,
      'feedback': feedback.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteReview({
    required String universityId,
    required String reviewId,
  }) {
    return _reviewsRef(universityId).doc(reviewId).delete();
  }

  static Future<String> _universityName(String universityId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('universities')
        .doc(universityId)
        .get();

    return snapshot.data()?['name'] as String? ?? 'A saved university';
  }

  static Future<UserProfile?> _currentReviewerProfile() async {
    final user = AuthService.currentUser;
    if (user == null) {
      return null;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    return UserProfile.fromMap({
      ...data,
      'uid': user.uid,
      'name': data['name'] ?? user.displayName ?? 'Student',
      'email': data['email'] ?? user.email ?? '',
      'photoUrl': data['photoUrl'] ?? user.photoURL ?? '',
    });
  }
}
