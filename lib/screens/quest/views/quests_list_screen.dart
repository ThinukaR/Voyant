import 'package:flutter/material.dart';
import 'package:voyant/screens/quest/views/quest_screen.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class QuestsListScreen extends StatelessWidget {
  const QuestsListScreen({super.key});

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // active / completed quests
                      const Text(
                        'Active Quests',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildQuestCard(
                        context,
                        'Museum Explorer',
                        'Galle Fort Museum',
                        300,
                        'Ongoing',
                        false,
                      ),
                      _buildQuestCard(
                        context,
                        'Street Food Hunt',
                        'Colombo City',
                        150,
                        'Completed',
                        false,
                      ),

                      const SizedBox(height: 12),

                      // not started quests
                      const Text(
                        "Not Started",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildQuestCard(
                        context,
                        'Fort Walls Walk',
                        'Galle Fort',
                        200,
                        'Locked',
                        true,
                      ),
                      _buildQuestCard(
                        context,
                        'Lighthouse Visit',
                        'Galle Coast',
                        250,
                        'Locked',
                        true,
                      ),
                      _buildQuestCard(
                        context,
                        'Colonial Tour',
                        'Colombo Fort',
                        400,
                        'Locked',
                        true,
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

  Widget _buildQuestCard(
    BuildContext context,
    String title,
    String location,
    int xp,
    String status,
    bool isLocked,
  ) {
    // setting color based on status
    Color statusColor = Colors.white54;
    if (status == 'Ongoing') statusColor = Colors.greenAccent;
    if (status == 'Completed') statusColor = Colors.blue;
    if (status == 'Locked') statusColor = Colors.white38;

    // setting up icon based on status
    IconData statusIcon = Icons.lock;
    if (status == 'Ongoing') statusIcon = Icons.explore;
    if (status == 'Completed') statusIcon = Icons.check_circle;

    // making the card
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          // xp badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$xp XP',
              style: TextStyle(color: statusColor, fontSize: 11),
            ),
          ),
        ],
      ),
    );

    if (isLocked) {
      return Opacity(opacity: 0.5, child: card);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuestScreen()),
        );
      },
      child: card,
    );
  }
}
