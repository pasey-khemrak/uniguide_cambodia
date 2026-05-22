import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class SearchHistoryService {
  SearchHistoryService._();

  static CollectionReference<Map<String, dynamic>>? _historyRef() {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('searchHistory');
  }

  static Future<void> record(String query) async {
    final normalized = query.trim();
    final ref = _historyRef();
    if (ref == null || normalized.isEmpty) {
      return;
    }

    await ref.doc(normalized.toLowerCase()).set({
      'query': normalized,
      'searchedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> clear() async {
    final ref = _historyRef();
    if (ref == null) {
      return;
    }

    while (true) {
      final snapshot = await ref.limit(100).get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
