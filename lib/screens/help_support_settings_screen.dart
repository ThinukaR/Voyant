import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportSettingsScreen extends StatefulWidget {
  const HelpSupportSettingsScreen({super.key});

  @override
  State<HelpSupportSettingsScreen> createState() =>
      _HelpSupportSettingsScreenState();
}

class _HelpSupportSettingsScreenState extends State<HelpSupportSettingsScreen> {
  final String appVersion = '1.0.0';

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I reset my password?',
      'answer':
          'Go to the login screen and tap "Forgot Password". Enter your email and follow the instructions sent to your inbox.'
    },
    {
      'question': 'How do I enable Two-Factor Authentication?',
      'answer':
          'Navigate to Settings > Privacy & Security > Account Security, and toggle on Two-Factor Authentication.'
    },
    {
      'question': 'Can I change my profile picture?',
      'answer':
          'Yes, go to Settings > Account Settings and tap on your profile picture to upload a new one.'
    },
    {
      'question': 'How do I block a user?',
      'answer':
          'Visit Settings > Privacy & Security > Block & Safety to manage blocked users.'
    },
    {
      'question': 'How do I download my data?',
      'answer':
          'Go to Settings > Privacy & Security > Data Protection and tap "Download My Data".'
    },
  ];

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _showFAQs() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'FAQs',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(
                    _faqs[index]['question'] ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                  childrenPadding: const EdgeInsets.all(12),
                  children: [
                    Text(
                      _faqs[index]['answer'] ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
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

  void _submitSupportTicket() {
    TextEditingController subjectController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Submit Support Ticket',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Subject',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your issue...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
              ],
            ),
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
                    content: Text('Support ticket submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child:
                  const Text('Submit', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  void _reportBug() {
    TextEditingController bugDescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Report a Bug',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bugDescriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Describe the bug and steps to reproduce it...',
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
              ],
            ),
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
                    content: Text('Bug report submitted. Thank you!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Submit', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _sendFeedback() {
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Send Feedback',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: feedbackController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Share your suggestions and feedback...',
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
              ],
            ),
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
                    content: Text('Feedback sent! We appreciate your input.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Send', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int rating = 5;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1B0033),
              title: const Text(
                'Rate Our App',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How would you rate Voyant?',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() => rating = index + 1);
                        },
                        child: Icon(
                          Icons.star,
                          size: 40,
                          color: index < rating
                              ? Colors.amber
                              : Colors.white30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$rating out of 5 stars',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for rating Voyant!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.cyanAccent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _checkForUpdates() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B0033),
          title: const Text(
            'Check for Updates',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'You are running the latest version (1.0.0)',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
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
                      'Help & Support',
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
                        // Help Center Section
                        _buildSectionCard(
                          title: 'Help Center',
                          icon: Icons.help,
                          children: [
                            _buildActionButton(
                              'FAQs',
                              Icons.question_answer,
                              _showFAQs,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Guides & Tutorials',
                              Icons.school,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening tutorials...'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Contact Support Section
                        _buildSectionCard(
                          title: 'Contact Support',
                          icon: Icons.support_agent,
                          children: [
                            _buildActionButton(
                              'Submit Support Ticket',
                              Icons.description,
                              _submitSupportTicket,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Email Support',
                              Icons.email,
                              () {
                                _launchUrl(
                                    'mailto:support@voyant.com?subject=Support');
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Report Issues Section
                        _buildSectionCard(
                          title: 'Report Issues',
                          icon: Icons.bug_report,
                          children: [
                            _buildActionButton(
                              'Report Bug',
                              Icons.error,
                              _reportBug,
                              isDestructive: true,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Report User/Content',
                              Icons.flag,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Report submitted for review.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              isDestructive: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Feedback Section
                        _buildSectionCard(
                          title: 'Feedback',
                          icon: Icons.feedback,
                          children: [
                            _buildActionButton(
                              'Send Feedback',
                              Icons.edit,
                              _sendFeedback,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Rate the App',
                              Icons.star,
                              _rateApp,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Account Help Section
                        _buildSectionCard(
                          title: 'Account Help',
                          icon: Icons.account_circle,
                          children: [
                            _buildActionButton(
                              'Login Issues',
                              Icons.lock,
                              () {
                                _launchUrl(
                                    'https://voyant.com/help/login-issues');
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Password Reset',
                              Icons.vpn_key,
                              () {
                                _launchUrl(
                                    'https://voyant.com/help/password-reset');
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Account Recovery',
                              Icons.restore,
                              () {
                                _launchUrl(
                                    'https://voyant.com/help/account-recovery');
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Legal & Policies Section
                        _buildSectionCard(
                          title: 'Legal & Policies',
                          icon: Icons.gavel,
                          children: [
                            _buildActionButton(
                              'Terms & Conditions',
                              Icons.description,
                              () {
                                _launchUrl('https://voyant.com/terms');
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Privacy Policy',
                              Icons.privacy_tip,
                              () {
                                _launchUrl('https://voyant.com/privacy');
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Community Guidelines',
                              Icons.group,
                              () {
                                _launchUrl(
                                    'https://voyant.com/community-guidelines');
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // App Info Section
                        _buildSectionCard(
                          title: 'App Info',
                          icon: Icons.info,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'App Version',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  appVersion,
                                  style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Check for Updates',
                              Icons.system_update,
                              _checkForUpdates,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
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
}
