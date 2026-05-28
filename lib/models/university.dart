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
    this.mapEmbedUrl = '',
    this.admissionUrl = '',
    this.latitude,
    this.longitude,
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
  final String mapEmbedUrl;
  final String admissionUrl;
  final double? latitude;
  final double? longitude;

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
      'mapEmbedUrl': mapEmbedUrl,
      'admissionUrl': admissionUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory University.fromMap(Map<String, dynamic> map, {String? id}) {
    String stringValue(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }

      return '';
    }

    double? doubleValue(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is num) {
          return value.toDouble();
        }

        if (value is String) {
          return double.tryParse(value.trim());
        }
      }

      return null;
    }

    final address = stringValue(['address', 'Address']);
    final location = stringValue(['location', 'Location']);
    final visibleLocation = location.startsWith('http') ? address : location;

    return University(
      id: id ?? stringValue(['id']),
      name: stringValue(['name', 'Name']),
      shortName: stringValue(['shortName', 'ShortName', 'short_name']),
      location: visibleLocation,
      address: address,
      rating: (map['rating'] as num?)?.toDouble() ??
          (map['Rating'] as num?)?.toDouble() ??
          0,
      tuition: stringValue(['tuition', 'Tuition']),
      curriculum: stringValue(['curriculum', 'Curriculum']),
      type: stringValue(['type', 'Type']),
      imageUrl: stringValue(['imageUrl', 'ImageUrl', 'image_url']),
      mapImageUrl: stringValue(['mapImageUrl', 'MapImageUrl', 'map_image_url']),
      majors: List<String>.from(map['majors'] as List? ?? const []),
      about: stringValue(['about', 'About']),
      mapUrl: stringValue([
        'mapUrl',
        'MapUrl',
        'googleMapUrl',
        'GoogleMapUrl',
        'campusLocation',
        'CampusLocation',
        'Location',
      ]),
      mapEmbedUrl: stringValue([
        'mapEmbedUrl',
        'MapEmbedUrl',
        'googleMapEmbedUrl',
        'GoogleMapEmbedUrl',
        'embedMapUrl',
        'EmbedMapUrl',
      ]),
      admissionUrl: stringValue([
        'admissionUrl',
        'AdmissionUrl',
        'applyUrl',
        'ApplyUrl',
        'admissionsUrl',
        'AdmissionsUrl',
      ]),
      latitude: doubleValue(['latitude', 'Latitude', 'lat', 'Lat']),
      longitude: doubleValue(['longitude', 'Longitude', 'lng', 'Lng', 'long']),
    );
  }
}
