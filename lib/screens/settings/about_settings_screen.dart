import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voyant/blocs/about_settings_bloc/about_settings_bloc.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class AboutSettingsScreen extends StatefulWidget {
  const AboutSettingsScreen({super.key});

  @override
  State<AboutSettingsScreen> createState() => _AboutSettingsScreenState();
}

class _AboutSettingsScreenState extends State<AboutSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load about data when screen initializes
    context.read<AboutSettingsBloc>().add(
      const LoadAboutSettingsEvent(),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _showReleaseNotes(List<Map<String, String>> releaseNotes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Release Notes',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: releaseNotes.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version ${releaseNotes[index]['version']}',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      releaseNotes[index]['date'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      releaseNotes[index]['changes'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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

  void _showDevelopersInfo(List<Map<String, String>> developers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Development Team',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: developers.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      developers[index]['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      developers[index]['role'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      developers[index]['email'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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

  void _showThirdPartyLibraries(List<Map<String, String>> libraries) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Third-Party Libraries',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: libraries.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          libraries[index]['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          libraries[index]['license'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      libraries[index]['description'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
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
      body: AnimatedGradientBackground(
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
                      'About',
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
                    child: BlocBuilder<AboutSettingsBloc, AboutSettingsState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            // App Information Section
                            _buildSectionCard(
                              title: 'App Information',
                              icon: Icons.info,
                              children: [
                                _buildInfoRow('App Name', state.appName),
                                const SizedBox(height: 12),
                                _buildInfoRow('Version', state.appVersion),
                                const SizedBox(height: 12),
                                _buildInfoRow('Build Number', state.buildNumber),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Company Section
                            _buildSectionCard(
                              title: 'Company',
                              icon: Icons.business,
                              children: [
                                const Text(
                                  'About Voyant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.aboutText.isNotEmpty
                                      ? state.aboutText
                                      : 'Voyant is an innovative travel and adventure application designed to connect travelers with unforgettable experiences around the world.',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Mission & Vision',
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${state.mission}\n\n${state.vision}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Developers Section
                            _buildSectionCard(
                              title: 'Developers',
                              icon: Icons.code,
                              children: [
                                _buildActionButton(
                                  'Development Team',
                                  Icons.group,
                                      () => _showDevelopersInfo(state.developers),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Credits',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Special thanks to all our contributors and the open-source community who made this app possible.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Legal Section
                            _buildSectionCard(
                              title: 'Legal',
                              icon: Icons.gavel,
                              children: [
                                _buildActionButton(
                                  'Terms & Conditions',
                                  Icons.description,
                                      () => _launchUrl('https://voyant.com/terms'),
                                ),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                  'Privacy Policy',
                                  Icons.privacy_tip,
                                      () => _launchUrl('https://voyant.com/privacy'),
                                ),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                  'Licenses',
                                  Icons.description,
                                      () => _showThirdPartyLibraries(
                                    state.thirdPartyLibraries,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Updates Section
                            _buildSectionCard(
                              title: 'Updates',
                              icon: Icons.system_update,
                              children: [
                                _buildActionButton(
                                  'What\'s New / Release Notes',
                                  Icons.new_releases,
                                      () => _showReleaseNotes(state.releaseNotes),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Contact Section
                            _buildSectionCard(
                              title: 'Contact',
                              icon: Icons.email,
                              children: [
                                _buildActionButton(
                                  'Website',
                                  Icons.language,
                                      () => _launchUrl('https://voyant.com'),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildSocialIconButton(
                                      Icons.facebook,
                                      'Facebook',
                                          () => _launchUrl(
                                          'https://facebook.com/voyantapp'),
                                    ),
                                    _buildSocialIconButton(
                                      Icons.image,
                                      'Instagram',
                                          () => _launchUrl(
                                          'https://instagram.com/voyantapp'),
                                    ),
                                    _buildSocialIconButton(
                                      Icons.abc,
                                      'Twitter',
                                          () => _launchUrl(
                                          'https://twitter.com/voyantapp'),
                                    ),
                                    _buildSocialIconButton(
                                      Icons.info,
                                      'LinkedIn',
                                          () => _launchUrl(
                                          'https://linkedin.com/company/voyant'),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Acknowledgements Section
                            _buildSectionCard(
                              title: 'Acknowledgements',
                              icon: Icons.favorite,
                              children: [
                                _buildActionButton(
                                  'Third-Party Libraries',
                                  Icons.library_books,
                                      () => _showThirdPartyLibraries(
                                    state.thirdPartyLibraries,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Partners & Contributors',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '• Google Maps for location services\n• Firebase for backend infrastructure\n• Flutter community for continuous support',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Copyright Notice
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.cyanAccent.withOpacity(0.3),
                                ),
                              ),
                              child: const Text(
                                '© 2026 Voyant. All rights reserved.\nMade with ❤️ for travelers.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
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

  Widget _buildActionButton(
      String label,
      IconData icon,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: const Color(0xFF1B0033),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton(
      IconData icon,
      String label,
      VoidCallback onPressed,
      ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.cyanAccent,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.cyanAccent,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}