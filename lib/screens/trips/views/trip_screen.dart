import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyant/screens/quest/views/quests_list_screen.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  final String tripName;
  const TripDetailScreen({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  static const String baseUrl = 'https://api-cbmysz2x4a-uc.a.run.app/api';

  List<dynamic> quests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTripData();
  }

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<void> _loadTripData() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/quests/trip/${widget.tripId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          quests = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // calculate stats from real quest data
    final totalQuests = quests.length;
    final completedQuests = quests
        .where((q) => q['userStatus'] == 'completed')
        .length;
    final totalTasks = quests.fold<int>(
      0,
      (sum, q) => sum + ((q['tasks'] as List?)?.length ?? 0),
    );
    final completedTasks = quests.fold<int>(
      0,
      (sum, q) => sum + ((q['tasksCompleted'] as int?) ?? 0),
    );
    final totalXP = quests.fold<int>(
      0,
      (sum, q) => sum + ((q['totalXP'] as int?) ?? 0),
    );
    final progress = totalQuests == 0 ? 0.0 : completedQuests / totalQuests;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) => Navigator.pop(context),
        backgroundColor: const Color(0xFF12121A),
        selectedItemColor: const Color(0xFFB020DD),
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: "Trips",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Map"),
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: "Inventory",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Avatar"),
        ],
      ),
      body: AnimatedGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    widget.tripName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFB020DD)),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // DASHBOARD
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 180,
                                  width: 180,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 15,
                                    backgroundColor: const Color(0xFF1E2A3A),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.greenAccent,
                                        ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${(progress * 100).toInt()}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Progress',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStat(
                                  Icons.flag,
                                  Colors.orange,
                                  'Quests',
                                  '$completedQuests / $totalQuests',
                                ),
                                const SizedBox(height: 16),
                                _buildStat(
                                  Icons.task_alt,
                                  Colors.greenAccent,
                                  'Tasks',
                                  '$completedTasks / $totalTasks',
                                ),
                                const SizedBox(height: 16),
                                _buildStat(
                                  Icons.military_tech,
                                  Colors.amber,
                                  'Badges',
                                  '0 / 0',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // XP BANNER
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF551161), Color(0xFF1A0A2E)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFB020DD).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total XP Reward',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$totalXP XP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // NAVIGATION
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuestsListScreen(tripId: widget.tripId),
                          ),
                        ),
                        child: _buildNavigationRow(
                          "Quests",
                          "View all active quests",
                        ),
                      ),
                      const Divider(height: 1, thickness: 0),
                      _buildNavigationRow(
                        "Tasks",
                        "Check off your daily items",
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationRow(String title, String subtitle) {
    return Container(
      color: Colors.white.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
