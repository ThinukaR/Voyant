import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/quest_models.dart';
import '../../../services/quest_service.dart';
import '../../quest/views/quest_hub_screen.dart';
import '../../../widgets/animated_gradient_background.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  List<dynamic> trips = [];
  List<Quest> mainQuests = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTripsAndQuests();
  }

  Future<void> _loadTripsAndQuests() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      //uses quest service to load quest 
      final questResponse = await QuestService().getAllUserQuests();
      
      setState(() {
        mainQuests = questResponse.mainQuests;
        trips = questResponse.trips;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Trips & Quests',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadTripsAndQuests,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A148C),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        //main quest section 
                        if (mainQuests.isNotEmpty) ...[
                          const Text(
                            'Main Quests',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...mainQuests.map((quest) => _buildQuestCard(quest)),
                          const SizedBox(height: 24),
                        ],
                        
                        //trips 
                        if (trips.isNotEmpty) ...[
                          const Text(
                            'Trips',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...trips.map((trip) => _buildTripCard(trip)),
                        ],
                        
                        //View all quests 
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const QuestHubScreen(
                                    userId: 'current-user', 
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A148C),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('View All Quests'),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildQuestCard(Quest quest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A148C).withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4A148C).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.campaign,
            color: Color(0xFF4A148C),
          ),
        ),
        title: Text(
          quest.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          quest.description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        trailing: Text(
          '${quest.totalXP} XP',
          style: const TextStyle(
            color: Color(0xFF4A148C),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const QuestHubScreen(
                userId: 'current-user',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripCard(dynamic trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A148C).withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4A148C).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.card_travel,
            color: Color(0xFF4A148C),
          ),
        ),
        title: Text(
          trip['tripName'] ?? 'Unknown Trip',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          trip['description'] ?? 'No description',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const QuestHubScreen(
                userId: 'current-user',
              ),
            ),
          );
        },
      ),
    );
  }
}
