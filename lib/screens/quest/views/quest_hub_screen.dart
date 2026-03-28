import 'package:flutter/material.dart';
import '../../../models/quest_models.dart';
import '../../../services/quest_service.dart';
import './quest_screen.dart';
import './quest_start_screen.dart';
import '../../../../widgets/animated_gradient_background.dart';

class QuestHubScreen extends StatefulWidget {
  final String userId;

  const QuestHubScreen({
    super.key,
    required this.userId,
  });

  @override
  State<QuestHubScreen> createState() => _QuestHubScreenState();
}

class _QuestHubScreenState extends State<QuestHubScreen> {
  List<Quest> _mainQuests = [];
  List<Quest> _tripQuests = [];
  List<Quest> _locationQuests = [];
  List<Quest> _npcQuests = [];
  List<dynamic> _trips = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableQuests();
  }

  Future<void> _loadAvailableQuests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final questResponse = await QuestService().getAllUserQuests();
      
      setState(() {
        _mainQuests = questResponse.mainQuests;
        _tripQuests = questResponse.tripQuests;
        _locationQuests = questResponse.locationQuests;
        _npcQuests = questResponse.npcQuests;
        _trips = questResponse.trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _startQuest(Quest quest) async {
    try {
      //quest start animation 
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => QuestStartScreen(
          questTitle: quest.title,
          questId: quest.id,
          onQuestStarted: () async {

            //quest starts after animation 
            try {
              final progress = await QuestService().startQuest(quest.id);
              
              //navigating to quest screen 
              if (context.mounted) {
                Navigator.of(context).pop(); 
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuestScreen(
                      quest: quest,
                      initialProgress: progress,
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error starting quest: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting quest: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resumeQuest(Quest quest) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestScreen(
          quest: quest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: const Color(0xFF1B0330),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A148C),
          elevation: 0,
          title: const Text(
            'Quest Hub',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _error != null
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
                        const Text(
                          'Error loading quests',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadAvailableQuests,
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
                    child: Column(
                      children: [

                        //main quest selection 

                        if (_mainQuests.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Main Quests',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final quest in _mainQuests) 
                                  _buildQuestCard(quest, null),
                              ],
                            ),
                          ),
                        ],
                        
                        //trip quests 
                        if (_tripQuests.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Trip Quests',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final quest in _tripQuests) 
                                  _buildQuestCard(quest, null),
                              ],
                            ),
                          ),
                        ],
                        
                        //location uests 
                        if (_locationQuests.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Location Quests',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final quest in _locationQuests) 
                                  _buildQuestCard(quest, null),
                              ],
                            ),
                          ),
                        ],
                        
                        //NPC quests 
                        if (_npcQuests.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'NPC Quests',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final quest in _npcQuests) 
                                  _buildQuestCard(quest, null),
                              ],
                            ),
                          ),
                        ],
                        
                        
                        if (_mainQuests.isEmpty && 
                            _tripQuests.isEmpty && 
                            _locationQuests.isEmpty && 
                            _npcQuests.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'No quests available',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
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

  Widget _buildQuestCard(Quest quest, QuestProgress? progress) {
    final isInProgress = progress?.status == 'in_progress';
    final isCompleted = progress?.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A148C).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                //quest icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A148C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getQuestIcon(quest.questType),
                    color: const Color(0xFF4A148C),
                    size: 30,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                //quest info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _getQuestTypeIcon(quest.questType),
                            color: Colors.white.withOpacity(0.5),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getQuestTypeLabel(quest.questType),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.schedule,
                            color: Colors.white.withOpacity(0.5),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            quest.estimatedDuration ?? 'No time limit',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      //Progress and XP
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white.withOpacity(0.5),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${quest.totalXP} XP',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${progress?.totalXPEarned ?? 0}/${quest.totalXP} XP',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            //For progress and actions
            Row(
              children: [
                //progress indicator
                if (isInProgress)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress: ${progress?.tasksCompleted ?? 0}/${quest.tasks.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (progress?.tasksCompleted ?? 0) / quest.tasks.length,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A148C)),
                        ),
                      ],
                    ),
                  ),
                
                //completed status
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isInProgress 
                          ? () => _resumeQuest(quest)
                          : () => _startQuest(quest),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A148C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(isInProgress ? 'RESUME' : 'START'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //helper methods for quest type icons and labels
  IconData _getQuestIcon(String questType) {
    switch (questType) {
      case 'main_quest':
        return Icons.campaign;
      case 'trip_quest':
        return Icons.card_travel;
      case 'location_quest':
        return Icons.location_on;
      case 'npc_quest':
        return Icons.person;
      default:
        return Icons.explore;
    }
  }

  String _getQuestTypeLabel(String questType) {
    switch (questType) {
      case 'main_quest':
        return 'Main Quest';
      case 'trip_quest':
        return 'Trip Quest';
      case 'location_quest':
        return 'Location Quest';
      case 'npc_quest':
        return 'NPC Quest';
      default:
        return 'Quest';
    }
  }

  IconData _getQuestTypeIcon(String questType) {
    switch (questType) {
      case 'main_quest':
        return Icons.campaign;
      case 'trip_quest':
        return Icons.card_travel;
      case 'location_quest':
        return Icons.location_on;
      case 'npc_quest':
        return Icons.person;
      default:
        return Icons.explore;
    }
  }
}
