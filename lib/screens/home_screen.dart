import 'package:flutter/material.dart';

import '../data/university_data.dart';
import '../models/university.dart';
import '../services/auth_service.dart';
import '../widgets/uniguide_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final displayName = user?.displayName?.trim();
    final firstName = displayName == null || displayName.isEmpty
        ? 'Student'
        : displayName.split(' ').first;

    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, '/search'),
        child: const Icon(Icons.edit_outlined),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(child: UniGuideHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      color: Color(0xFF087C70),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find your future, $firstName',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SearchLauncher(
                    onTap: () => Navigator.pushNamed(context, '/search'),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryButton(
                          label: 'Popular Universities',
                          icon: Icons.school_outlined,
                          selected: true,
                          onTap: () => Navigator.pushNamed(context, '/search'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _CategoryButton(
                          label: 'Top Majors',
                          icon: Icons.menu_book_outlined,
                          selected: false,
                          onTap: () => Navigator.pushNamed(context, '/search'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  _SectionTitle(
                    title: 'Featured Universities',
                    action: 'See all',
                    onAction: () => Navigator.pushNamed(context, '/search'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 470,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: universities.take(3).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final university = universities[index];
                        return _FeaturedCard(
                          university: university,
                          onTap: () => _openDetails(context, university),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 34),
                  const _SectionTitle(title: 'Recommended for You'),
                  const SizedBox(height: 16),
                  ...universities.skip(2).take(2).map((university) {
                    return _RecommendationCard(
                      university: university,
                      onTap: () => _openDetails(context, university),
                    );
                  }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, University university) {
    Navigator.pushNamed(context, '/university-details', arguments: university);
  }
}

class _SearchLauncher extends StatelessWidget {
  const _SearchLauncher({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.black45, size: 28),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Search universities, majors, etc.',
                style: TextStyle(color: Colors.black54, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? accentColor : const Color(0xFFE8EAEC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? primaryColor : Colors.black54),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? primaryColor : Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              '$action ->',
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.university, required this.onTap});

  final University university;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 336,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE2E6EA)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  UniversityImage(url: university.imageUrl, height: 228),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: RatingBadge(rating: university.rating),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      university.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
                        Expanded(
                          child: Text(
                            university.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      children: university.majors.take(2).map((major) {
                        return MajorChip(label: major);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.university, required this.onTap});

  final University university;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            university.imageUrl,
            width: 116,
            height: 116,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 116,
              height: 116,
              color: const Color(0xFFE6EEF1),
              child: const Icon(Icons.account_balance, color: primaryColor),
            ),
          ),
        ),
        title: Text(
          university.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                university.about,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StarRating(rating: university.rating, size: 14),
                  Text(' ${university.rating.toStringAsFixed(1)}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('|'),
                  ),
                  Expanded(
                    child: Text(
                      university.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
