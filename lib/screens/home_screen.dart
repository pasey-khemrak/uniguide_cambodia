import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/university.dart';
import '../services/auth_service.dart';
import '../services/university_service.dart';
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
                    title: 'Top IT & Technology Majors',
                    action: 'Explore',
                    onAction: () => Navigator.pushNamed(
                      context,
                      '/search',
                      arguments: 'Information Technology',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TopMajorsList(
                    majors: _technologyMajors,
                    onMajorTap: (major) => _openMajorSource(context, major),
                  ),
                  const SizedBox(height: 34),
                  StreamBuilder<List<University>>(
                    stream: UniversityService.universities(),
                    builder: (context, snapshot) {
                      final universities = snapshot.data ?? const <University>[];

                      if (snapshot.connectionState == ConnectionState.waiting &&
                          universities.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (universities.isEmpty) {
                        return const _EmptyUniversitiesMessage();
                      }

                      final featured = universities.take(3).toList();
                      final recommended = universities.skip(2).take(2).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            title: 'Featured Universities',
                            action: 'See all',
                            onAction: () =>
                                Navigator.pushNamed(context, '/search'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 470,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: featured.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final university = featured[index];
                                return _FeaturedCard(
                                  university: university,
                                  onTap: () => _openDetails(context, university),
                                );
                              },
                            ),
                          ),
                          if (recommended.isNotEmpty) ...[
                            const SizedBox(height: 34),
                            const _SectionTitle(title: 'Recommended for You'),
                            const SizedBox(height: 16),
                            ...recommended.map((university) {
                              return _RecommendationCard(
                                university: university,
                                onTap: () => _openDetails(context, university),
                              );
                            }),
                          ],
                        ],
                      );
                    },
                  ),
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

  Future<void> _openMajorSource(BuildContext context, _PopularMajor major) async {
    final uri = Uri.parse(major.sourceUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      Navigator.pushNamed(context, '/search', arguments: major.name);
    }
  }
}

class _PopularMajor {
  const _PopularMajor({
    required this.name,
    required this.sourceName,
    required this.sourceUrl,
  });

  final String name;
  final String sourceName;
  final String sourceUrl;
}

const _technologyMajors = [
  _PopularMajor(
    name: 'Computer Science',
    sourceName: 'BLS',
    sourceUrl:
        'https://www.bls.gov/ooh/field-of-degree/computer-and-information/computer-and-information-technology-field-of-degree.htm',
  ),
  _PopularMajor(
    name: 'Information Technology',
    sourceName: 'BLS',
    sourceUrl:
        'https://www.bls.gov/ooh/field-of-degree/computer-and-information/computer-and-information-technology-field-of-degree.htm',
  ),
  _PopularMajor(
    name: 'Software Engineering',
    sourceName: 'Penn State',
    sourceUrl:
        'https://www.psu.edu/academics/undergraduate/majors/pathways/computer-science-information-systems-careers',
  ),
  _PopularMajor(
    name: 'Data Science',
    sourceName: 'Penn State',
    sourceUrl:
        'https://www.psu.edu/academics/undergraduate/majors/pathways/information-technology-data-science-careers',
  ),
  _PopularMajor(
    name: 'Cybersecurity',
    sourceName: 'Penn State',
    sourceUrl:
        'https://www.psu.edu/academics/undergraduate/majors/pathways/information-technology-data-science-careers',
  ),
  _PopularMajor(
    name: 'Artificial Intelligence',
    sourceName: 'Penn State',
    sourceUrl:
        'https://www.psu.edu/academics/undergraduate/majors/pathways/information-technology-data-science-careers',
  ),
  _PopularMajor(
    name: 'Computer Engineering',
    sourceName: 'BLS',
    sourceUrl:
        'https://www.bls.gov/ooh/field-of-degree/computer-and-information/computer-and-information-technology-field-of-degree.htm',
  ),
  _PopularMajor(
    name: 'Information Systems',
    sourceName: 'Penn State',
    sourceUrl:
        'https://www.psu.edu/academics/undergraduate/majors/pathways/computer-science-information-systems-careers',
  ),
];

class _TopMajorsList extends StatelessWidget {
  const _TopMajorsList({
    required this.majors,
    required this.onMajorTap,
  });

  final List<_PopularMajor> majors;
  final ValueChanged<_PopularMajor> onMajorTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: majors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final major = majors[index];

          return _TopMajorCard(
            major: major,
            onTap: () => onMajorTap(major),
          );
        },
      ),
    );
  }
}

class _TopMajorCard extends StatelessWidget {
  const _TopMajorCard({
    required this.major,
    required this.onTap,
  });

  final _PopularMajor major;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD8DEE2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: primaryColor,
                    size: 19,
                  ),
                ),
                const Spacer(),
                Text(
                  major.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.open_in_new,
                      size: 13,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Source: ${major.sourceName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyUniversitiesMessage extends StatelessWidget {
  const _EmptyUniversitiesMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          'No universities found in Firestore yet.',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
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
                    child: ReviewRatingBadge(universityId: university.id),
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
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.black54,
                        ),
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
                  ReviewRatingInline(universityId: university.id),
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
