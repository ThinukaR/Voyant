import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voyant/screens/referral_system/refer_screen.dart';
import 'package:voyant/screens/settings_screen.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';
import 'package:voyant/screens/profile/views/profile_screen.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onTripsTap;
  const HomeTab({super.key, required this.onTripsTap});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const String baseUrl = 'http://192.168.8.148:3000/api';

  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<void> _loadStats() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/stats/home'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          stats = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Stats error: $e');
      setState(() => isLoading = false);
    }
  }

  // level starts at 0, every 1000 XP = 1 level
  int _getLevel(int xp) => (xp / 1000).floor();
  int _getXPForNextLevel(int xp) => 1000 - (xp % 1000);
  double _getLevelProgress(int xp) => (xp % 1000) / 1000;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          // StreamBuilder listens to Firestore in realtime
          // whenever XP or level updates, the UI updates automatically
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final username = userData?['username'] ?? 'Explorer';
              final totalXP = (userData?['totalXP'] ?? 0) as int;
              final level = _getLevel(totalXP);
              final xpToNext = _getXPForNextLevel(totalXP);
              final levelProgress = _getLevelProgress(totalXP);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.card_giftcard, color: Color(0xFFB020DD)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ReferScreenView(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings, color: Color(0xFFB020DD)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                            // profile icon — tap to go to profile page
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          ),
                          child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFB020DD), Color(0xFF551161)],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFB020DD),
                                width: 2,
                              ),
                                ),
                                child: const Icon(
                              Icons.person,
                                  color: Colors.white,
                              size: 30,
                            ),
                          ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // XP + LEVEL CARD — connected to Firestore realtime
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF551161), Color(0xFF1A0A2E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFB020DD)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Explorer Level',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB020DD),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'LVL $level',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalXP XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: levelProgress,
                              minHeight: 8,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFB020DD),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$xpToNext XP to Level ${level + 1}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // STATS ROW — from backend
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFB020DD),
                            ),
                          )
                        : Row(
                            children: [
                              _buildStatCard(
                                Icons.flag,
                                Colors.orange,
                                '${stats?['questCount'] ?? 0}',
                                'Quests',
                                null,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                Icons.luggage,
                                const Color(0xFFB020DD),
                                '${stats?['tripCount'] ?? 0}',
                                'Trips',
                                widget.onTripsTap,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                Icons.military_tech,
                                Colors.amber,
                                '0',
                                'Badges',
                                null,
                              ),
                            ],
                          ),

                    const SizedBox(height: 24),

                    // ACTIVE TRIP — from backend
                    const Text(
                      'Active Trip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    isLoading
                        ? const SizedBox()
                        : stats?['activeTrip'] == null
                        ? const Text(
                            'No active trip',
                            style: TextStyle(color: Colors.white54),
                          )
                        : Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12121A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFB020DD),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stats!['activeTrip']['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Active',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value:
                                        stats!['activeTrip']['totalQuests'] == 0
                                        ? 0
                                        : stats!['activeTrip']['completedQuests'] /
                                              stats!['activeTrip']['totalQuests'],
                                    minHeight: 6,
                                    backgroundColor: Colors.white12,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.green,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${stats!['activeTrip']['completedQuests']}/${stats!['activeTrip']['totalQuests']} quests completed',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Color color,
    String value,
    String label,
    VoidCallback? onTap,
  ) {
    Widget card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(108, 70, 0, 145),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A0A2E)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );

    if (onTap != null) {
      return Expanded(
        child: GestureDetector(onTap: onTap, child: card),
      );
    }
    return Expanded(child: card);
  }
}
