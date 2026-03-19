import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:io';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _locationSharingEnabled = true;
  bool _twoFactorEnabled = false;
  bool _biometricLoginEnabled = false;
  List<String> _loginSessions = ['Current Device'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // Load profile data from Firestore via BLoC
      // For now, using placeholder data
      setState(() {
        _nameController.text = firebaseUser.displayName ?? '';
        _bioController.text = '';
        _locationController.text = '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _changePassword() async {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Change Password',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Current Password',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'New Password',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && user.email != null) {
                    // Re-authenticate user
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: currentPasswordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);

                    // Update password
                    await user.updatePassword(newPasswordController.text);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password changed successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Logout?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final userRepository =
                      RepositoryProvider.of<UserRepository>(context);
                  await userRepository.logOut();
                  if (mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Delete Account?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Delete user document from Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .delete();
                    // Delete Firebase Auth user
                    await user.delete();
                    if (mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account deleted successfully'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(_nameController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account settings saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadPersonalData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting personal data download...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5B0E8C),
              Color(0xFF1B0033),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Profile Section
                        _buildSectionCard(
                          title: 'Profile',
                          icon: Icons.person,
                          children: [
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.cyanAccent,
                                        width: 3,
                                      ),
                                      image: _profileImage != null
                                          ? DecorationImage(
                                              image: FileImage(_profileImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: _profileImage == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tap to change profile picture',
                                    style: TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Display Name',
                              controller: _nameController,
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Bio',
                              controller: _bioController,
                              icon: Icons.description,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Location',
                              controller: _locationController,
                              icon: Icons.location_on,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Authentication Section
                        _buildSectionCard(
                          title: 'Authentication',
                          icon: Icons.lock,
                          children: [
                            _buildInfoRow(
                              'Email',
                              FirebaseAuth.instance.currentUser?.email ?? 'N/A',
                            ),
                            const SizedBox(height: 16),
                            _buildActionButton(
                              'Change Password',
                              Icons.vpn_key,
                              _changePassword,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Logout',
                              Icons.logout,
                              _logout,
                              isDestructive: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Preferences Section
                        _buildSectionCard(
                          title: 'Preferences',
                          icon: Icons.tune,
                          children: [
                            _buildToggleTile(
                              'Location Sharing',
                              _locationSharingEnabled,
                              (value) {
                                setState(() => _locationSharingEnabled = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Security Section
                        _buildSectionCard(
                          title: 'Security',
                          icon: Icons.security,
                          children: [
                            _buildToggleTile(
                              'Two-Factor Authentication',
                              _twoFactorEnabled,
                              (value) {
                                setState(() => _twoFactorEnabled = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildToggleTile(
                              'Biometric Login',
                              _biometricLoginEnabled,
                              (value) {
                                setState(() => _biometricLoginEnabled = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Account Management Section
                        _buildSectionCard(
                          title: 'Account Management',
                          icon: Icons.manage_accounts,
                          children: [
                            _buildActionButton(
                              'Download Personal Data',
                              Icons.download,
                              _downloadPersonalData,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Delete Account',
                              Icons.delete_forever,
                              _deleteAccount,
                              isDestructive: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Connected Accounts Section
                        _buildSectionCard(
                          title: 'Connected Accounts',
                          icon: Icons.link,
                          children: [
                            const Text(
                              'No connected accounts',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Link Google Account',
                              Icons.account_circle,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Linking Google account...'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Link Facebook Account',
                              Icons.facebook,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Linking Facebook account...'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Activity Section
                        _buildSectionCard(
                          title: 'Activity',
                          icon: Icons.history,
                          children: [
                            const Text(
                              'Login Sessions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._loginSessions
                                .asMap()
                                .entries
                                .map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.cyanAccent
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.devices_other,
                                                color: Colors.cyanAccent,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                entry.value,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Color(0xFF1B0033),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.cyanAccent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.cyanAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.cyanAccent,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.cyanAccent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.cyanAccent.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.cyanAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile(
      String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.cyanAccent,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red : Colors.cyanAccent,
          foregroundColor:
              isDestructive ? Colors.white : const Color(0xFF1B0033),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
