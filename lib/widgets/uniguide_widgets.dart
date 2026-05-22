import 'package:flutter/material.dart';

import '../models/university.dart';

const primaryColor = Color(0xFF07586A);
const accentColor = Color(0xFF7FE7DF);
const pageColor = Color(0xFFF6F8FA);

class UniGuideHeader extends StatelessWidget {
  const UniGuideHeader({
    super.key,
    this.showBack = false,
    this.title = 'UniGuide Cambodia',
  });

  final bool showBack;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => Navigator.pop(context),
            )
          else
            const Icon(Icons.school_outlined, color: primaryColor, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none, color: primaryColor),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
    );
  }
}

class UniGuideBottomNav extends StatelessWidget {
  const UniGuideBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      indicatorColor: accentColor,
      backgroundColor: Colors.white,
      height: 72,
      onDestinationSelected: (index) {
        final routes = ['/home', '/search', '/saved', '/profile'];
        if (index == currentIndex) {
          return;
        }
        Navigator.pushReplacementNamed(context, routes[index]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(icon: Icon(Icons.bookmark_border), label: 'Saved'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD986),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StarRating(rating: rating, size: 13),
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
  });

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final icon = rating >= starValue
            ? Icons.star
            : rating >= starValue - 0.5
                ? Icons.star_half
                : Icons.star_border;

        return Icon(
          icon,
          color: const Color(0xFFB38A00),
          size: size,
        );
      }),
    );
  }
}

class MajorChip extends StatelessWidget {
  const MajorChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class UniversityImage extends StatelessWidget {
  const UniversityImage({
    super.key,
    required this.url,
    this.height = 180,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(8)),
  });

  final String url;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          color: const Color(0xFFE6EEF1),
          child: const Icon(Icons.account_balance, color: primaryColor, size: 42),
        ),
      ),
    );
  }
}

class UniversityListCard extends StatelessWidget {
  const UniversityListCard({
    super.key,
    required this.university,
    required this.onDetails,
  });

  final University university;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE0E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              UniversityImage(url: university.imageUrl, height: 178),
              Positioned(
                top: 12,
                right: 12,
                child: RatingBadge(rating: university.rating),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
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
                          fontSize: 18,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD8DEE2)),
                      ),
                      child: const Icon(Icons.account_balance, color: primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 17, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        university.location,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  children: university.majors.take(3).map((major) {
                    return MajorChip(label: major);
                  }).toList(),
                ),
                const Divider(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Annual Tuition', style: TextStyle(color: Colors.black54)),
                          Text(
                            university.tuition,
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: onDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
