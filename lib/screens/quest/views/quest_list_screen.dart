import 'package:flutter/material.dart';
import '../../../models/quest_models.dart';
import '../../../services/quest_service.dart';
import '../../../widgets/animated_gradient_background.dart';
import './quest_start_screen.dart';
import './quest_screen.dart';

class QuestsListScreen extends StatefulWidget {
  final String tripId;
  const QuestsListScreen({super.key, required this.tripId});
  @override
  State<QuestsListScreen> createState() => _QuestsListScreenState();
}

class _QuestsListScreenState extends State<QuestsListScreen> {
  List<Quest> _quests = [];
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final quests = await QuestService().getQuestsForTrip(widget.tripId);
      setState(() {
        _quests = quests;
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuestStartScreen(
        questTitle: quest.title,
        questId: quest.id,
        onQuestStarted: () async {
          try {
            final progress = await QuestService().startQuest(quest.id);
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      QuestScreen(quest: quest, initialProgress: progress),
                ),
              );

              if (changed == true) {
                await _loadQuests(); // whatever your function is called
              }
            }
          } catch (e) {
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('Error starting quest: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _resumeQuest(Quest quest) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            QuestScreen(quest: quest, initialProgress: quest.progress),
      ),
    );

    if (changed == true) {
      await _loadQuests();
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
            'Quests',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB020DD)),
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
                      onPressed: _loadQuests,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A148C),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _quests.isEmpty
            ? const Center(
                child: Text(
                  'No quests available for this trip',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _quests.length,
                itemBuilder: (context, index) {
                  final quest = _quests[index];
                  return _buildQuestCard(quest);
                },
              ),
      ),
    );
  }

  Widget _buildQuestCard(Quest quest) {
    final isInProgress = quest.isInProgress;
    final isCompleted = quest.isCompleted;
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A148C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Color(0xFF4A148C),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quest.totalXP} XP',
                  style: const TextStyle(
                    color: Color(0xFFB020DD),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
