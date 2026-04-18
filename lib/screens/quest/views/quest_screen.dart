import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';
import '../../../models/quest_models.dart';
import '../../../services/quest_service.dart';
import '../../../components/quest_dialogue_widget.dart';

class QuestScreen extends StatefulWidget {
  final Quest quest;
  final QuestProgress? initialProgress;

  const QuestScreen({super.key, required this.quest, this.initialProgress});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  QuestProgress? _currentProgress;
  Task? _currentTask; // used as a scratch variable by _buildTaskContentFor
  bool _isLoading = false;
  String? _error;
  String? taskId;
  bool _progressChanged = false;

  // controller for text inputs
  final _controller = TextEditingController();

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

      // Always refresh progress from server so UI advances correctly.
      // If server says "not started", progress will be null.
      _currentProgress = await QuestService().getQuestProgress(widget.quest.id);

      // If we were launched with initialProgress (from pressing START),
      // use it as a fallback in case the server hasn't updated yet.
      _currentProgress ??= widget.initialProgress;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Set<String> _completedTaskIds() {
    return _currentProgress?.taskProgress
            .where((tp) => tp.isCompleted)
            .map((tp) => tp.taskId)
            .toSet() ??
        <String>{};
  }

  int _firstIncompleteIndex(List<Task> tasks, Set<String> completedIds) {
    for (var i = 0; i < tasks.length; i++) {
      if (!completedIds.contains(tasks[i].id)) return i;
    }
    return tasks.length; // all complete
  }

  Future<void> _completeTask(
    String taskId, {
    Map<String, dynamic> answer = const {},
  }) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await QuestService().completeTask(
        widget.quest.id,
        taskId,
        answer,
      );

      if (!mounted) return;

