import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyant/screens/quest/views/quest_screen.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class QuestsListScreen extends StatefulWidget {
  final String tripId;
  const QuestsListScreen({super.key, required this.tripId});

  @override
  State<QuestsListScreen> createState() => _QuestsListScreenState();
}

class _QuestsListScreenState extends State<QuestsListScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  List<dynamic> quests = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<void> _loadQuests() async {
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
        setState(() {
          error = 'Failed to load quests';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
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
                    const SizedBox(width: 16),
                    const Text(
                      'Quests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // content
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB020DD),
                        ),
                      )
                    : error != null
                    ? Center(
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : quests.isEmpty
                    ? const Center(
                        child: Text(
                          'No quests yet',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // active quests
                            _buildSection(
                              'Active Quests',
                              quests
                                  .where((q) => q['userStatus'] == 'active')
                                  .toList(),
                              Colors.white,
                            ),

                            // not started
                            _buildSection(
                              'Not Started',
                              quests
                                  .where(
                                    (q) => q['userStatus'] == 'not_started',
                                  )
                                  .toList(),
                              Colors.white54,
                            ),

                            // completed
                            _buildSection(
                              'Completed',
                              quests
                                  .where((q) => q['userStatus'] == 'completed')
                                  .toList(),
                              Colors.white54,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<dynamic> sectionQuests,
    Color titleColor,
  ) {
    if (sectionQuests.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...sectionQuests.map((q) => _buildQuestCard(q)).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuestCard(Map<String, dynamic> quest) {
    final status = quest['userStatus'] ?? 'not_started';
    final tasksCompleted = quest['tasksCompleted'] ?? 0;
    final totalTasks = (quest['tasks'] as List?)?.length ?? 0;

    Color statusColor = Colors.white54;
    IconData statusIcon = Icons.explore;

    if (status == 'active') {
      statusColor = Colors.greenAccent;
      statusIcon = Icons.explore;
    } else if (status == 'completed') {
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.white38;
      statusIcon = Icons.lock;
    }

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$tasksCompleted/$totalTasks tasks',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${quest['totalXP']} XP',
              style: TextStyle(color: statusColor, fontSize: 11),
            ),
          ),
        ],
      ),
    );

    if (status == 'not_started' ||
        status == 'active' ||
        status == 'completed') {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestScreen(questId: quest['_id']),
            ),
          );
        },
        child: card,
      );
    }

    return Opacity(opacity: 0.5, child: card);
  }
}
