import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';
import '../../../models/quest_models.dart';
import '../../../services/quest_service.dart';
import '../../../components/quest_dialogue_widget.dart';

class QuestScreen extends StatefulWidget {
  final Quest quest;
  final QuestProgress? initialProgress;

  const QuestScreen({
    super.key,
    required this.quest,
    this.initialProgress,
  });

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  QuestProgress? _currentProgress;
  Task? _currentTask;
  List<Task> _availableTasks = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestData();
  }

  Future<void> _loadQuestData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      //existing prorgess is used or new progress is made
      if (widget.initialProgress != null) {
        _currentProgress = widget.initialProgress;
      } else {
        //creates empty prorgess for new quests 
        _currentProgress = null;
      }

      _updateAvailableTasks();
      _findNextUncompletedTask();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateAvailableTasks() {
    _availableTasks = widget.quest.tasks.where((task) => !task.isLocked).toList();
  }

  Task? _findNextUncompletedTask() {
    if (_currentProgress != null) {
      final completedTaskIds = _currentProgress!.taskProgress
          .where((tp) => tp.isCompleted)
          .map((tp) => tp.taskId)
          .toSet();

      for (final task in _availableTasks) {
        if (!completedTaskIds.contains(task.id)) {
          _currentTask = task;
          return _currentTask;
        }
      }
    }

    _currentTask = _availableTasks.isNotEmpty ? _availableTasks.first : null;
    return _currentTask;
  }

  Future<void> _completeTask(String taskId) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await QuestService().completeTask(
        widget.quest.id,
        taskId,
        <String, dynamic>{},
      );

      if (result['passed'] == true) {

        //refreshing progress
        await _loadQuestData();
      } else {
        setState(() {
          _error = result['reason'] ?? 'Task completion failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _processDialogueChoice(String choice, String? nextDialogueId) {
    //handling dialogue choices
    print('Choice: $choice, Next: $nextDialogueId');
  }

  //conroller for text inputs
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedGradientBackground(
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFFB020DD)),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedGradientBackground(
          child: Center(
            child: Text(_error!, style: const TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.quest.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(height: 6),
                    // status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        widget.quest.userStatus == 'completed'
                            ? 'Completed'
                            : 'In Progress',
                        style: TextStyle(
                          color: widget.quest.userStatus == 'completed'
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildQuestBody(),
              ),
            ],
          ),
      ),
        ),
    );
  }

  Widget _buildQuestBody() {
    if (_currentTask == null) {
      return const Center(
        child: Text(
          'No available tasks',
          style: TextStyle(
            color: Color(0xFFB3B3B3),
            fontSize: 18,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest info card for the active task.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4A148C).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentTask!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentTask!.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.task_alt,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Task ${_availableTasks.indexOf(_currentTask!) + 1} of ${_availableTasks.length}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.star,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentTask!.xpReward} XP',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTaskContent(),
          const SizedBox(height: 24),
          if (_currentTask!.type != 'dialogue')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _completeTask(_currentTask!.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A148C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Complete Task',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskContent() {
    switch (_currentTask!.type) {
      case 'multiple_choice':
        return _buildMultipleChoiceTask();
      case 'dialogue':
        return _buildDialogueTask();
      case 'geofence':
        return _buildGeofenceTask();
      case 'checkin':
        return _buildCheckinTask();
      case 'number_input':
        return _buildNumberInputTask();
      case 'string_input':
        return _buildStringInputTask();
      case 'true_false':
        return _buildTrueFalseTask();
      default:
        return _buildDefaultTask();
    }
  }

  Widget _buildMultipleChoiceTask() {
    final options = _currentTask!.taskData?['options'] ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentTask!.taskData?['question'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: () => _completeTask(_currentTask!.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                option['text'] ?? 'Option',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDialogueTask() {
    final dialogueData = _currentTask!.taskData?['dialogueData'];
    if (dialogueData == null) {
      return const Text(
        'No dialogue available',
        style: TextStyle(color: Colors.white),
      );
    }

    return QuestDialogueWidget(
      npcName: dialogueData['npcName'] ?? 'Unknown',
      npcAvatar: dialogueData['npcAvatar'],
      dialogueText: dialogueData['dialogueText'] ?? 'No dialogue available',
      emotion: dialogueData['emotion'] ?? 'neutral',
      options: (dialogueData['options'] as List<dynamic>?)
          ?.map((option) => option as Map<String, dynamic>)
          .toList() ?? [],
      onChoiceSelected: (choice, {String? nextDialogueId}) {
        _processDialogueChoice(choice, nextDialogueId);
      },
    );
  }

  Widget _buildGeofenceTask() {
    final geofenceData = _currentTask!.taskData?['geofenceData'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Location Task',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (geofenceData?['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              geofenceData['description'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckinTask() {
    final checkinData = _currentTask!.taskData?['checkinData'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Check-in Task',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (checkinData?['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              checkinData['description'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStringInputTask() {
    final inputData = _currentTask!.taskData;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inputData?['question'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your answer',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeTask(_currentTask!.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A148C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputTask() {
    final inputData = _currentTask!.taskData;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inputData?['question'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter a number',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeTask(_currentTask!.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A148C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrueFalseTask() {
    final inputData = _currentTask!.taskData;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inputData?['question'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _completeTask(_currentTask!.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('True'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _completeTask(_currentTask!.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('False'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultTask() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Task',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentTask!.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getTaskTypeLabel(String taskType) {
    switch (taskType) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'dialogue':
        return 'Dialogue';
      case 'geofence':
        return 'Location Task';
      case 'checkin':
        return 'Check-in';
      case 'number_input':
        return 'Number Input';
      case 'string_input':
        return 'Text Input';
      case 'true_false':
        return 'True/False';
      default:
        return 'Task';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
