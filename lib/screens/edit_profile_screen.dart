import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../widgets/uniguide_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _majorController;
  late final TextEditingController _schoolController;
  late final TextEditingController _programController;
  late List<String> _majors;
  late List<UserEducation> _education;
  late String _status;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _isSaving = false;
  String? _saveMessage;
  bool _saveSucceeded = false;

  static const _statuses = [
    'High School Student',
    'Bachelor Degree',
    'Master Degree',
    'Graduate',
    'Working Professional',
  ];

  static const _majorSuggestions = [
    'Computer Science',
    'Software Engineering',
    'Information Technology',
    'Data Science',
    'Cybersecurity',
    'Business Administration',
    'Accounting',
    'Finance',
    'Marketing',
    'International Relations',
    'Law',
    'Architecture',
    'Civil Engineering',
    'Electrical Engineering',
    'Medicine',
    'Nursing',
    'Pharmacy',
    'Education',
    'TESOL',
    'Tourism and Hospitality',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _locationController = TextEditingController(text: widget.profile.location);
    _bioController = TextEditingController(text: widget.profile.bio);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _majorController = TextEditingController();
    _schoolController = TextEditingController();
    _programController = TextEditingController();
    _majors = [...widget.profile.interestedMajors];
    _education = [...widget.profile.education];
    _status = _statuses.contains(widget.profile.status)
        ? widget.profile.status
        : _statuses.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _majorController.dispose();
    _schoolController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxWidth: 600,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    setState(() {
      _pickedImage = image;
      _pickedImageBytes = bytes;
    });
  }

  Future<void> _saveProfile() async {
    _commitPendingEducation();

    final validationMessage = _profileValidationMessage();
    if (validationMessage != null) {
      setState(() {
        _saveSucceeded = false;
        _saveMessage = validationMessage;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveSucceeded = true;
      _saveMessage = 'Saving profile...';
    });

    try {
      var photoUrl = widget.profile.photoUrl;
      String? photoWarning;
      if (_pickedImage != null) {
        try {
          photoUrl = await UserProfileService.uploadProfilePhoto(_pickedImage!)
              .timeout(const Duration(seconds: 60));
        } on TimeoutException {
          photoWarning =
              ' Profile saved, but the photo upload timed out. Try a smaller image or check your internet connection.';
        } on CloudinaryUploadException catch (error) {
          photoWarning =
              ' Profile saved, but the photo upload failed: ${error.message}.';
        }
      }

      final updatedProfile = widget.profile.copyWith(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        status: _status,
        bio: _bioController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        interestedMajors: _cleanMajors(),
        education: _cleanEducation(),
        photoUrl: photoUrl,
      );

      await UserProfileService.updateProfile(updatedProfile);

      if (mounted) {
        setState(() {
          _pickedImage = null;
          _pickedImageBytes = null;
          _saveSucceeded = true;
          _saveMessage = 'Profile updated successfully.${photoWarning ?? ''}';
        });
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        setState(() {
          _saveSucceeded = false;
          _saveMessage = _firebaseSaveMessage(error);
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _saveSucceeded = false;
          _saveMessage =
              'Saving took too long. Check your internet connection and try again.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _saveSucceeded = false;
          _saveMessage = 'Could not update profile: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _firebaseSaveMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firebase rules blocked this profile update. Allow this user to update their own users document, including education and interestedMajors.';
      case 'resource-exhausted':
        return 'This profile has too much information to save at once. Shorten the bio or remove some items.';
      case 'unavailable':
        return 'Firebase is unavailable right now. Check your internet connection and try again.';
      case 'deadline-exceeded':
        return 'Firebase took too long to save this profile. Check your connection and try again.';
      default:
        return 'Could not update profile: ${error.message ?? error.code}';
    }
  }

  String? _profileValidationMessage() {
    if (_nameController.text.trim().isEmpty) {
      return 'Enter your full name.';
    }

    if (!_emailController.text.trim().contains('@')) {
      return 'Enter a valid email.';
    }

    if (_bioController.text.trim().length > 800) {
      return 'Keep your bio under 800 characters.';
    }

    if (_majors.length > 20) {
      return 'Keep selected majors to 20 or fewer.';
    }

    if (_education.length > 10) {
      return 'Keep education entries to 10 or fewer.';
    }

    return null;
  }

  void _discardChanges() {
    setState(() {
      _nameController.text = widget.profile.name;
      _locationController.text = widget.profile.location;
      _bioController.text = widget.profile.bio;
      _emailController.text = widget.profile.email;
      _phoneController.text = widget.profile.phone;
      _majors = [...widget.profile.interestedMajors];
      _education = [...widget.profile.education];
      _status = _statuses.contains(widget.profile.status)
          ? widget.profile.status
          : _statuses.first;
      _majorController.clear();
      _schoolController.clear();
      _programController.clear();
      _pickedImage = null;
      _pickedImageBytes = null;
      _saveMessage = null;
    });
  }

  void _addMajor() {
    final major = _majorController.text.trim();
    if (major.isEmpty || _majors.contains(major)) {
      return;
    }

    setState(() {
      _majors.add(major);
      _majorController.clear();
    });
  }

  void _addEducation() {
    final school = _schoolController.text.trim();
    final program = _programController.text.trim();

    if (school.isEmpty || program.isEmpty) {
      setState(() {
        _saveSucceeded = false;
        _saveMessage = 'Enter both school and program before adding education.';
      });
      return;
    }

    setState(() {
      _education.add(UserEducation(school: school, program: program));
      _schoolController.clear();
      _programController.clear();
      _saveSucceeded = true;
      _saveMessage = null;
    });
  }

  void _commitPendingEducation() {
    final school = _schoolController.text.trim();
    final program = _programController.text.trim();

    if (school.isEmpty && program.isEmpty) {
      return;
    }

    if (school.isEmpty || program.isEmpty) {
      return;
    }

    _education.add(UserEducation(school: school, program: program));
    _schoolController.clear();
    _programController.clear();
  }

  List<String> _cleanMajors() {
    return _majors
        .map((major) => major.trim())
        .where((major) => major.isNotEmpty)
        .toSet()
        .toList();
  }

  List<UserEducation> _cleanEducation() {
    return _education
        .map(
          (item) => UserEducation(
            school: item.school.trim(),
            program: item.program.trim(),
          ),
        )
        .where((item) => item.school.isNotEmpty && item.program.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: pageColor,
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: primaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  _PreviewCard(
                    name: _nameController.text,
                    location: _locationController.text,
                    photoUrl: widget.profile.photoUrl,
                    pickedImageBytes: _pickedImageBytes,
                    onPickPhoto: _pickPhoto,
                  ),
                  const SizedBox(height: 12),
                  _FormPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PanelTitle(
                          icon: Icons.edit_note,
                          title: 'Basic Information',
                        ),
                        const _FieldLabel('Full Name'),
                        TextField(
                          controller: _nameController,
                          decoration: _inputDecoration(),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Location'),
                        TextField(
                          controller: _locationController,
                          decoration: _inputDecoration(),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Current Grade / Status'),
                        InputDecorator(
                          decoration: _inputDecoration(),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _status,
                              isExpanded: true,
                              items: _statuses.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _status = value);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Bio'),
                        TextField(
                          controller: _bioController,
                          maxLines: 5,
                          decoration: _inputDecoration(),
                        ),
                        const SizedBox(height: 20),
                        const _PanelTitle(
                          icon: Icons.account_balance_outlined,
                          title: 'Education',
                        ),
                        if (_education.isEmpty)
                          const Text(
                            'No education added yet.',
                            style: TextStyle(color: Colors.black54),
                          )
                        else
                          ..._education.map((item) {
                            return _EditableEducationTile(
                              education: item,
                              onDelete: () {
                                setState(() => _education.remove(item));
                              },
                            );
                          }),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _schoolController,
                          decoration: _inputDecoration().copyWith(
                            labelText: 'School / University',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _programController,
                          decoration: _inputDecoration().copyWith(
                            labelText: 'Program / Major',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _addEducation,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Education'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _PanelTitle(
                          icon: Icons.school_outlined,
                          title: 'Interested Majors',
                        ),
                        const Text(
                          'Suggested majors',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          children: _majorSuggestions.map((major) {
                            final selected = _majors.contains(major);
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                                bottom: 8,
                              ),
                              child: FilterChip(
                                label: Text(major),
                                selected: selected,
                                selectedColor: accentColor,
                                onSelected: selected
                                    ? null
                                    : (_) {
                                        setState(() => _majors.add(major));
                                      },
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your selected majors',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          children: [
                            ..._majors.map((major) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: 8, bottom: 8),
                                child: InputChip(
                                  label: Text(major),
                                  backgroundColor: accentColor,
                                  onDeleted: () {
                                    setState(() => _majors.remove(major));
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _majorController,
                          decoration: _inputDecoration().copyWith(
                            labelText: 'Custom major',
                            suffixIcon: IconButton(
                              tooltip: 'Add major',
                              onPressed: _addMajor,
                              icon: const Icon(Icons.add),
                            ),
                          ),
                          onSubmitted: (_) => _addMajor(),
                        ),
                        const SizedBox(height: 20),
                        const _PanelTitle(
                          icon: Icons.alternate_email,
                          title: 'Contact Details',
                        ),
                        const _FieldLabel('Email Address'),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Phone Number'),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(prefixText: '+855  '),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _discardChanges,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFE2E5E8),
                              foregroundColor: Colors.black54,
                            ),
                            child: const Text('Discard Changes'),
                          ),
                        ),
                        if (_saveMessage != null) ...[
                          const SizedBox(height: 14),
                          _SaveMessage(
                            message: _saveMessage!,
                            succeeded: _saveSucceeded,
                          ),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 8,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Update My Profile'),
                          ),
                        ),
                      ],
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

  InputDecoration _inputDecoration({String? prefixText}) {
    return InputDecoration(
      prefixText: prefixText,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }
}

class _SaveMessage extends StatelessWidget {
  const _SaveMessage({
    required this.message,
    required this.succeeded,
  });

  final String message;
  final bool succeeded;

  @override
  Widget build(BuildContext context) {
    final color = succeeded ? primaryColor : Colors.red.shade700;
    final background = succeeded
        ? accentColor.withValues(alpha: 0.28)
        : Colors.red.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.32)),
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
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.name,
    required this.location,
    required this.photoUrl,
    required this.pickedImageBytes,
    required this.onPickPhoto,
  });

  final String name;
  final String location;
  final String photoUrl;
  final Uint8List? pickedImageBytes;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    return _FormPanel(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _PreviewPhoto(
                  photoUrl: photoUrl,
                  pickedImageBytes: pickedImageBytes,
                ),
              ),
              FloatingActionButton.small(
                heroTag: 'profile-photo',
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                onPressed: onPickPhoto,
                child: const Icon(Icons.camera_alt),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            name.isEmpty ? 'UniGuide Student' : name,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Divider(height: 36),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.black54),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewPhoto extends StatelessWidget {
  const _PreviewPhoto({
    required this.photoUrl,
    required this.pickedImageBytes,
  });

  final String photoUrl;
  final Uint8List? pickedImageBytes;

  @override
  Widget build(BuildContext context) {
    if (pickedImageBytes != null) {
      return Image.memory(
        pickedImageBytes!,
        width: 144,
        height: 144,
        fit: BoxFit.cover,
      );
    }

    if (photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        width: 144,
        height: 144,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 144,
      height: 144,
      color: const Color(0xFFE6EEF1),
      child: const Icon(Icons.person_outline, color: primaryColor, size: 56),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8D0D6)),
      ),
      child: child,
    );
  }
}

class _EditableEducationTile extends StatelessWidget {
  const _EditableEducationTile({
    required this.education,
    required this.onDelete,
  });

  final UserEducation education;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pageColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D0D6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  education.school,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  education.program,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove education',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