      if (result['passed'] == true) {
        _progressChanged = true;
        await _loadQuestData();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correct!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['reason'] ?? 'Wrong answer, try again'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processDialogueChoice(String choice, String? nextDialogueId) {
    // handling dialogue choices (hook this to backend later if needed)
    debugPrint('Choice: $choice, Next: $nextDialogueId');
  }

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
                          onTap: () => Navigator.pop(context, _progressChanged),
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
                    const SizedBox(height: 12),
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
              Expanded(child: _buildQuestBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestBody() {
    final tasks = [...widget.quest.tasks]
      ..sort((a, b) => a.order.compareTo(b.order));

    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks in this quest',
          style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 18),
        ),
      );
    }

    final completedIds = _completedTaskIds();
    final firstIncomplete = _firstIncompleteIndex(tasks, completedIds);

    if (firstIncomplete >= tasks.length) {
      return const Center(
        child: Text(
          'Quest completed!',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isCompleted = completedIds.contains(task.id);
        final isUnlocked =
            index == firstIncomplete; // only next incomplete is playable
        final isLockedByOrder = !isCompleted && !isUnlocked;

        return _buildTaskCard(
          task: task,
          isCompleted: isCompleted,
          isUnlocked: isUnlocked,
          isLockedByOrder: isLockedByOrder,
          positionLabel: 'Task ${index + 1} of ${tasks.length}',
        );
      },
    );
  }

  Widget _buildTaskCard({
    required Task task,
    required bool isCompleted,
    required bool isUnlocked,
    required bool isLockedByOrder,
    required String positionLabel,
  }) {
    final content = _buildTaskContentFor(task, enabled: isUnlocked);

    return Opacity(
      opacity: isLockedByOrder ? 0.45 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? const Color(0xFFB020DD).withOpacity(0.8)
                : Colors.white.withOpacity(0.15),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (isLockedByOrder)
                  const Icon(Icons.lock, color: Colors.white70)
                else
                  const Icon(Icons.play_circle_fill, color: Colors.white),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              positionLabel,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              task.description,
              style: TextStyle(color: Colors.white.withOpacity(0.85)),
            ),
            const SizedBox(height: 12),

            // task content (options/input/etc.)
            content,

            const SizedBox(height: 12),

            // action area
            if (isCompleted)
              Text(
                'Completed (+${task.xpReward} XP)',
                style: TextStyle(color: Colors.green.withOpacity(0.9)),
              )
            else if (isLockedByOrder)
              Text(
                'Complete the previous task to unlock this.',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            /*else if (task.type != 'dialogue')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _completeTask(task.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A148C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Complete Task'),
                ),
              ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildTaskContentFor(Task task, {required bool enabled}) {
    final prev = _currentTask;
    _currentTask = task;

    final result = IgnorePointer(
      ignoring: !enabled,
      child: _buildTaskContentForId(task.id), // <-- pass stable id
    );

    _currentTask = prev;
    return result;
  }

  Widget _buildTaskContentForId(String taskId) {
    switch (_currentTask!.type) {
      case 'multiple_choice':
        return _buildMultipleChoiceTask(taskId);
      case 'dialogue':
        return _buildDialogueTask(); // no submit here
      case 'geofence':
        return _buildGeofenceTask();
      case 'checkin':
        return _buildCheckinTask();
      case 'number_input':
        return _buildNumberInputTask(taskId);
      case 'string_input':
        return _buildStringInputTask(taskId);
      case 'true_false':
        return _buildTrueFalseTask(taskId);
      default:
        return _buildDefaultTask();
    }
  }

  Widget _buildMultipleChoiceTask(String taskId) {
    final taskData = _currentTask!.taskData as Map<String, dynamic>?;

    if (taskData == null) {
      return const Text(
        'No multiple choice data found for this task.',
        style: TextStyle(color: Colors.white),
      );
    }

    final question = taskData?['question']?.toString() ?? '';
    final optionsRaw = taskData?['options'];

    // Normalize options into a list of maps like: [{ "text": "..." }, ...]
    final List<Map<String, dynamic>> options = switch (optionsRaw) {
      final List list => list.map<Map<String, dynamic>>((o) {
        if (o is Map) return Map<String, dynamic>.from(o);
        if (o is String) return {'text': o};
        return {'text': o.toString()};
      }).toList(),
      final String s => [
        {'text': s},
      ],
      _ => const [],
    };

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
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _completeTask(
                        taskId,
                        answer: {'answer': option['text']?.toString() ?? ''},
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  option['text']?.toString() ?? 'Option',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogueTask() {
    // taskData is already the dialogueData map (see Task._getTaskData in quest_models.dart)
    final dialogueData = _currentTask!.taskData as Map<String, dynamic>?;

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
      options:
          (dialogueData['options'] as List<dynamic>?)
              ?.map((o) => o as Map<String, dynamic>)
              .toList() ??
          [],
      onChoiceSelected: (choice, {String? nextDialogueId}) {
        _processDialogueChoice(choice, nextDialogueId);
      },
    );
  }

  Widget _buildGeofenceTask() {
    final geofenceData = _currentTask!.taskData as Map<String, dynamic>?;
    final description = geofenceData?['description'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Location Task',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
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
    final checkinData = _currentTask!.taskData as Map<String, dynamic>?;
    final description = checkinData?['description'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Check-in Task',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
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

  Widget _buildStringInputTask(String taskId) {
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
            inputData?['question']?.toString() ?? '',
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
              onPressed: _isLoading
                  ? null
                  : () => _completeTask(
                      taskId,
                      answer: {'answer': _controller.text},
                    ),
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

  Widget _buildNumberInputTask(String taskId) {
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
            inputData?['question']?.toString() ?? '',
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
              onPressed: _isLoading
                  ? null
                  : () => _completeTask(
                      taskId,
                      answer: {'answer': _controller.text},
                    ),
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

  Widget _buildTrueFalseTask(String taskId) {
    final inputData = _currentTask!.taskData;
    final question = inputData?['question']?.toString() ?? '';

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
            question,
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
                  onPressed: _isLoading
                      ? null
                      : () => _completeTask(taskId, answer: {'answer': true}),
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
                  onPressed: _isLoading
                      ? null
                      : () => _completeTask(taskId, answer: {'answer': false}),
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
          const Icon(Icons.help_outline, color: Colors.white, size: 48),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
