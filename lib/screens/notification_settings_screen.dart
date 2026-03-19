import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // General
  bool _pushNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Activity
  bool _missionsEnabled = true;
  bool _rewardsEnabled = true;
  bool _recommendationsEnabled = true;

  // Social
  bool _friendRequestsEnabled = true;
  bool _likesCommentsEnabled = true;
  bool _tripInvitesEnabled = true;

  // Reminders
  bool _tripRemindersEnabled = true;
  bool _bookingAlertsEnabled = true;
  bool _eventNotificationsEnabled = true;

  // Messages
  bool _chatNotificationsEnabled = true;
  bool _groupUpdatesEnabled = true;
  bool _supportRepliesEnabled = true;

  // Promotions
  bool _offersEnabled = true;
  bool _newFeaturesEnabled = false;

  // Preferences
  String _notificationFrequency = 'Instant';
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  // Privacy
  bool _showNotificationContent = true;
  bool _lockScreenPreview = true;

  final List<String> _frequencyOptions = ['Instant', 'Daily', 'Weekly'];

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietHoursStart : _quietHoursEnd,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
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
                      'Notifications',
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
                        // General Section
                        _buildSectionCard(
                          title: 'General',
                          icon: Icons.notifications,
                          children: [
                            _buildToggleTile(
                              'Push Notifications',
                              _pushNotifications,
                              (value) {
                                setState(() => _pushNotifications = value);
                              },
                            ),
                            _buildToggleTile(
                              'Sound',
                              _soundEnabled,
                              (value) {
                                setState(() => _soundEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Vibration',
                              _vibrationEnabled,
                              (value) {
                                setState(() => _vibrationEnabled = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Activity Section
                        _buildSectionCard(
                          title: 'Activity',
                          icon: Icons.emoji_events,
                          children: [
                            _buildToggleTile(
                              'Missions & Challenges',
                              _missionsEnabled,
                              (value) {
                                setState(() => _missionsEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Rewards & Achievements',
                              _rewardsEnabled,
                              (value) {
                                setState(() => _rewardsEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Travel Recommendations',
                              _recommendationsEnabled,
                              (value) {
                                setState(() => _recommendationsEnabled = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Social Section
                        _buildSectionCard(
                          title: 'Social',
                          icon: Icons.people,
                          children: [
                            _buildToggleTile(
                              'Friend Requests',
                              _friendRequestsEnabled,
                              (value) {
                                setState(() => _friendRequestsEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Likes & Comments',
                              _likesCommentsEnabled,
                              (value) {
                                setState(() => _likesCommentsEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Trip Invites',
                              _tripInvitesEnabled,
                              (value) {
                                setState(() => _tripInvitesEnabled = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Reminders Section
                        _buildSectionCard(
                          title: 'Reminders',
                          icon: Icons.alarm,
                          children: [
                            _buildToggleTile(
                              'Trip Reminders',
                              _tripRemindersEnabled,
                              (value) {
                                setState(() => _tripRemindersEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Booking Alerts',
                              _bookingAlertsEnabled,
                              (value) {
                                setState(() => _bookingAlertsEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Event Notifications',
                              _eventNotificationsEnabled,
                              (value) {
                                setState(() => _eventNotificationsEnabled = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Messages Section
                        _buildSectionCard(
                          title: 'Messages',
                          icon: Icons.mail,
                          children: [
                            _buildToggleTile(
                              'Chat Notifications',
                              _chatNotificationsEnabled,
                              (value) {
                                setState(() => _chatNotificationsEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Group Updates',
                              _groupUpdatesEnabled,
                              (value) {
                                setState(() => _groupUpdatesEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'Support Replies',
                              _supportRepliesEnabled,
                              (value) {
                                setState(() => _supportRepliesEnabled = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Promotions Section
                        _buildSectionCard(
                          title: 'Promotions',
                          icon: Icons.local_offer,
                          children: [
                            _buildToggleTile(
                              'Offers & Discounts',
                              _offersEnabled,
                              (value) {
                                setState(() => _offersEnabled = value);
                              },
                            ),
                            _buildToggleTile(
                              'New Features & Updates',
                              _newFeaturesEnabled,
                              (value) {
                                setState(() => _newFeaturesEnabled = value);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Preferences Section
                        _buildSectionCard(
                          title: 'Preferences',
                          icon: Icons.tune,
                          children: [
                            // Frequency Selection
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Notification Frequency',
                                    style: TextStyle(
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
                                      value: _notificationFrequency,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      dropdownColor: const Color(0xFF1B0033),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      items: _frequencyOptions
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _notificationFrequency =
                                                newValue;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Quiet Hours
                            _buildToggleTile(
                              'Quiet Hours / Do Not Disturb',
                              _quietHoursEnabled,
                              (value) {
                                setState(() => _quietHoursEnabled = value);
                              },
                            ),

                            if (_quietHoursEnabled) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'From',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () => _selectTime(true),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    Colors.cyanAccent
                                                        .withOpacity(0.5),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _quietHoursStart.format(context),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'To',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () => _selectTime(false),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    Colors.cyanAccent
                                                        .withOpacity(0.5),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _quietHoursEnd.format(context),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Privacy Section
                        _buildSectionCard(
                          title: 'Privacy',
                          icon: Icons.privacy_tip,
                          children: [
                            _buildToggleTile(
                              'Show Notification Content',
                              _showNotificationContent,
                              (value) {
                                setState(() => _showNotificationContent = value);
                              },
                            ),
                            _buildToggleTile(
                              'Lock Screen Preview',
                              _lockScreenPreview,
                              (value) {
                                setState(() => _lockScreenPreview = value);
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
                              'Save Settings',
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
          ...children
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: child,
                ),
              )
              .toList(),
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
}
