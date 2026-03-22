import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/privacy_security_settings_bloc/privacy_security_settings_bloc.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class PrivacySecuritySettingsScreen extends StatefulWidget {
  const PrivacySecuritySettingsScreen({super.key});

  @override
  State<PrivacySecuritySettingsScreen> createState() =>
      _PrivacySecuritySettingsScreenState();
}

class _PrivacySecuritySettingsScreenState
    extends State<PrivacySecuritySettingsScreen> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    // Load settings when screen initializes
    context.read<PrivacySecuritySettingsBloc>().add(
      const LoadPrivacySecuritySettingsEvent(),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  void _saveChanges() {
    context.read<PrivacySecuritySettingsBloc>().add(
      const SaveAllSettingsEvent(),
    );
  }

  void _changePassword() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    
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
                  // Change password via BLoC (from account settings)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password change initiated. Verify in account settings.'),
                      backgroundColor: Colors.green,
                    ),
                  );
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

  void _logoutAllDevices() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Logout from All Devices?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will logout from all active sessions. You will need to login again.',
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
                context.read<PrivacySecuritySettingsBloc>().add(
                  const LogoutAllDevicesEvent(),
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion initiated. Verify in account settings.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showBlockedUsers(Map<String, dynamic> blockSafetySettings) {
    final blockedUsers = blockSafetySettings['blockedUsers'] as List? ?? [];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Blocked Users',
            style: TextStyle(color: Colors.white),
          ),
          content: blockedUsers.isEmpty
              ? const Text(
                  'You have not blocked any users.',
                  style: TextStyle(color: Colors.white70),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: blockedUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          blockedUsers[index] as String,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            final updated = List<String>.from(blockedUsers);
                            updated.removeAt(index);
                            context.read<PrivacySecuritySettingsBloc>().add(
                              UpdateBlockSafetyEvent({
                                'blockedUsers': updated,
                              }),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<PrivacySecuritySettingsBloc, PrivacySecuritySettingsState>(
        listener: (context, state) {
          if (state.status == PrivacySecuritySettingsStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Privacy & Security settings saved successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state.status == PrivacySecuritySettingsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage ?? "Unknown error"}'),
                backgroundColor: Colors.red,
              ),
            );
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
                        'Privacy & Security',
                        style: TextStyle(
                          fontSize: 24,
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
                          child: BlocBuilder<PrivacySecuritySettingsBloc,
                              PrivacySecuritySettingsState>(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  // Account Security Section
                                  _buildSectionCard(
                                    title: 'Account Security',
                                    icon: Icons.lock,
                                    children: [
                                      _buildActionButton(
                                        'Change Password',
                                        Icons.vpn_key,
                                        _changePassword,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildToggleTile(
                                        'Two-Factor Authentication',
                                        state.accountSecuritySettings['twoFactorEnabled'] ??
                                            false,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdateAccountSecurityEvent({
                                              'twoFactorEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildToggleTile(
                                        'Biometric Login',
                                        state.accountSecuritySettings[
                                                'biometricLoginEnabled'] ??
                                            false,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdateAccountSecurityEvent({
                                              'biometricLoginEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      if (state.accountSecuritySettings[
                                              'biometricLoginEnabled'] ??
                                          false) ...[
                                        const SizedBox(height: 12),
                                        _buildDropdownField(
                                          label: 'Biometric Type',
                                          value: state.accountSecuritySettings[
                                                  'biometricType'] ??
                                              'Fingerprint',
                                          items: ['Fingerprint', 'Face ID'],
                                          onChanged: (value) {
                                            context
                                                .read<
                                                    PrivacySecuritySettingsBloc>()
                                                .add(
                                                  UpdateAccountSecurityEvent({
                                                    'biometricType': value,
                                                  }),
                                                );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Privacy Controls Section
                                  _buildSectionCard(
                                    title: 'Privacy Controls',
                                    icon: Icons.visibility,
                                    children: [
                                      _buildDropdownField(
                                        label: 'Profile Visibility',
                                        value: state
                                                .privacyControlSettings[
                                            'profileVisibility'] ??
                                            'Public',
                                        items: [
                                          'Public',
                                          'Private',
                                          'Friends Only'
                                        ],
                                        onChanged: (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdatePrivacyControlsEvent({
                                              'profileVisibility': value,
                                            }),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      _buildToggleTile(
                                        'Activity Visibility',
                                        state.privacyControlSettings[
                                                'activityVisibilityEnabled'] ??
                                            true,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdatePrivacyControlsEvent({
                                              'activityVisibilityEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildToggleTile(
                                        'Location Sharing',
                                        state.privacyControlSettings[
                                                'locationSharingEnabled'] ??
                                            true,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdatePrivacyControlsEvent({
                                              'locationSharingEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Data Protection Section
                                  _buildSectionCard(
                                    title: 'Data Protection',
                                    icon: Icons.security,
                                    children: [
                                      _buildActionButton(
                                        'Download My Data',
                                        Icons.download,
                                        () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Starting data download...'),
                                              backgroundColor: Colors.blue,
                                            ),
                                          );
                                        },
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

                                  // Device Management Section
                                  _buildSectionCard(
                                    title: 'Device Management',
                                    icon: Icons.devices,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Active Sessions',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (state.activeSessions != null &&
                                              state.activeSessions!.isNotEmpty)
                                            ...state.activeSessions!
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                                  final session = entry.value;
                                                  final index = entry.key;
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.05),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                          color: Colors
                                                              .cyanAccent
                                                              .withOpacity(
                                                                  0.3),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .devices_other,
                                                                color: Colors
                                                                    .cyanAccent,
                                                                size: 18,
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                session[
                                                                    'device'] ??
                                                                    'Unknown Device',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (index != 0)
                                                            GestureDetector(
                                                              onTap: () {
                                                                // Remove session
                                                              },
                                                              child:
                                                                  const Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .red,
                                                                size: 18,
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
                                              'No active sessions',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                          const SizedBox(height: 12),
                                          _buildActionButton(
                                            'Logout from All Devices',
                                            Icons.logout,
                                            _logoutAllDevices,
                                            isDestructive: true,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Permissions Section
                                  _buildSectionCard(
                                    title: 'Permissions',
                                    icon: Icons.admin_panel_settings,
                                    children: [
                                      _buildToggleTile(
                                        'Location Access',
                                        state.permissionsSettings[
                                                'locationPermission'] ??
                                            true,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdatePermissionsEvent({
                                              'locationPermission': value,
                                            }),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildToggleTile(
                                        'Camera Access',
                                        state.permissionsSettings[
                                                'cameraPermission'] ??
                                            true,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdatePermissionsEvent({
                                              'cameraPermission': value,
                                            }),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildToggleTile(
                                        'Storage Access',
                                        state.permissionsSettings[
                                                'storagePermission'] ??
                                            true,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdatePermissionsEvent({
                                              'storagePermission': value,
                                            }),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Alerts & Monitoring Section
                                  _buildSectionCard(
                                    title: 'Alerts & Monitoring',
                                    icon: Icons.notifications_active,
                                    children: [
                                      _buildToggleTile(
                                        'Suspicious Login Alerts',
                                        state.alertsMonitoringSettings[
                                                'suspiciousLoginAlerts'] ??
                                            true,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdateAlertsMonitoringEvent({
                                              'suspiciousLoginAlerts': value,
                                            }),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildToggleTile(
                                        'Security Notifications',
                                        state.alertsMonitoringSettings[
                                                'securityNotifications'] ??
                                            true,
                                        (value) {
                                          context
                                              .read<
                                                  PrivacySecuritySettingsBloc>()
                                              .add(
                                            UpdateAlertsMonitoringEvent({
                                              'securityNotifications': value,
                                            }),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Block & Safety Section
                                  _buildSectionCard(
                                    title: 'Block & Safety',
                                    icon: Icons.block,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Blocked Users: ${(state.blockSafetySettings['blockedUsers'] as List?)?.length ?? 0}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () => _showBlockedUsers(
                                              state.blockSafetySettings,
                                            ),
                                            icon: const Icon(Icons.list),
                                            label: const Text('View'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.cyanAccent,
                                              foregroundColor:
                                                  const Color(0xFF1B0033),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildActionButton(
                                        'Report User/Content',
                                        Icons.flag,
                                        () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Report submitted. We\'ll review it soon.'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 30),

                                  // Save Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state.status ==
                                              PrivacySecuritySettingsStatus
                                                  .loading
                                          ? null
                                          : _saveChanges,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyanAccent,
                                        disabledBackgroundColor:
                                            Colors.cyanAccent
                                                .withOpacity(0.5),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: state.status ==
                                              PrivacySecuritySettingsStatus
                                                  .loading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator(
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
                                  ),

                                  const SizedBox(height: 20),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      // Loading overlay
                      BlocBuilder<PrivacySecuritySettingsBloc,
                          PrivacySecuritySettingsState>(
                        builder: (context, state) {
                          if (state.status ==
                              PrivacySecuritySettingsStatus.loading) {
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
          // Section Header
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
          // Section Items
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleTile(String label, bool value, Function(bool) onChanged) {
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
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
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.cyanAccent,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1B0033),
            style: const TextStyle(
              color: Colors.white,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
}
