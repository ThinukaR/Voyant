import 'package:flutter/material.dart';
import 'components/settings_tile.dart';
import 'account_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'appearance_settings_screen.dart';
import 'privacy_security_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsItems = [
      {"title": "Account", "icon": Icons.person_outline},
      {"title": "Notifications", "icon": Icons.notifications_none},
      {"title": "Appearance", "icon": Icons.remove_red_eye_outlined},
      {"title": "Privacy & Security", "icon": Icons.lock_outline},
      {"title": "Help & Support", "icon": Icons.headset_mic_outlined},
      {"title": "About", "icon": Icons.info_outline},
    ];

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
              const SizedBox(height: 20),

              // Title
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Card Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.cyanAccent,
                      width: 1,
                    ),
                  ),
                  child: ListView.separated(
                    itemCount: settingsItems.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.white.withOpacity(0.2),
                      indent: 20,
                      endIndent: 20,
                    ),
                    itemBuilder: (context, index) {
                      String title = settingsItems[index]["title"] as String;
                      return SettingsTile(
                        icon: settingsItems[index]["icon"] as IconData,
                        title: title,
                        onTap: () {
                          if (title == "Account") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountSettingsScreen(),
                              ),
                            );
                          } else if (title == "Notifications") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationSettingsScreen(),
                              ),
                            );
                          } else if (title == "Appearance") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppearanceSettingsScreen(),
                              ),
                            );
                          } else if (title == "Privacy & Security") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacySecuritySettingsScreen(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Button (Map icon style)
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A1B9A),
                      Color(0xFFAB47BC),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}