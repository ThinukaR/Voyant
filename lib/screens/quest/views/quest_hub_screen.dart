import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'quest_map_screen.dart';
import '../map/map.dart';

class QuestHubScreen extends StatefulWidget {
  final String userId;

  const QuestHubScreen({super.key, required this.userId});

  @override
  State<QuestHubScreen> createState() => _QuestHubScreenState();
}

class _QuestHubScreenState extends State<QuestHubScreen> {
  List<MainQuest> _availableQuests = [];
  Map<String, dynamic> _userProgress = {};
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

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/main-quests/user/${widget.userId}/available'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _availableQuests = (data['availableQuests'] as List)
              .map((quest) => MainQuest.fromJson(quest))
              .toList();
          _userProgress = data['userProgress'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load quests: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  

  Future<void> _startQuest(MainQuest quest) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/main-quests/start'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'userId': widget.userId,
          'mainQuestId': quest.id,
        }),
      );

      if (response.statusCode == 201) {
        //navigating to the quest 
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainQuestScreen(
              userId: widget.userId,
              mainQuestId: quest.id,
            ),
          ),
        );
      } else {
        throw Exception('Failed to start quest: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting quest: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resumeQuest(MainQuest quest) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MainQuestScreen(
          userId: widget.userId,
          mainQuestId: quest.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              : _availableQuests.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.explore_off,
                            size: 64,
                            color: Colors.white70,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No quests available',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Complete prerequisites to unlock more quests',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _availableQuests.length,
                      itemBuilder: (context, index) {
                        final quest = _availableQuests[index];
                        final progress = _userProgress[quest.id];
                        
                        return _buildQuestCard(quest, progress);
                      },
                    ),
    );
  }

  Widget _buildQuestCard(MainQuest quest, dynamic progress) {
    final isInProgress = progress != null && progress['status'] == 'in_progress';
    final isCompleted = progress != null && progress['status'] == 'completed';

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
                  child: const Icon(
                    Icons.explore,
                    color: Color(0xFF4A148C),
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
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.5),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            quest.location.toUpperCase(),
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
                            quest.estimatedDuration,
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
                          'Progress: ${progress['currentSubQuestIndex'] + 1}/${quest.totalSubQuests}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (progress['currentSubQuestIndex'] + 1) / quest.totalSubQuests,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A148C)),
                        ),
                      ],
                    ),
                  ),
                


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
                  ElevatedButton(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}