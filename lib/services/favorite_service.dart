import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/university.dart';
import 'auth_service.dart';

class FavoriteService {
  FavoriteService._();

  static CollectionReference<Map<String, dynamic>>? _favoritesRef() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');
  }

  static Stream<bool> isSaved(String universityId) {
    final ref = _favoritesRef();
    if (ref == null) {
      return Stream.value(false);
    }

    return ref.doc(universityId).snapshots().map((snapshot) => snapshot.exists);
  }

  static Stream<List<University>> savedUniversities() {
    final ref = _favoritesRef();
    if (ref == null) {
      return Stream.value(const []);
    }

    return ref.orderBy('savedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => University.fromMap(doc.data())).toList();
    });
  }

  static Future<void> toggleSaved(University university, bool isSaved) async {
    final ref = _favoritesRef();
    if (ref == null) {
      return;
    }

    if (isSaved) {
      await ref.doc(university.id).delete();
      return;
    }

    await ref.doc(university.id).set({
      ...university.toMap(),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> remove(String universityId) async {
    final ref = _favoritesRef();
    if (ref == null) {
      return;
    }
    await ref.doc(universityId).delete();
  }
}
