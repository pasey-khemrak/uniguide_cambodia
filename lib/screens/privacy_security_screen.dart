import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/search_history_service.dart';
import '../widgets/uniguide_widgets.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _isWorking = false;
  bool _confirmDelete = false;
  String? _message;
  bool _succeeded = false;

  Future<void> _clearSearchHistory() async {
    await _runAction(() async {
      await SearchHistoryService.clear();
      return 'Search history cleared.';
    });
  }

  Future<void> _deleteAccount() async {
    await _runAction(() async {
      await AuthService.deleteCurrentAccount();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
      return 'Account deleted.';
    });
  }

  Future<void> _runAction(Future<String> Function() action) async {
    setState(() {
      _isWorking = true;
      _message = null;
    });

    try {
      final message = await action();
      if (mounted) {
        setState(() {
          _succeeded = true;
          _message = message;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _succeeded = false;
          _message = AuthService.messageForAuthError(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            const UniGuideHeader(showBack: true, title: 'Privacy & Security'),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  const _HeroPanel(),
                  const SizedBox(height: 30),
                  _PrivacySection(
                    title: 'ACCOUNT SECURITY',
                    children: [
                      _PrivacyTile(
                        icon: Icons.key_outlined,
                        title: 'Change Password',
                        subtitle: 'Update password or send a reset email',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/change-password',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _PrivacySection(
                    title: 'DATA & PRIVACY',
                    children: [
                      _PrivacyTile(
                        icon: Icons.history_outlined,
                        title: 'Clear Search History',
                        subtitle: 'Remove university and major search records',
                        onTap: _isWorking ? null : _clearSearchHistory,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _PrivacySection(
                    title: 'LEGAL & COMPLIANCE',
                    children: [
                      _PrivacyTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        trailing: Icons.open_in_new,
                        onTap: () => Navigator.pushNamed(context, '/terms'),
                      ),
                    ],
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 22),
                    _StatusMessage(message: _message!, succeeded: _succeeded),
                  ],
                  const SizedBox(height: 46),
                  const Center(
                    child: Text(
                      'Need to close your account entirely?',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_confirmDelete)
                    _DeleteConfirmPanel(
                      isWorking: _isWorking,
                      onCancel: () => setState(() => _confirmDelete = false),
                      onDelete: _deleteAccount,
                    )
                  else
                    TextButton(
                      onPressed: _isWorking
                          ? null
                          : () => setState(() => _confirmDelete = true),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFE4EFF1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D0D6)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Data, Your Choice',
            style: TextStyle(
              color: primaryColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Manage how UniGuide Cambodia protects your academic journey and personal information.',
            style: TextStyle(color: Colors.black54, fontSize: 18, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D0D6)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFC8D0D6))),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  const _PrivacyTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing = Icons.chevron_right,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final IconData trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE6F3F4),
        foregroundColor: primaryColor,
        child: Icon(icon),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Icon(trailing, color: Colors.black54),
      onTap: onTap,
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.message,
    required this.succeeded,
  });

  final String message;
  final bool succeeded;

  @override
  Widget build(BuildContext context) {
    final color = succeeded ? primaryColor : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: succeeded
            ? accentColor.withValues(alpha: 0.25)
            : Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            succeeded ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteConfirmPanel extends StatelessWidget {
  const _DeleteConfirmPanel({
    required this.isWorking,
    required this.onCancel,
    required this.onDelete,
  });

  final bool isWorking;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Text(
            'Deleting your account removes your profile, saved universities, notifications, and search history.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isWorking ? null : onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isWorking ? null : onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: isWorking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
