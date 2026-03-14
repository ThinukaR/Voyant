import 'package:flutter/material.dart';

class QuestDisplaySection extends StatelessWidget {
  const QuestDisplaySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Completed Quests",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildSimpleQuestBox(
                title: "Galle Track",
                icon: Icons.terrain,
              ),
              const SizedBox(height: 12),
              _buildSimpleQuestBox(
                title: "Exploring Fort",
                icon: Icons.map,
              ),
              const SizedBox(height: 12),
              _buildSimpleQuestBox(
                title: "Sightseeing",
                icon: Icons.camera,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleQuestBox({
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
