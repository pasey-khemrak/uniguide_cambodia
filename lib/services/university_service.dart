import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/university.dart';

class UniversityService {
  UniversityService._();

  static CollectionReference<Map<String, dynamic>> get _universitiesRef {
    return FirebaseFirestore.instance.collection('universities');
  }

  static Stream<List<University>> universities() {
    return _universitiesRef
        .snapshots()
        .map((snapshot) {
          final universities = snapshot.docs.map((doc) {
            return University.fromMap(doc.data(), id: doc.id);
          }).toList();

          universities.sort((a, b) => a.name.compareTo(b.name));
          return universities;
        })
        .handleError((_) => const <University>[]);
  }

  static List<University> filter(List<University> source, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return source;
    }

    final scored = source.where((university) {
      final haystack = [
        university.name,
        university.shortName,
        university.location,
        university.address,
        university.type,
        ...university.majors,
      ].join(' ').toLowerCase();

      return haystack.contains(normalized);
    }).toList();

    scored.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final aStarts = aName.startsWith(normalized);
      final bStarts = bName.startsWith(normalized);

      if (aStarts == bStarts) {
        return aName.compareTo(bName);
      }

      return aStarts ? -1 : 1;
    });

    return scored;
  }
}
