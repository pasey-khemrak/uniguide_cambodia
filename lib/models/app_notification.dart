import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.universityId = '',
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final String universityId;

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['createdAt'];

    return AppNotification(
      id: id,
      title: map['title'] as String? ?? 'Notification',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'general',
      universityId: map['universityId'] as String? ?? '',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
