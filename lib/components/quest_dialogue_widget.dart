import 'package:flutter/material.dart';
import '../models/quest_models.dart';

class QuestDialogueWidget extends StatefulWidget {
  final String npcName;
  final String? npcAvatar;
  final String dialogueText;
  final String emotion;
  final List<Map<String, dynamic>> options;
  final void Function(String choice, {String? nextDialogueId}) onChoiceSelected;
  final bool isProcessing;

  const QuestDialogueWidget({
    super.key,
    required this.npcName,
    this.npcAvatar,
    required this.dialogueText,
    this.emotion = 'neutral',
    required this.options,
    required this.onChoiceSelected,
    this.isProcessing = false,
  });

  @override
  State<QuestDialogueWidget> createState() => _QuestDialogueWidgetState();
}

class _QuestDialogueWidgetState extends State<QuestDialogueWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1B0330).withOpacity(0.95),
            const Color(0xFF4A148C).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A148C).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //NPC header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF4A148C),
                    width: 2,
                  ),
                ),
                child: widget.npcAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          widget.npcAvatar!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 30,
                              color: Color(0xFF4A148C),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF4A148C),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.npcName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getEmotionColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getEmotionText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          //dialogue 
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.dialogueText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          //options for dialogue
          ...widget.options.map((option) => _buildOption(option)),
        ],
      ),
    );
  }

  Widget _buildOption(Map<String, dynamic> option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: InkWell(
                onTap: widget.isProcessing ? null : () {
                  widget.onChoiceSelected(
                    option['text'] ?? '',
                    nextDialogueId: option['nextDialogueId'],
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.isProcessing
                        ? Colors.grey.withOpacity(0.3)
                        : const Color(0xFF4A148C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4A148C),
                    ),
                  ),
                  child: Text(
                    option['text'] ?? 'Option',
                    style: TextStyle(
                      color: widget.isProcessing
                          ? Colors.grey
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getEmotionColor() {
    switch (widget.emotion) {
      case 'happy':
        return Colors.green.withOpacity(0.3);
      case 'angry':
        return Colors.red.withOpacity(0.3);
      case 'sad':
        return Colors.blue.withOpacity(0.3);
      case 'surprised':
        return Colors.orange.withOpacity(0.3);
      case 'neutral':
      default:
        return const Color(0xFF4A148C).withOpacity(0.3);
    }
  }

  String _getEmotionText() {
    switch (widget.emotion) {
      case 'happy':
        return 'Happy';
      case 'angry':
        return 'Angry';
      case 'sad':
        return 'Sad';
      case 'surprised':
        return 'Surprised';
      case 'neutral':
      default:
        return 'Neutral';
    }
  }
}
