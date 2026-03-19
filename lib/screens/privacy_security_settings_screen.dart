import 'package:flutter/material.dart';

class PrivacySecuritySettingsScreen extends StatefulWidget {
  const PrivacySecuritySettingsScreen({super.key});

  @override
  State<PrivacySecuritySettingsScreen> createState() =>
      _PrivacySecuritySettingsScreenState();
}

class _PrivacySecuritySettingsScreenState
    extends State<PrivacySecuritySettingsScreen> {
  // Account Security
  bool _twoFactorEnabled = false;
  bool _biometricLoginEnabled = false;
  String _biometricType = 'Fingerprint';

  // Privacy Controls
  String _profileVisibility = 'Public';
  bool _activityVisibilityEnabled = true;
  bool _locationSharingEnabled = true;

  // Device Management
  List<String> _activeSessions = ['Current Device', 'iPhone 14', 'iPad Pro'];

  // Permissions
  bool _locationPermission = true;
  bool _cameraPermission = true;
  bool _storagePermission = true;

  // Alerts & Monitoring
  bool _suspiciousLoginAlerts = true;
  bool _securityNotifications = true;

  // Block & Safety
  List<String> _blockedUsers = [];
  int _blockedCount = 0;

  final List<String> _profileVisibilityOptions = ['Public', 'Private', 'Friends Only'];
  final List<String> _biometricOptions = ['Fingerprint', 'Face ID'];

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy & Security settings saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _changePassword() {
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out from all devices'),
                    backgroundColor: Colors.orange,
                  ),
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
                    content: Text('Account deletion initiated'),
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

  void _showBlockedUsers() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Blocked Users',
            style: TextStyle(color: Colors.white),
          ),
          content: _blockedCount == 0
              ? const Text(
                  'You have not blocked any users.',
                  style: TextStyle(color: Colors.white70),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: _blockedUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _blockedUsers[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _blockedUsers.removeAt(index);
                              _blockedCount--;
                            });
                            Navigator.pop(context);
                            _showBlockedUsers();
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
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
                            if (_biometricLoginEnabled) ...[
                              const SizedBox(height: 12),
                              _buildDropdownField(
                                label: 'Biometric Type',
                                value: _biometricType,
                                items: _biometricOptions,
                                onChanged: (value) {
                                  setState(() => _biometricType = value);
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
                              value: _profileVisibility,
                              items: _profileVisibilityOptions,
                              onChanged: (value) {
                                setState(() => _profileVisibility = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildToggleTile(
                              'Activity Visibility',
                              _activityVisibilityEnabled,
                              (value) {
                                setState(() => _activityVisibilityEnabled = value);
                              },
                            ),
                            const SizedBox(height: 12),
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

                        // Data Protection Section
                        _buildSectionCard(
                          title: 'Data Protection',
                          icon: Icons.security,
                          children: [
                            _buildActionButton(
                              'Download My Data',
                              Icons.download,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Starting data download...'),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                ..._activeSessions.asMap().entries.map((entry) {
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
                                          if (entry.key != 0)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _activeSessions
                                                      .removeAt(entry.key);
                                                });
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
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
                              _locationPermission,
                              (value) {
                                setState(() => _locationPermission = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildToggleTile(
                              'Camera Access',
                              _cameraPermission,
                              (value) {
                                setState(() => _cameraPermission = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildToggleTile(
                              'Storage Access',
                              _storagePermission,
                              (value) {
                                setState(() => _storagePermission = value);
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
                              _suspiciousLoginAlerts,
                              (value) {
                                setState(() => _suspiciousLoginAlerts = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildToggleTile(
                              'Security Notifications',
                              _securityNotifications,
                              (value) {
                                setState(() => _securityNotifications = value);
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Blocked Users: $_blockedCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showBlockedUsers,
                                  icon: const Icon(Icons.list),
                                  label: const Text('View'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    foregroundColor: const Color(0xFF1B0033),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Report User/Content',
                              Icons.flag,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
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
