import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:voyant/widgets/animated_gradient_background.dart';
import '../../../components/info_prompt_popup.dart';

class MessageLogsRepository {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/messages';
  
  static Future<List<Message>> getUserMessages(String userId, {
    int page = 1,
    int limit = 20,
    bool? isRead,
    String? messageType,
  }) async {
    try {
      final queryParams = <String, String>{
    //setting up the page anmd limit for how many messages it can have 
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      //filters to filter out unread or specific type of messages like rewards
      if (isRead != null) {
        queryParams['isRead'] = isRead.toString();
      }
      
      if (messageType != null) {
        queryParams['messageType'] = messageType;
      }

      final uri = Uri.parse('$_baseUrl/user/$userId').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesList = data['messages'];
        return messagesList.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<int> getUnreadCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> markAllAsRead(String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/$userId/mark-all-read'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all as read: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

//main ui screen
class MessageLogsScreen extends StatefulWidget {
  final String userId;

  const MessageLogsScreen({super.key, required this.userId});

  @override
  State<MessageLogsScreen> createState() => _MessageLogsScreenState();
}

class _MessageLogsScreenState extends State<MessageLogsScreen>
with TickerProviderStateMixin {
  late TabController _tabController;
  List<Message> _messages = [];
  List<Message> _filteredMessages = [];
  bool _isLoading = true;
  String? _error;
  int _unreadCount = 0;
  String _currentFilter = 'all'; // Track current filter
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    //creating tabs of - hunts , quests , rewards and all
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged); //detects any tab switching to respond 
    _loadMessages();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filters = ['all', 'hint', 'quest_update', 'reward']; 
      //updates the current filter
      _currentFilter = filters[_tabController.index]; 
      _loadMessages(refresh: true); 
    }
  }

  Future<void> _loadMessages({bool refresh = false}) async {
    if (refresh) { //reset when refreshing it 
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _messages.clear();
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final messages = await MessageLogsRepository.getUserMessages(
        widget.userId,
        page: _currentPage,
        messageType: _currentFilter == 'all' ? null : _currentFilter,
      );

      setState(() {
        if (refresh) {
          _messages = messages;
        } else {
          _messages.addAll(messages);
        }
        _filteredMessages = _messages;
        _isLoading = false;
        _hasMore = messages.length == 20; // Assuming page size is 20
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await MessageLogsRepository.getUnreadCount(widget.userId);
      setState(() {
        _unreadCount = count;
      });
    } catch (e) {
      debugPrint('Failed to load unread count: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await MessageLogsRepository.markAllAsRead(widget.userId);
      await _loadUnreadCount();
      await _loadMessages(refresh: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All messages have been marked as read'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark messages as read: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
   }


    //Dynamic colors and icons //

    Color _getMessageTypeColor(String messageType) {
        switch (messageType) {
        case 'hint':
            return Colors.blue.shade600;
        case 'warning':
            return Colors.orange.shade600;
        case 'quest_update':
            return Colors.purple.shade600;
        case 'reward':
            return Colors.green.shade600;
        default:
            return Colors.grey.shade600;
        }
    }

    IconData _getMessageTypeIcon(String messageType) {
        switch (messageType) {
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

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A148C),
        elevation: 0,
        title: const Text(
          'Message Logs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
        //shows unread count in red if there are unread messages 
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          IconButton( 
            //mark all as read
            icon: const Icon(Icons.mark_email_read, color: Colors.white),
            onPressed: _markAllAsRead,
          ),
        ],
        bottom: TabBar(
            //keeps the active bar as white while the innactive bar is a more faded white ( 70 applied for now )
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Hints'),
            Tab(text: 'Quests'),
            Tab(text: 'Rewards'),
          ],
        ),
      ),
      body: AnimatedGradientBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMessagesList('all'),
            _buildMessagesList('hint'),
            _buildMessagesList('quest_update'),
            _buildMessagesList('reward'),
          ],
        ),
      ),
    );
  }


// message list  
//this will create the content inside the tabs 
//will dynamically switch between the different screens 
  Widget _buildMessagesList(String messageType) {
    return Column(
      children: [
        
        Expanded( //takes all the space available
        //loading spinner animation
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                //error screen
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
                            'Error loading messages',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
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
                            onPressed: () => _loadMessages(refresh: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A148C),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    //empty
                  : _filteredMessages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                        //list 
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (!_isLoading &&
                                _hasMore &&
                                //user reached bottom ( detecting bottom)
                                scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) { 
                              setState(() {
                                _currentPage++;
                                _isLoading = true;
                              });
                              _loadMessages();
                            }
                            return false;
                          },
                          child: RefreshIndicator(
                            onRefresh: () => _loadMessages(refresh: true),
                            color: Colors.white,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredMessages.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filteredMessages.length && _hasMore) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator( //spinner animation 
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white), //possible change later 
                                      ),
                                    ),
                                  );
                                }

                                final message = _filteredMessages[index];
                                return _buildMessageCard(message);
                              },
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

//builds the message card ( how the message will look like in the list)
   Widget _buildMessageCard(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), //adds margins between cards
      decoration: BoxDecoration(
        //glass effect/glassmorphism
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMessageTypeColor(message.messageType).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // character image 
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getMessageTypeColor(message.messageType),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: message.characterAvatar.isNotEmpty
                        ? Image.network(
                            message.characterAvatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: _getMessageTypeColor(message.messageType),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: _getMessageTypeColor(message.messageType),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 12),

                // name of sender and message type 
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            message.characterName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getMessageTypeColor(message.messageType).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getMessageTypeIcon(message.messageType),
                                  color: _getMessageTypeColor(message.messageType),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  message.messageType.toUpperCase(),
                                  style: TextStyle(
                                    color: _getMessageTypeColor(message.messageType),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.6),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            message.location,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatTimestamp(message.timestamp),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // only show messages if not read 
                if (!message.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getMessageTypeColor(message.messageType),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // the content of the message 
            Text(
              message.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //timestamp -> time ago format conversion 
   String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }
}


