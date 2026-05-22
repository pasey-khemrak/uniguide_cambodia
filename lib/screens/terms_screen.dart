import 'package:flutter/material.dart';

import '../widgets/uniguide_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            const UniGuideHeader(showBack: true, title: 'Terms of Service'),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: const [
                  _TermsPanel(
                    title: 'Using UniGuide Cambodia',
                    body:
                        'UniGuide Cambodia helps students explore universities, save options, and share reviews. Information in the app should be used as guidance, and students should verify admission details with each official university.',
                  ),
                  SizedBox(height: 14),
                  _TermsPanel(
                    title: 'Your Account',
                    body:
                        'You are responsible for keeping your account secure and for the accuracy of information you add to your profile, reviews, and saved universities.',
                  ),
                  SizedBox(height: 14),
                  _TermsPanel(
                    title: 'Reviews',
                    body:
                        'Reviews should be honest, respectful, and based on real student experience. UniGuide Cambodia may remove content that is abusive, misleading, or unrelated to university guidance.',
                  ),
                  SizedBox(height: 14),
                  _TermsPanel(
                    title: 'Privacy',
                    body:
                        'Profile data, saved universities, notifications, and search history are used to personalize your experience. You can clear search history or delete your account from Privacy & Security.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsPanel extends StatelessWidget {
  const _TermsPanel({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8DEE2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}
