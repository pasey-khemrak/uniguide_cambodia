import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import '../widgets/uniguide_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            const UniGuideHeader(),
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
                    padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton.small(
                          heroTag: 'edit-profile',
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/edit-profile',
                            arguments: profile,
                          ),
                          child: const Icon(Icons.edit),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _ProfileHero(profile: profile),
                      const SizedBox(height: 48),
                      _EducationSection(profile: profile),
                      const SizedBox(height: 28),
                      _SettingsSection(
                        onEdit: () => Navigator.pushNamed(
                          context,
                          '/edit-profile',
                          arguments: profile,
                        ),
                        onPersonalInfo: () => Navigator.pushNamed(
                          context,
                          '/personal-information',
                        ),
                        onNotifications: () => Navigator.pushNamed(
                          context,
                          '/notifications',
                        ),
                        onPrivacySecurity: () => Navigator.pushNamed(
                          context,
                          '/privacy-security',
                        ),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _ProfilePhoto(url: profile.photoUrl, size: 190),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          profile.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        if (profile.location.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.black54,
                size: 28,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  profile.location,
                  style: const TextStyle(color: Colors.black54, fontSize: 22),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EducationSection extends StatelessWidget {
  const _EducationSection({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return _ProfilePanel(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_outlined, color: primaryColor, size: 34),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Education',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/edit-profile',
                  arguments: profile,
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(color: primaryColor, fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (profile.education.isEmpty)
            const _EducationTile(
              icon: Icons.school_outlined,
              school: 'No education added yet',
              program: 'Tap edit to update your profile',
            )
          else
            ...profile.education.map((item) {
              return _EducationTile(
                icon: Icons.account_balance,
                school: item.school,
                program: item.program,
              );
            }),
        ],
      ),
    );
  }
}

class _EducationTile extends StatelessWidget {
  const _EducationTile({
    required this.icon,
    required this.school,
    required this.program,
  });

  final IconData icon;
  final String school;
  final String program;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D0D6)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 34),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  program,
                  style: const TextStyle(color: Colors.black54, fontSize: 19),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.onEdit,
    required this.onPersonalInfo,
    required this.onNotifications,
    required this.onPrivacySecurity,
  });

  final VoidCallback onEdit;
  final VoidCallback onPersonalInfo;
  final VoidCallback onNotifications;
  final VoidCallback onPrivacySecurity;

  @override
  Widget build(BuildContext context) {
    return _ProfilePanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Account Settings',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.person_outline,
            label: 'Personal Information',
            onTap: onPersonalInfo,
          ),
          _SettingsTile(
            icon: Icons.notifications_none,
            label: 'Notifications',
            onTap: onNotifications,
          ),
          _SettingsTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: onEdit,
          ),
          _SettingsTile(
            icon: Icons.shield_outlined,
            label: 'Privacy & Security',
            onTap: onPrivacySecurity,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            leading: const Icon(Icons.logout, color: Colors.red, size: 32),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontSize: 24),
            ),
            onTap: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      leading: Icon(icon, color: Colors.black54, size: 32),
      title: Text(label, style: const TextStyle(fontSize: 24)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54, size: 34),
      shape: const Border(top: BorderSide(color: Color(0xFFC8D0D6))),
      onTap: onTap,
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.child,
    this.padding = const EdgeInsets.all(28),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8D0D6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: const Color(0xFFE6EEF1),
        child: const Icon(Icons.person_outline, color: primaryColor, size: 64),
      );
    }

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: const Color(0xFFE6EEF1),
        child: const Icon(Icons.person_outline, color: primaryColor, size: 64),
      ),
    );
  }
}
