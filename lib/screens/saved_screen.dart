import 'package:flutter/material.dart';

import '../models/university.dart';
import '../services/favorite_service.dart';
import '../widgets/uniguide_widgets.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            const UniGuideHeader(),
            Expanded(
              child: StreamBuilder<List<University>>(
                stream: FavoriteService.savedUniversities(),
                builder: (context, snapshot) {
                  final saved = snapshot.data ?? const <University>[];

                  return ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    children: [
                      const Text(
                        'Shortlist',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Review and compare the universities you've saved for your academic journey.",
                        style: TextStyle(color: Colors.black54, fontSize: 18, height: 1.45),
                      ),
                      const SizedBox(height: 28),
                      if (saved.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 90),
                          child: Center(
                            child: Text(
                              'No saved universities yet.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        )
                      else
                        ...saved.map((university) {
                          return _SavedUniversityCard(university: university);
                        }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedUniversityCard extends StatelessWidget {
  const _SavedUniversityCard({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 22),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFD8DEE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              UniversityImage(url: university.imageUrl, height: 240),
              Positioned(
                top: 18,
                right: 18,
                child: RatingBadge(rating: university.rating),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        university.name,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 26,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () => FavoriteService.remove(university.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.black54),
                    Expanded(
                      child: Text(
                        university.address,
                        style: const TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  children: university.majors.take(3).map((major) {
                    return MajorChip(label: major);
                  }).toList(),
                ),
                const Divider(height: 28),
                Center(
                  child: SizedBox(
                    width: 240,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/university-details',
                        arguments: university,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View Details', style: TextStyle(fontSize: 17)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
