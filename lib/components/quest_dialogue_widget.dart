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
    
    @override
//to run when the widget is created 
  void initState() {
    super.initState();
    
    //animation duration 
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), 
      vsync: this,
    );

    //will fade from invisible to visible 
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut), //only runs in the first 60% of the animation 
    ));

    //slightly below to visible range 
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic), //ensures that it starts a bit later than the fade's start 
    ));

    _animationController.forward();
  }

//preventing memory leaks 
  @override
  void dispose() {
    _animationController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

void _handleChoice(DialogueOption option) {
    if (widget.isProcessing) return; //stops double clicking 

    //check - seeing if the response option needs a text input or not
    //text input is mostly needed for things like referral codes 
    //if it is not required then it will refer to parent for choice options 
    if (option.conditions.requiresReference) {
      setState(() {
        _showReferenceInput = true;
      });
    } else {
      widget.onChoiceSelected(option.id);
    }
  }
 

  void _submitReferenceChoice(DialogueOption option) {
    final referenceCode = _referenceController.text.trim();
    widget.onChoiceSelected(option.id, userInput: referenceCode); //both id and user input are sent 
    _referenceController.clear();
    setState(() {
      _showReferenceInput = false;
    });
  }