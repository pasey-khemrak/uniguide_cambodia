class UniversityReview {
  const UniversityReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.rating,
    required this.feedback,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final double rating;
  final String feedback;
  final DateTime? createdAt;

  factory UniversityReview.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['createdAt'];

    return UniversityReview(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Student',
      userPhotoUrl: map['userPhotoUrl'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      feedback: map['feedback'] as String? ?? '',
      createdAt: timestamp == null ? null : timestamp.toDate() as DateTime,
    );
  }
}
