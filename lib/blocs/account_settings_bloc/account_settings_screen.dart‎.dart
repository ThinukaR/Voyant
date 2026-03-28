import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';
import 'package:voyant/blocs/account_settings_bloc/account_settings_bloc.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';
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
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // Load profile data from Firestore via BLoC
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      if (mounted) {
        context.read<AccountSettingsBloc>().add(
          UploadProfileImageEvent(File(image.path)),
        );
      }
    }
  }

  Future<void> _changePassword() async {
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
                controller: _currentPasswordController,
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
                controller: _newPasswordController,
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
                controller: _confirmPasswordController,
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
              onPressed: () {
                if (_newPasswordController.text == _confirmPasswordController.text) {
                  Navigator.pop(context);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user?.email != null) {
                    context.read<AccountSettingsBloc>().add(
                      ChangePasswordEvent(
                        email: user!.email!,
                        currentPassword: _currentPasswordController.text,
                        newPassword: _newPasswordController.text,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
              onPressed: () {
                Navigator.pop(context);
                final user = FirebaseAuth.instance.currentUser;
                if (user?.email != null) {
                  context.read<AccountSettingsBloc>().add(
                    DeleteAccountEvent(
                      email: user!.email!,
                      password: '', // User will be prompted via re-authentication
                    ),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    context.read<AccountSettingsBloc>().add(
      UpdateProfileEvent(
        displayName: _nameController.text,
        bio: _bioController.text,
        location: _locationController.text,
      ),
    );
  }

  void _downloadPersonalData() {
    context.read<AccountSettingsBloc>().add(
      const DownloadPersonalDataEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<AccountSettingsBloc, AccountSettingsState>(
        listener: (context, state) {
          // Handle state changes
          if (state.status == AccountSettingsStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Changes saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == AccountSettingsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage ?? "Unknown error"}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == AccountSettingsStatus.accountDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account deleted successfully'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: AnimatedGradientBackground(
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
                  child: Stack(
                    children: [
                      SingleChildScrollView(
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
                              BlocBuilder<AccountSettingsBloc, AccountSettingsState>(
                                builder: (context, state) {
                                  return _buildSectionCard(
                                    title: 'Preferences',
                                    icon: Icons.tune,
                                    children: [
                                      _buildToggleTile(
                                        'Location Sharing',
                                        state.locationSharingEnabled,
                                            (value) {
                                          context.read<AccountSettingsBloc>().add(
                                            UpdateLocationSharingEvent(value),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Security Section
                              BlocBuilder<AccountSettingsBloc, AccountSettingsState>(
                                builder: (context, state) {
                                  return _buildSectionCard(
                                    title: 'Security',
                                    icon: Icons.security,
                                    children: [
                                      _buildToggleTile(
                                        'Two-Factor Authentication',
                                        state.twoFactorEnabled,
                                            (value) {
                                          context.read<AccountSettingsBloc>().add(
                                            UpdateTwoFAEvent(value),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildToggleTile(
                                        'Biometric Login',
                                        state.biometricLoginEnabled,
                                            (value) {
                                          context.read<AccountSettingsBloc>().add(
                                            UpdateBiometricEvent(value),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
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
                                      context.read<AccountSettingsBloc>().add(
                                        const LinkSocialAccountEvent(
                                          provider: 'google',
                                          accessToken: '', // Would be obtained via OAuth
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildActionButton(
                                    'Link Facebook Account',
                                    Icons.facebook,
                                        () {
                                      context.read<AccountSettingsBloc>().add(
                                        const LinkSocialAccountEvent(
                                          provider: 'facebook',
                                          accessToken: '', // Would be obtained via OAuth
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Activity Section
                              BlocBuilder<AccountSettingsBloc, AccountSettingsState>(
                                builder: (context, state) {
                                  return _buildSectionCard(
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
                                      if (state.loginSessions != null && state.loginSessions!.isNotEmpty)
                                        ...state.loginSessions!
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final session = entry.value;
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
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.devices_other,
                                                          color: Colors.cyanAccent,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            session['device'] ?? 'Unknown Device',
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 13,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        })
                                            .toList()
                                      else
                                        const Text(
                                          'No sessions found',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              // Save Button
                              BlocBuilder<AccountSettingsBloc, AccountSettingsState>(
                                builder: (context, state) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state.status == AccountSettingsStatus.loading
                                          ? null
                                          : _saveChanges,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyanAccent,
                                        disabledBackgroundColor: Colors.cyanAccent.withOpacity(0.5),
                                        padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: state.status == AccountSettingsStatus.loading
                                          ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          color: Color(0xFF1B0033),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      // Loading overlay
                      BlocBuilder<AccountSettingsBloc, AccountSettingsState>(
                        builder: (context, state) {
                          if (state.status == AccountSettingsStatus.loading) {
                            return Container(
                              color: Colors.black.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.cyanAccent,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
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