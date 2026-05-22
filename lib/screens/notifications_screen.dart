import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../widgets/uniguide_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            const UniGuideHeader(showBack: true, title: 'Notifications'),
            Expanded(
              child: StreamBuilder<List<AppNotification>>(
                stream: NotificationService.notifications(),
                builder: (context, snapshot) {
                  final userNotifications = snapshot.data ?? const [];

                  return StreamBuilder<List<AppNotification>>(
                    stream: NotificationService.newUniversityNotifications(),
                    builder: (context, universitySnapshot) {
                      final notifications = [
                        ...userNotifications,
                        ...(universitySnapshot.data ?? const []),
                      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                      final isLoading =
                          snapshot.connectionState == ConnectionState.waiting &&
                              universitySnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              notifications.isEmpty;

                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (notifications.isEmpty) {
                        return const Center(
                          child: Text(
                            'No notifications yet.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _NotificationTile(
                            notification: notifications[index],
                          );
                        },
                      );
                    },
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8DEE2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: accentColor.withValues(alpha: 0.55),
            foregroundColor: primaryColor,
            child: Icon(_iconFor(notification.type)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(color: Colors.black87, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'profile':
        return Icons.person_outline;
      case 'review':
      case 'saved_review':
        return Icons.rate_review_outlined;
      case 'university':
        return Icons.account_balance_outlined;
      default:
        return Icons.notifications_none;
    }
  }
}
