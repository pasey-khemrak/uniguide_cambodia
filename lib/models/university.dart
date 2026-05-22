class University {
  const University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.location,
    required this.address,
    required this.rating,
    required this.tuition,
    required this.curriculum,
    required this.type,
    required this.imageUrl,
    required this.mapImageUrl,
    required this.majors,
    required this.about,
    this.mapUrl = '',
    this.admissionUrl = '',
  });

  final String id;
  final String name;
  final String shortName;
  final String location;
  final String address;
  final double rating;
  final String tuition;
  final String curriculum;
  final String type;
  final String imageUrl;
  final String mapImageUrl;
  final List<String> majors;
  final String about;
  final String mapUrl;
  final String admissionUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'location': location,
      'address': address,
      'rating': rating,
      'tuition': tuition,
      'curriculum': curriculum,
      'type': type,
      'imageUrl': imageUrl,
      'mapImageUrl': mapImageUrl,
      'majors': majors,
      'about': about,
      'mapUrl': mapUrl,
      'admissionUrl': admissionUrl,
    };
  }

  factory University.fromMap(Map<String, dynamic> map, {String? id}) {
    return University(
      id: id ?? (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      shortName: map['shortName'] as String? ?? '',
      location: map['location'] as String? ?? '',
      address: map['address'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      tuition: map['tuition'] as String? ?? '',
      curriculum: map['curriculum'] as String? ?? '',
      type: map['type'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      mapImageUrl: map['mapImageUrl'] as String? ?? '',
      majors: List<String>.from(map['majors'] as List? ?? const []),
      about: map['about'] as String? ?? '',
      mapUrl: map['mapUrl'] as String? ??
          map['googleMapUrl'] as String? ??
          map['campusLocation'] as String? ??
          '',
      admissionUrl: map['admissionUrl'] as String? ??
          map['applyUrl'] as String? ??
          map['admissionsUrl'] as String? ??
          '',
    );
  }
}
