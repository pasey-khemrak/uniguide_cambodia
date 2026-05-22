import '../models/university.dart';

const universitiesFallback = [
  University(
    id: 'aupp',
    name: 'American University of Phnom Penh',
    shortName: 'AUPP',
    location: 'Khan Russey Keo, Phnom Penh',
    address: 'Khan Russey Keo, Phnom Penh, Cambodia',
    rating: 4.8,
    tuition: r'$6,000 - $9,000',
    curriculum: 'US Global',
    type: 'Private',
    imageUrl:
        'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=80',
    mapImageUrl:
        'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=900&q=80',
    majors: ['Computer Science', 'Business Administration', 'Law', 'Communications'],
    about:
        'The American University of Phnom Penh is a leading higher education institution in Cambodia, offering programs with a global academic focus. Students benefit from modern facilities, international-style learning, and a curriculum focused on critical thinking, leadership, and ethical professional practice.',
  ),
  University(
    id: 'rupp',
    name: 'Royal University of Phnom Penh',
    shortName: 'RUPP',
    location: 'Khan Toul Kork, Phnom Penh',
    address: 'Russian Federation Blvd, Phnom Penh',
    rating: 4.5,
    tuition: r'$400 - $800',
    curriculum: 'Cambodian',
    type: 'Public',
    imageUrl:
        'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=1200&q=80',
    mapImageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
    majors: ['IT Engineering', 'Mathematics', 'Khmer Literature', 'Education'],
    about:
        'Royal University of Phnom Penh is one of Cambodias oldest and most recognized public universities. It offers a wide range of undergraduate and graduate programs across science, humanities, engineering, education, and social sciences.',
  ),
  University(
    id: 'puc',
    name: 'Pannasastra University of Cambodia',
    shortName: 'PUC',
    location: 'Khan Chamkarmon, Phnom Penh',
    address: 'Khan Chamkarmon, Phnom Penh',
    rating: 4.3,
    tuition: r'$1,200 - $2,500',
    curriculum: 'International',
    type: 'Private',
    imageUrl:
        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=80',
    mapImageUrl:
        'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=900&q=80',
    majors: ['International Relations', 'TESOL', 'Law', 'Business'],
    about:
        'Pannasastra University of Cambodia provides programs with an international orientation and English-language learning environment. It is known for social sciences, law, education, and business-related programs.',
  ),
  University(
    id: 'num',
    name: 'National University of Management',
    shortName: 'NUM',
    location: 'Phnom Penh',
    address: 'Phnom Penh, Cambodia',
    rating: 4.5,
    tuition: r'$500 - $1,500',
    curriculum: 'Cambodian',
    type: 'Public',
    imageUrl:
        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
    mapImageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
    majors: ['Economics', 'Business', 'Accounting', 'Management'],
    about:
        'National University of Management focuses on business, economics, accounting, finance, and management education for students preparing for careers in Cambodias growing economy.',
  ),
  University(
    id: 'paragon',
    name: 'Paragon International University',
    shortName: 'Paragon',
    location: 'Toul Kork, Phnom Penh',
    address: 'Toul Kork, Phnom Penh',
    rating: 4.6,
    tuition: r'$2,000 - $4,500',
    curriculum: 'International',
    type: 'Private',
    imageUrl:
        'https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=1200&q=80',
    mapImageUrl:
        'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=900&q=80',
    majors: ['Business', 'IT & CS', 'International Relations'],
    about:
        'Paragon International University offers internationally focused programs in technology, business, engineering, and social sciences, with an emphasis on practical skills and global readiness.',
  ),
];

const universities = universitiesFallback;

List<University> searchUniversities(String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return universitiesFallback;
  }

  return universitiesFallback.where((university) {
    final text = [
      university.name,
      university.shortName,
      university.location,
      university.type,
      ...university.majors,
    ].join(' ').toLowerCase();
    return text.contains(normalized);
  }).toList();
}
