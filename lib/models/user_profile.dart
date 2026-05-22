class UserEducation {
  const UserEducation({
    required this.school,
    required this.program,
  });

  final String school;
  final String program;

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'program': program,
    };
  }

  factory UserEducation.fromMap(Map<String, dynamic> map) {
    return UserEducation(
      school: map['school'] as String? ?? '',
      program: map['program'] as String? ?? '',
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.status,
    required this.bio,
    required this.photoUrl,
    required this.interestedMajors,
    required this.education,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String status;
  final String bio;
  final String photoUrl;
  final List<String> interestedMajors;
  final List<UserEducation> education;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'status': status,
      'bio': bio,
      'photoUrl': photoUrl,
      'interestedMajors': interestedMajors,
      'education': education.map((item) => item.toMap()).toList(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      location: map['location'] as String? ?? '',
      status: map['status'] as String? ?? 'Bachelor Degree',
      bio: map['bio'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      interestedMajors:
          List<String>.from(map['interestedMajors'] as List? ?? const []),
      education: (map['education'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => UserEducation.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? status,
    String? bio,
    String? photoUrl,
    List<String>? interestedMajors,
    List<UserEducation>? education,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      interestedMajors: interestedMajors ?? this.interestedMajors,
      education: education ?? this.education,
    );
  }
}
