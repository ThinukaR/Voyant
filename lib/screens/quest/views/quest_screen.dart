import 'dart:async';
import 'package:flutter/material.dart';
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
      
      _currentTask = _availableTasks.firstWhere(
        (task) => !completedTaskIds.contains(task.id),
        orElse: () => _availableTasks.isNotEmpty ? _availableTasks.first : null as Task,
      );
    } else {
      _currentTask = _availableTasks.isNotEmpty ? _availableTasks.first : null as Task;
    }
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
    return Scaffold(
      backgroundColor: const Color(0xFF1B0330),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 0,
        title: Text(
          widget.quest.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A148C)),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: const Color(0xFF4A148C),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading quest',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
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
                                    onPressed: _loadQuestData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4A148C),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _currentTask == null
                            ? const Center(
                                child: Text(
                                  'No available tasks',
                                  style: TextStyle(
                                    color: Color(0xFFB3B3B3),
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    //quest info 
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
                                            _currentTask!.description ?? '',
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

                                    //task content
                                    _buildTaskContent(),

                                    const SizedBox(height: 24),

                                    //complete task ( the button for it )
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
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : const Text(
                                                  'Complete Task',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
              ),
            ),
          );
        },
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
            _currentTask!.description ?? '',
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
