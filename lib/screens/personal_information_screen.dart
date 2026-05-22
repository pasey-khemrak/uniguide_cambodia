import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../widgets/uniguide_widgets.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            const UniGuideHeader(showBack: true, title: 'Personal Information'),
            Expanded(
              child: StreamBuilder<UserProfile?>(
                stream: UserProfileService.currentProfile(),
                builder: (context, snapshot) {
                  final profile = snapshot.data;

                  if (profile == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      _InfoPanel(
                        children: [
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: 'Full Name',
                            value: profile.name,
                          ),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: profile.email,
                          ),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: profile.phone.isEmpty
                                ? 'Not added yet'
                                : '+855 ${profile.phone}',
                          ),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: profile.location.isEmpty
                                ? 'Not added yet'
                                : profile.location,
                          ),
                          _InfoRow(
                            icon: Icons.school_outlined,
                            label: 'Current Status',
                            value: profile.status,
                          ),
                          _InfoRow(
                            icon: Icons.notes_outlined,
                            label: 'Bio',
                            value: profile.bio.isEmpty
                                ? 'Not added yet'
                                : profile.bio,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoPanel(
                        title: 'Interested Majors',
                        children: [
                          if (profile.interestedMajors.isEmpty)
                            const Text(
                              'No interested majors added yet.',
                              style: TextStyle(color: Colors.black54),
                            )
                          else
                            Wrap(
                              children: profile.interestedMajors.map((major) {
                                return MajorChip(label: major);
                              }).toList(),
                            ),
                        ],
                      ),
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

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.children,
    this.title,
  });

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8DEE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.35,
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
