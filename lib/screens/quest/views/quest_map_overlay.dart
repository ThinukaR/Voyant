import 'package:flutter/material.dart';

class QuestMapOverlay extends StatelessWidget {
  final Widget child;
  final bool isDialogueActive;
  final VoidCallback? onMapTap;

  const QuestMapOverlay({
    super.key,
    required this.child,
    required this.isDialogueActive,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //base map which is always visible 
        child,

        //quest overlay darks during dalogue ( the map becomes darker)
        if (isDialogueActive)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: Colors.black.withOpacity(0.3),
            child: Container(
              //preventing user from interacting with the map during dialogue
              color: Colors.transparent,
            ),
          ),
      ],
    );
  }
}