import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Message {
  final String id;
  final String characterName;
  final String characterAvatar;
  final String message;
  final String messageType;
  final String location;
  final bool isRead;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.characterName,
    required this.characterAvatar,
    required this.message,
    required this.messageType,
    required this.location,
    required this.isRead,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id']?.toString() ?? '',
      characterName: json['characterName'] ?? '',
      characterAvatar: json['characterAvatar'] ?? '',
      message: json['message'] ?? '',
      messageType: json['messageType'] ?? 'info',
      location: json['location'] ?? '',
      isRead: json['isRead'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class MessageRepository {
  static const String _baseUrl = 'http://192.168.8.148:3000/api/messages';
  
  static Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/$userId/mark-read'), //api end point to mark message 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'messageIds': [messageId],
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to mark message as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

class _InfoPromptPopupState extends State<InfoPromptPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    //slide animation that starts the popup from top and brings it into the main screen area
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    //makes it fade in 
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    _controller.forward(); //starting animation 

    //remove the popup after 8 seconds 
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && !_isDismissing) {
        _dismissPopup();

      }
    });
  }

  //calls the dismiss function to remove the popup 
  Future<void> _dismissPopup() async {
    if (_isDismissing) return;
    
    _isDismissing = true;
    
    // Marks message as read
    try {
      await MessageRepository.markMessageAsRead(widget.message.id, widget.userId);
    } catch (e) {
      debugPrint('Failed to mark message as read: $e');
    }

    // dismiss animation
    await _controller.reverse();
    
    if (mounted) {
      widget.onDismiss?.call(widget.message.id); 
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


//dynamic styling for messages 
 Color _getMessageTypeColor() {
  //700 is used for a more darker swatch ( customizable to a lighter swatch )
    switch (widget.message.messageType) {
      case 'hint':
        return Colors.blue.shade700;
      case 'warning':
        return Colors.orange.shade700;
      case 'quest_update':
        return Colors.purple.shade700;
      case 'reward':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _dismissPopup,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getMessageTypeColor().withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: _getMessageTypeColor().withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      //creating and styling for npc/ogranization profile 
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getMessageTypeColor(),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getMessageTypeColor().withOpacity(0.3), //glow effect 
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipOval( //makes the image stay circular 
                          child: widget.message.characterAvatar.isNotEmpty
                              ? Image.network(
                                  widget.message.characterAvatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: _getMessageTypeColor(),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: _getMessageTypeColor(),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12)

                      // main body of the prompt 
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // display the npc name and location ( can be general location or assigned location )
                            Row(
                              children: [
                                Text(
                                  widget.message.characterName,
                                  style: TextStyle(
                                    color: _getMessageTypeColor(),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.message.location,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // displaying the text 
                            Text(
                              widget.message.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            // timestamp and adding a hint for the user to exit the popup
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTimestamp(widget.message.timestamp),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 10,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Tap to dismiss",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // icon indication for what the message is 
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _getMessageTypeColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getMessageTypeIcon(),
                          color: _getMessageTypeColor(),
                          size: 16,
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

//selects icon type to show as visual indication for prompts 
  IconData _getMessageTypeIcon() {
    switch (widget.message.messageType) {
      case 'hint':
        return Icons.lightbulb;
      case 'warning':
        return Icons.warning;
      case 'quest_update':
        return Icons.assignment;
      case 'reward':
        return Icons.emoji_events;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}

// overlaying (in case of multiple popups )
class InfoPromptOverlay extends StatefulWidget {
  final Widget child;
  final String userId;

  const InfoPromptOverlay({
    super.key,
    required this.child,
    required this.userId,
  });

  @override
  State<InfoPromptOverlay> createState() => _InfoPromptOverlayState();
}

class _InfoPromptOverlayState extends State<InfoPromptOverlay> {
  final List<Message> _activeMessages = [];
  final List<GlobalKey> _popupKeys = [];

  void showMessage(Message message) {
    setState(() {
      _activeMessages.add(message);
      _popupKeys.add(GlobalKey());
    });
  }

  void _removeMessage(String messageId) { 
    final index = _activeMessages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      setState(() {
        _activeMessages.removeAt(index);
        _popupKeys.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._activeMessages.asMap().entries.map((entry) {
          final index = entry.key;
          final message = entry.value;
          
          return InfoPromptPopup(
            key: _popupKeys[index],
            message: message,
            userId: widget.userId,
            onDismiss: (messageId) => _removeMessage(messageId), 
          );
        }),
      ],
    );
  }
}
