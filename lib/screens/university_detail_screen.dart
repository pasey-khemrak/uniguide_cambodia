import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/university.dart';
import '../models/university_review.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../services/review_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/map_embed_view.dart';
import '../widgets/uniguide_widgets.dart';

class UniversityDetailScreen extends StatelessWidget {
  const UniversityDetailScreen({super.key, required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UniversityReview>>(
      stream: ReviewService.reviewsFor(university.id),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <UniversityReview>[];
        final averageRating = ReviewService.averageRating(reviews);

        return Scaffold(
          backgroundColor: pageColor,
          bottomNavigationBar: const UniGuideBottomNav(currentIndex: 1),
          body: SafeArea(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
              children: [
                const UniGuideHeader(
                    showBack: true, title: 'University Details'),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    UniversityImage(
                      url: university.imageUrl,
                      height: 170,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: RatingBadge(rating: averageRating),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD8DEE2)),
                      ),
                      child: const Icon(Icons.school_outlined,
                          color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${university.name} (${university.shortName})',
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 20,
                              height: 1.2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 15, color: Colors.black54),
                              Expanded(
                                child: Text(
                                  university.address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openAdmission(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Apply Now'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    StreamBuilder<bool>(
                      stream: FavoriteService.isSaved(university.id),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data ?? false;
                        return SizedBox(
                          width: 52,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () async {
                              await FavoriteService.toggleSaved(
                                  university, isSaved);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isSaved
                                          ? 'Removed from saved universities.'
                                          : 'Saved to your shortlist.',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: const BorderSide(color: primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Icon(isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useStackedInfo = constraints.maxWidth < 360;

                    if (useStackedInfo) {
                      return Column(
                        children: [
                          _InfoBox(
                            icon: Icons.payments_outlined,
                            label: 'Annual Tuition',
                            value: university.tuition,
                          ),
                          const SizedBox(height: 12),
                          _InfoBox(
                            icon: Icons.public,
                            label: 'Curriculum',
                            value: university.curriculum,
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.payments_outlined,
                            label: 'Annual Tuition',
                            value: university.tuition,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.public,
                            label: 'Curriculum',
                            value: university.curriculum,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const _SectionLabel('About'),
                const SizedBox(height: 10),
                _Panel(
                  child: Text(
                    university.about,
                    style: const TextStyle(height: 1.5, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Popular Majors'),
                const SizedBox(height: 10),
                Wrap(
                  children: university.majors
                      .map((major) => MajorChip(label: major))
                      .toList(),
                ),
                const SizedBox(height: 14),
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campus Location',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CampusMap(university: university),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              university.location,
                              softWrap: true,
                              style: const TextStyle(
                                color: Colors.black54,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: _SectionLabel('Student Reviews')),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Read All Reviews',
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                if (reviews.isEmpty)
                  const _Panel(
                    child: Text(
                      'No reviews yet. Be the first student to rate this university.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                else
                  ...reviews.map(
                    (review) => _ReviewCard(
                      universityId: university.id,
                      review: review,
                    ),
                  ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _showAddReviewDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Review'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddReviewDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => AddReviewDialog(universityId: university.id),
    );
  }

  Future<void> _openAdmission(BuildContext context) async {
    final url = university.admissionUrl.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admission link is not available yet.')),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admission link is invalid.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open admission page.')),
      );
    }
  }
}

class _CampusMap extends StatelessWidget {
  const _CampusMap({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    final embedUrl = _embedMapUrl();

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _openMap(context),
      child: Ink(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFD8DEE2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: MapEmbedView(
            url: embedUrl,
            fallback: Stack(
              fit: StackFit.expand,
              children: [
                _GoogleMapPlaceholder(university: university),
                Positioned(
                  left: 12,
                  top: 12,
                  right: 72,
                  child: _MapPlaceCard(university: university),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _MapRoundButton(
                    icon: Icons.open_in_full,
                    tooltip: 'Open map',
                    onTap: () => _openMap(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _embedMapUrl() {
    final savedEmbedUrl = university.mapEmbedUrl.trim();
    if (savedEmbedUrl.isNotEmpty) {
      final iframeSrc = RegExp(r'src="([^"]+)"').firstMatch(savedEmbedUrl);
      final embedUrl = iframeSrc?.group(1) ?? savedEmbedUrl;

      if (embedUrl.contains('/maps/embed')) {
        return embedUrl;
      }
    }

    final latitude = university.latitude;
    final longitude = university.longitude;
    if (latitude != null && longitude != null) {
      final coordinates = '$latitude,$longitude';
      return Uri.https('www.google.com', '/maps', {
        'q': coordinates,
        'll': coordinates,
        'output': 'embed',
        'hl': 'km',
        't': 'k',
        'z': '19',
      }).toString();
    }

    final query = [
      university.name,
      university.address,
      'Cambodia',
    ].where((item) => item.trim().isNotEmpty).join(', ');

    return Uri.https('www.google.com', '/maps', {
      'q': query,
      'output': 'embed',
      'hl': 'km',
      't': 'k',
      'z': '18',
    }).toString();
  }

  Future<void> _openMap(BuildContext context) async {
    final mapValue = university.mapUrl.trim().isEmpty
        ? university.address.trim()
        : university.mapUrl.trim();
    final uri = Uri.tryParse(mapValue)?.hasScheme == true
        ? Uri.parse(mapValue)
        : Uri.https(
            'www.google.com', '/maps/search/', {'api': '1', 'query': mapValue});

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }
}

class _GoogleMapPlaceholder extends StatelessWidget {
  const _GoogleMapPlaceholder({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GoogleMapPainter(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_pin, color: Color(0xFFEA4335), size: 46),
            Transform.translate(
              offset: const Offset(0, -7),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  university.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD93025),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF4F7F3),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.42),
      Paint()..color = const Color(0xFFE8F1E6),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
      Paint()..color = const Color(0xFFDDEED9),
    );

    final minorRoadBorder = Paint()
      ..color = const Color(0xFFD0D8DD)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final minorRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final mainRoadBorder = Paint()
      ..color = const Color(0xFFD5DDE3)
      ..strokeWidth = 19
      ..style = PaintingStyle.stroke;
    final mainRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roads = [
      [
        Offset(-20, size.height * 0.30),
        Offset(size.width + 20, size.height * 0.54)
      ],
      [
        Offset(-20, size.height * 0.82),
        Offset(size.width + 20, size.height * 0.12)
      ],
      [
        Offset(size.width * 0.20, -20),
        Offset(size.width * 0.62, size.height + 20)
      ],
      [
        Offset(size.width * 0.78, -20),
        Offset(size.width * 0.34, size.height + 20)
      ],
      [
        Offset(-20, size.height * 0.48),
        Offset(size.width + 20, size.height * 0.67)
      ],
    ];

    for (final road in roads) {
      canvas.drawLine(road[0], road[1], minorRoadBorder);
      canvas.drawLine(road[0], road[1], minorRoad);
    }

    final mainRoads = [
      [
        Offset(-20, size.height * 0.38),
        Offset(size.width + 20, size.height * 0.58)
      ],
      [
        Offset(size.width * 0.30, -20),
        Offset(size.width * 0.58, size.height + 20)
      ],
    ];

    for (final road in mainRoads) {
      canvas.drawLine(road[0], road[1], mainRoadBorder);
      canvas.drawLine(road[0], road[1], mainRoad);
    }

    _drawLabel(canvas, 'Northbridge St.',
        Offset(size.width * 0.06, size.height * 0.52));
    _drawLabel(canvas, 'St 110', Offset(size.width * 0.72, size.height * 0.28));
    _drawLabel(
        canvas, 'Ratanak Plaza', Offset(size.width * 0.60, size.height * 0.76));
    _drawPoi(canvas, Icons.local_hospital, 'Hospital',
        Offset(size.width * 0.18, size.height * 0.72));
    _drawPoi(canvas, Icons.shopping_bag, 'Market',
        Offset(size.width * 0.76, size.height * 0.42));
  }

  void _drawLabel(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  void _drawPoi(Canvas canvas, IconData icon, String label, Offset offset) {
    canvas.drawCircle(offset, 10, Paint()..color = Colors.white);
    canvas.drawCircle(offset, 8, Paint()..color = const Color(0xFF1A73E8));

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      offset - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );

    _drawLabel(canvas, label, offset + const Offset(12, -7));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPlaceCard extends StatelessWidget {
  const _MapPlaceCard({required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  university.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  university.address.isEmpty
                      ? university.location
                      : university.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.directions, color: Color(0xFF1A73E8), size: 22),
        ],
      ),
    );
  }
}

class _MapRoundButton extends StatelessWidget {
  const _MapRoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black54, size: 18),
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(
            value.trim().isEmpty ? 'Not available' : value,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8DEE2)),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.universityId,
    required this.review,
  });

  final String universityId;
  final UniversityReview review;

  @override
  Widget build(BuildContext context) {
    final canManage = AuthService.currentUser?.uid == review.userId;

    return StreamBuilder<UserProfile?>(
      stream: UserProfileService.profileFor(review.userId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final displayName = profile?.name.trim().isNotEmpty == true
            ? profile!.name.trim()
            : review.userName;
        final photoUrl = profile?.photoUrl.trim().isNotEmpty == true
            ? profile!.photoUrl.trim()
            : review.userPhotoUrl;

        return _Panel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewAvatar(name: displayName, photoUrl: photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (canManage)
                          PopupMenuButton<String>(
                            tooltip: 'Review actions',
                            onSelected: (value) {
                              if (value == 'edit') {
                                showDialog<void>(
                                  context: context,
                                  builder: (_) => AddReviewDialog(
                                    universityId: universityId,
                                    review: review,
                                  ),
                                );
                              }

                              if (value == 'delete') {
                                _confirmDelete(context);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit Review'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Review'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    StarRating(rating: review.rating, size: 15),
                    const SizedBox(height: 8),
                    Text(
                      '"${review.feedback}"',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete review?'),
          content: const Text('This review will be permanently removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await ReviewService.deleteReview(
        universityId: universityId,
        reviewId: review.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete review: $error')),
        );
      }
    }
  }
}

class _ReviewAvatar extends StatelessWidget {
  const _ReviewAvatar({
    required this.name,
    required this.photoUrl,
  });

  final String name;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'ST' : name.trim()[0].toUpperCase();

    if (photoUrl.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl.trim(),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialAvatar(initial: initial),
        ),
      );
    }

    return _InitialAvatar(initial: initial);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: accentColor.withValues(alpha: 0.55),
      child: Text(
        initial,
        style: const TextStyle(color: primaryColor),
      ),
    );
  }
}

class AddReviewDialog extends StatefulWidget {
  const AddReviewDialog({
    super.key,
    required this.universityId,
    this.review,
  });

  final String universityId;
  final UniversityReview? review;

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _feedbackController = TextEditingController();
  double _rating = 5;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final review = widget.review;
    if (review != null) {
      _rating = review.rating;
      _feedbackController.text = review.feedback;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your feedback.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final review = widget.review;
      if (review == null) {
        await ReviewService.addReview(
          universityId: widget.universityId,
          rating: _rating,
          feedback: _feedbackController.text,
        );
      } else {
        await ReviewService.updateReview(
          universityId: widget.universityId,
          reviewId: review.id,
          rating: _rating,
          feedback: _feedbackController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save review: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.review == null ? 'Rate this university' : 'Edit review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your rating'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final value = index + 1.0;
                return IconButton(
                  tooltip: '$value stars',
                  onPressed: () => setState(() => _rating = value),
                  icon: Icon(
                    _rating >= value ? Icons.star : Icons.star_border,
                    color: const Color(0xFFB38A00),
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your feedback...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(widget.review == null ? 'Submit' : 'Update'),
        ),
      ],
    );
  }
}
