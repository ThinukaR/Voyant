import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../components/info_prompt_popup.dart';

class MessageLogsRepository {
  static const String _baseUrl = 'http://localhost:3000/api/messages';
  
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
      backgroundColor: const Color(0xFF1B0330),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMessagesList('all'),
          _buildMessagesList('hint'),
          _buildMessagesList('quest_update'),
          _buildMessagesList('reward'),
        ],
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
