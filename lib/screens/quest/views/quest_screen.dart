import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';

class QuestScreen extends StatefulWidget {
  final String questId;
  const QuestScreen({super.key, required this.questId});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Map<String, dynamic>? quest;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadQuest();
  }

  // get firebase token
  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // fetch quest from backend
  Future<void> _loadQuest({bool justStarted = false}) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/quests/${widget.questId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // only auto-start once, don't loop
        if (data['userStatus'] == 'not_started' && !justStarted) {
          await _startQuest();
          return;
        }

        setState(() {
          quest = data;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load quest: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        error = 'Connection error: $e';
        isLoading = false;
      });
    }
  }

  // start the quest then reload
  Future<void> _startQuest() async {
    try {
      final token = await _getToken();
      await http.post(
        Uri.parse('$baseUrl/quests/${widget.questId}/start'),
        headers: {'Authorization': 'Bearer $token'},
      );
      await Future.delayed(const Duration(milliseconds: 500)); // ← add this
      await _loadQuest(justStarted: true); // ← pass flag
    } catch (e) {
      setState(() {
        error = 'Failed to start quest';
        isLoading = false;
      });
    }
  }

  // complete a task
  Future<void> _completeTask(String taskId, Map<String, dynamic> task) async {
    debugPrint('Completing task: $taskId type: ${task['type']}'); // ← add

    // build the request body based on task type
    Map<String, dynamic> body = {};

    if (task['type'] == 'geofence') {
      // TODO: get real GPS from device later
      // for now using hardcoded coordinates for testing
      body = {'userLat': 6.02604, 'userLng': 80.21531};
    } else if (task['type'] == 'number_input' ||
        task['type'] == 'string_input') {
      // show input dialog
      final answer = await _showAnswerDialog(task);
      if (answer == null) return; // user cancelled
      body = {'answer': answer};
    } else {
      // checkin, find_object, spot_diff — just confirm
      body = {'confirmed': true};
    }

    debugPrint('Body: $body'); // ← add

    try {
      final token = await _getToken();
      debugPrint('Token: $token'); // ← add
      final response = await http.post(
        Uri.parse('$baseUrl/quests/${widget.questId}/tasks/$taskId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      debugPrint('Complete status: ${response.statusCode}'); // ← add
      debugPrint('Complete body: ${response.body}'); // ← add

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['passed'] == true) {
        // check if user leveled up
        if (result['leveledUp'] == true) {
          _showLevelUpDialog(result['newLevel'], result['xpAwarded']);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ +${result['xpAwarded']} XP earned!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        // force full reload
        setState(() {
          isLoading = true;
          quest = null;
        });
        await _loadQuest(
          justStarted: true,
        ); // ← justStarted true prevents re-starting
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connection error')));
      }
    }
  }

  // dialog box for when level uping
  void _showLevelUpDialog(int newLevel, int xpAwarded) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFFB020DD).withOpacity(0.5)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // star icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB020DD).withOpacity(0.2),
                border: Border.all(color: const Color(0xFFB020DD), width: 2),
              ),
              child: const Icon(Icons.star, color: Colors.amber, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'LEVEL UP!',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You reached Level $newLevel',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '+$xpAwarded XP earned',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB020DD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // show dialog for number/string input tasks
  Future<String?> _showAnswerDialog(Map<String, dynamic> task) async {
    final controller = TextEditingController();
    final question = task['type'] == 'number_input'
        ? (task['numberInputData'] != null
              ? task['numberInputData']['question']
              : task['title'])
        : (task['stringInputData'] != null
              ? task['stringInputData']['instruction']
              : task['title']);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A2E),
        title: Text(task['title'], style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(question, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: task['type'] == 'number_input'
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Your answer',
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color(0xFFB020DD).withOpacity(0.5),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB020DD)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text(
              'Submit',
              style: TextStyle(color: Color(0xFFB020DD)),
            ),
          ),
        ],
      ),
    );
  }

  // get icon for task type
  IconData _getTaskIcon(String type) {
    switch (type) {
      case 'geofence':
        return Icons.location_on;
      case 'number_input':
        return Icons.pin;
      case 'string_input':
        return Icons.quiz;
      case 'photo':
        return Icons.photo_camera;
      case 'find_object':
        return Icons.search;
      case 'spot_diff':
        return Icons.compare;
      default:
        return Icons.task_alt;
    }
  }

  // get color for task type
  Color _getTaskColor(String type) {
    switch (type) {
      case 'geofence':
        return Colors.teal;
      case 'number_input':
        return Colors.blue;
      case 'string_input':
        return Colors.orange;
      case 'photo':
        return Colors.pink;
      case 'find_object':
        return Colors.purple;
      default:
        return Colors.white54;
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final bool isCompleted = task['isCompleted'] ?? false;
    final bool isLocked = task['isLocked'] ?? true;
    final String type = task['type'] ?? 'checkin';
    final icon = _getTaskIcon(type);
    final color = isCompleted ? Colors.greenAccent : _getTaskColor(type);

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.greenAccent.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(isCompleted ? Icons.check_circle : icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? '',
                  style: TextStyle(
                    color: isCompleted ? Colors.white54 : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  task['description'] ?? '',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            isLocked
                ? Icons.lock
                : isCompleted
                ? Icons.check_circle
                : Icons.arrow_forward_ios,
            color: isLocked ? Colors.white24 : color,
            size: 18,
          ),
        ],
      ),
    );

    // locked or completed tasks are not tappable
    if (isLocked || isCompleted) {
      return Opacity(opacity: isLocked ? 0.4 : 1.0, child: card);
    }

    // active task — tappable
    return GestureDetector(
      onTap: () => _completeTask(task['_id'], task),
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB020DD)),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    final tasks = (quest!['tasks'] as List<dynamic>?) ?? [];
    final lockedTasks = tasks
        .where((t) => t['isLocked'] == true)
        .cast<Map<String, dynamic>>()
        .toList();
    final activeTasks = tasks
        .where((t) => t['isLocked'] == false)
        .cast<Map<String, dynamic>>()
        .toList();
    final completedCount = tasks.where((t) => t['isCompleted'] == true).length;

    return Scaffold(
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
                            quest!['title'] ?? '',
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
                        quest!['userStatus'] == 'completed'
                            ? 'Completed'
                            : 'In Progress',
                        style: TextStyle(
                          color: quest!['userStatus'] == 'completed'
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.white.withOpacity(0.1), height: 1),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // progress + XP row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: CircularProgressIndicator(
                                  value: tasks.isEmpty
                                      ? 0
                                      : completedCount / tasks.length,
                                  strokeWidth: 10,
                                  backgroundColor: const Color(0xFF1E2A3A),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.greenAccent,
                                      ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$completedCount/${tasks.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Tasks',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A0A2E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFB020DD),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${quest!['totalXPEarned']} / ${quest!['totalXP']} XP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'XP Earned',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // locked tasks
                      if (lockedTasks.isNotEmpty) ...[
                        const Text(
                          'Locked Tasks',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...lockedTasks.map(_buildTaskCard),
                        const SizedBox(height: 28),
                      ],

                      // active tasks
                      if (activeTasks.isNotEmpty) ...[
                        const Text(
                          'Active Tasks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...activeTasks.map(_buildTaskCard),
                      ],
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
}
