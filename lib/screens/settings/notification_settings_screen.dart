import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voyant/blocs/notification_settings_bloc/notification_settings_bloc.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late TimeOfDay _quietHoursStart;
  late TimeOfDay _quietHoursEnd;

  @override
  void initState() {
    super.initState();
    _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
    _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

    // Load settings when screen initializes
    context.read<NotificationSettingsBloc>().add(
      const LoadNotificationSettingsEvent(),
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

  void _saveChanges() {
    context.read<NotificationSettingsBloc>().add(
      const SaveAllSettingsEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<NotificationSettingsBloc, NotificationSettingsState>(
        listener: (context, state) {
          if (state.status == NotificationSettingsStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification settings saved successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state.status == NotificationSettingsStatus.failure) {
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
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: BlocBuilder<NotificationSettingsBloc,
                              NotificationSettingsState>(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  // General Section
                                  _buildSectionCard(
                                    title: 'General',
                                    icon: Icons.notifications,
                                    children: [
                                      _buildToggleTile(
                                        'Push Notifications',
                                        state.generalSettings['pushNotifications'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateGeneralSettingsEvent({
                                              'pushNotifications': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Sound',
                                        state.generalSettings['soundEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateGeneralSettingsEvent({
                                              'soundEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Vibration',
                                        state.generalSettings['vibrationEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateGeneralSettingsEvent({
                                              'vibrationEnabled': value,
                                            }),
                                          );
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
                                        state.activitySettings['missionsEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateActivitySettingsEvent({
                                              'missionsEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Rewards & Achievements',
                                        state.activitySettings['rewardsEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateActivitySettingsEvent({
                                              'rewardsEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Travel Recommendations',
                                        state.activitySettings[
                                        'recommendationsEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateActivitySettingsEvent({
                                              'recommendationsEnabled': value,
                                            }),
                                          );
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
                                        state.socialSettings['friendRequestsEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateSocialSettingsEvent({
                                              'friendRequestsEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Likes & Comments',
                                        state.socialSettings['likesCommentsEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateSocialSettingsEvent({
                                              'likesCommentsEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Trip Invites',
                                        state.socialSettings['tripInvitesEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateSocialSettingsEvent({
                                              'tripInvitesEnabled': value,
                                            }),
                                          );
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
                                        state.reminderSettings['tripRemindersEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateReminderSettingsEvent({
                                              'tripRemindersEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Booking Alerts',
                                        state.reminderSettings['bookingAlertsEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateReminderSettingsEvent({
                                              'bookingAlertsEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Event Notifications',
                                        state.reminderSettings[
                                        'eventNotificationsEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateReminderSettingsEvent({
                                              'eventNotificationsEnabled': value,
                                            }),
                                          );
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
                                        state.messageSettings['chatNotificationsEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateMessageSettingsEvent({
                                              'chatNotificationsEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Group Updates',
                                        state.messageSettings['groupUpdatesEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateMessageSettingsEvent({
                                              'groupUpdatesEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Support Replies',
                                        state.messageSettings['supportRepliesEnabled'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdateMessageSettingsEvent({
                                              'supportRepliesEnabled': value,
                                            }),
                                          );
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
                                        state.promotionSettings['offersEnabled'] ?? true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdatePromotionSettingsEvent({
                                              'offersEnabled': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'New Features & Updates',
                                        state.promotionSettings['newFeaturesEnabled'] ??
                                            false,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdatePromotionSettingsEvent({
                                              'newFeaturesEnabled': value,
                                            }),
                                          );
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
                                        padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: DropdownButton<String>(
                                                value: state.preferences[
                                                'notificationFrequency'] ??
                                                    'Instant',
                                                isExpanded: true,
                                                underline: const SizedBox(),
                                                dropdownColor:
                                                const Color(0xFF1B0033),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                items: ['Instant', 'Daily', 'Weekly']
                                                    .map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    context
                                                        .read<
                                                        NotificationSettingsBloc>()
                                                        .add(
                                                      UpdatePreferencesEvent({
                                                        'notificationFrequency':
                                                        newValue,
                                                      }),
                                                    );
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
                                        state.preferences['quietHoursEnabled'] ?? false,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdatePreferencesEvent({
                                              'quietHoursEnabled': value,
                                            }),
                                          );
                                        },
                                      ),

                                      if (state.preferences['quietHoursEnabled'] ??
                                          false) ...[
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
                                                      padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.cyanAccent
                                                              .withOpacity(0.5),
                                                        ),
                                                        borderRadius:
                                                        BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        _quietHoursStart
                                                            .format(context),
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
                                                      padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.cyanAccent
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
                                        state.privacySettings[
                                        'showNotificationContent'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdatePrivacySettingsEvent({
                                              'showNotificationContent': value,
                                            }),
                                          );
                                        },
                                      ),
                                      _buildToggleTile(
                                        'Lock Screen Preview',
                                        state.privacySettings['lockScreenPreview'] ??
                                            true,
                                            (value) {
                                          context
                                              .read<
                                              NotificationSettingsBloc>()
                                              .add(
                                            UpdatePrivacySettingsEvent({
                                              'lockScreenPreview': value,
                                            }),
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
                                      onPressed:
                                      state.status ==
                                          NotificationSettingsStatus.loading
                                          ? null
                                          : _saveChanges,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyanAccent,
                                        disabledBackgroundColor:
                                        Colors.cyanAccent.withOpacity(0.5),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: state.status ==
                                          NotificationSettingsStatus.loading
                                          ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text(
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
                              );
                            },
                          ),
                        ),
                      ),
                      // Loading overlay
                      BlocBuilder<NotificationSettingsBloc,
                          NotificationSettingsState>(
                        builder: (context, state) {
                          if (state.status ==
                              NotificationSettingsStatus.loading) {
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