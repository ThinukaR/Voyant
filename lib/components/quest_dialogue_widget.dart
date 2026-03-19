import 'package:flutter/material.dart';
import '../models/quest_models.dart';

class QuestDialogueWidget extends StatefulWidget {
  final DialogueNode dialogueNode; //current dialogue ( retrieved from backend)
  final Function(String, {String? userInput}) onChoiceSelected;
  final bool isProcessing; //helps with not sending too many requests

  const QuestDialogueWidget({
    super.key,
    required this.dialogueNode,
    required this.onChoiceSelected,
    required this.isProcessing,
  });

  @override
  State<QuestDialogueWidget> createState() => _QuestDialogueWidgetState();
}

class _QuestDialogueWidgetState extends State<QuestDialogueWidget>
    with SingleTickerProviderStateMixin {

//controllers for animation 
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

//stores input for referral code ( TODO)    
  final TextEditingController _referenceController = TextEditingController();
  bool _showReferenceInput = false;
    
    }