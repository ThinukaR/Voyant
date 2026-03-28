import 'package:flutter/material.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';
import '../components/settings_tile.dart';
import 'account_settings_screen.dart';
import 'notification_settings_screen.dart';
import '../settings/appearance_settings_screen.dart';
import '../settings/privacy_security_settings_screen.dart';
import '../settings/help_support_settings_screen.dart';
import 'about_settings_screen.dart';

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
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Header with back navigation.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        "Settings",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
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
                          } else if (title == "Help & Support") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpSupportSettingsScreen(),
                              ),
                            );
                          } else if (title == "About") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutSettingsScreen(),
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
            ],
          ),
        ),
      ),
    );
  }
}