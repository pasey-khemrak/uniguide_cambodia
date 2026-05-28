import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/uniguide_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isWorking = false;
  bool _succeeded = false;
  String? _message;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      _showMessage('Enter your current password.', false);
      return;
    }

    if (newPassword.length < 8) {
      _showMessage('New password must be at least 8 characters.', false);
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('New passwords do not match.', false);
      return;
    }

    await _runAction(() async {
      await AuthService.changeCurrentUserPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      return 'Password changed successfully.';
    });
  }

  Future<void> _sendResetEmail() async {
    await _runAction(() async {
      await AuthService.sendCurrentUserPasswordResetEmail();
      return 'Password reset email sent. If it is in Spam, tap "Report not spam" first so Gmail enables the link.';
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
        _showMessage(message, true);
      }
    } catch (error) {
      if (mounted) {
        _showMessage(AuthService.messageForAuthError(error), false);
      }
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  void _showMessage(String message, bool succeeded) {
    setState(() {
      _message = message;
      _succeeded = succeeded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usesPassword = AuthService.currentUserUsesPassword;

    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            const UniGuideHeader(showBack: true, title: 'Change Password'),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  _Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Security',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          usesPassword
                              ? 'Enter your current password before choosing a new one.'
                              : 'This account signs in with Google. Your password is managed by Google, not UniGuide Cambodia.',
                          style: const TextStyle(
                            color: Colors.black54,
                            height: 1.45,
                          ),
                        ),
                        if (usesPassword) ...[
                          const SizedBox(height: 22),
                          _PasswordField(
                            controller: _currentPasswordController,
                            label: 'Current Password',
                          ),
                          const SizedBox(height: 14),
                          _PasswordField(
                            controller: _newPasswordController,
                            label: 'New Password',
                          ),
                          const SizedBox(height: 14),
                          _PasswordField(
                            controller: _confirmPasswordController,
                            label: 'Confirm New Password',
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isWorking ? null : _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: _isWorking
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Update Password'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reset by Email',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          usesPassword
                              ? 'Send a secure reset link to your account email if you do not remember your current password.'
                              : 'This account uses Google sign-in, so password reset links are managed by Google Account settings.',
                          style: const TextStyle(
                            color: Colors.black54,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed:
                              _isWorking || !usesPassword ? null : _sendResetEmail,
                          icon: const Icon(Icons.email_outlined),
                          label: const Text('Send Reset Email'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    _StatusMessage(message: _message!, succeeded: _succeeded),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: pageColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC8D0D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC8D0D6)),
        ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8DEE2)),
      ),
      child: child,
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
