import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Reward {

  //container for reward data 
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int xpPoints;
  final String userId;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.xpPoints,
    required this.userId,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      xpPoints: json['xpPoints'] ?? 0,
      userId: json['userId']?.toString() ?? '',
    );
  }
}

class RewardRepository {
  static const String _baseUrl = 'http://localhost:3000/api'; //will have to re-adjust this for real phones
  
  static Future<void> saveRewardToUser(String userId, String rewardId, int currentXP, int newXP) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/rewards/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'rewardId': rewardId,
          'currentXP': currentXP,
          'newXP': newXP,
          'claimedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        throw Exception('failed to save reward: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('network error: $e');
    }
  }
}

//main Ui setup 
class RewardScreen extends StatefulWidget {
  final String questName;
  final String rewardName;
  final String rewardImage;
  final String profileImage;
  final int expGained;
  final double startProgress; 
  final double endProgress;   
  final String userId;
  final String rewardId;

  const RewardScreen({
    super.key,
    required this.questName,
    required this.rewardName,
    required this.rewardImage,
    required this.profileImage,
    required this.expGained,
    required this.startProgress,
    required this.endProgress,
    required this.userId,
    required this.rewardId,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}


//animations 
class _RewardScreenState extends State<RewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _cosmeticDropController;
  late AnimationController _expBarController;
  late Animation<double> _cosmeticDropAnimation;
  late Animation<double> _expBarAnimation;
  late Animation<double> _glowAnimation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();

    //drop animation for the reward ( can be cosmetic or token)
    _cosmeticDropController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cosmeticDropAnimation = Tween<double>( //drops from top 
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cosmeticDropController,
      curve: Curves.bounceOut,
    ));

    // Glow animation 
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cosmeticDropController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));
  
   // animation for exp bar
    _expBarController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _expBarAnimation = Tween<double>(
      begin: widget.startProgress,
      end: widget.endProgress,
    ).animate(CurvedAnimation(
      parent: _expBarController,
      curve: Curves.easeInOut,
    ));

    _currentProgress = widget.startProgress;

    _cosmeticDropController.forward();
    
    // starting exp bar animation after reward drops 
    Future.delayed(const Duration(milliseconds: 600), () {
      _expBarController.forward();
      _animateProgress();
    });
  }

 void _animateProgress() {
    final duration = const Duration(milliseconds: 1500);
    final steps = 60;
    final stepTime = duration.inMilliseconds ~/ steps;

    //calculation to see how much the bar should increase per step 
    double increment = (widget.endProgress - widget.startProgress) / steps;

  //repeating timer 
    Timer.periodic(Duration(milliseconds: stepTime), (timer) { 
      setState(() {
        _currentProgress += increment;
      });

      if (_currentProgress >= widget.endProgress) {
        _currentProgress = widget.endProgress;
        timer.cancel();
      }
    });
  }

  @override
  //to stop any memory leaks that could happen 
  void dispose() {
    _cosmeticDropController.dispose();
    _expBarController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0330), 
      body: SafeArea( // to prevent itfrom going behind system UI 
        child: Container(
          width: double.infinity,
          height: double.infinity,
          //vertical gradient ( purple hues)
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2A1F3D),
                const Color(0xFF1B0330),
                const Color(0xFF0F0817),
              ],
            ),
          ),
          child: Stack(
            children: [
              // profile picture ( top corner )
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.profileImage.isNotEmpty
                        ? Image.network(
                            widget.profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade600,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade600,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 24,
                            ),
                          ),
                  ),
                ),
              ),

              // main body 
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // this will be the main text displayed in bold
                      const Text(
                        "QUEST COMPLETED!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Color(0xFF4A148C),
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // quest name
                      Text(
                        widget.questName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // displaying reward with an animation 
                      AnimatedBuilder(
                        animation: _cosmeticDropAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _cosmeticDropAnimation.value),
                            child: AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    // makes png look better ( filled background )
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(_glowAnimation.value * 0.6),
                                        blurRadius: 20 * _glowAnimation.value,
                                        spreadRadius: 5 * _glowAnimation.value,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: widget.rewardImage.isNotEmpty
                                        ? Image.network(
                                            widget.rewardImage,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.emoji_events,
                                                size: 60,
                                                color: Colors.white,
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.emoji_events,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      // reward name 
                      Text(
                        widget.rewardName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // amount of exp that the user gained 
                      Text(
                        "+${widget.expGained} EXP",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          shadows: [
                            Shadow(
                              color: Colors.green,
                              offset: Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // exp bar progression 
                      Container(
                        width: 280,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedBuilder(
                            animation: _expBarAnimation,
                            builder: (context, child) {
                              return Stack(
                                children: [
                                  // bar
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey.shade700,
                                          Colors.grey.shade800,
                                        ],
                                      ),
                                    ),
                                  ),


                                  // current progress will make the bar fill up to the nessesary level
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _currentProgress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green.shade400,
                                            Colors.green.shade600,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // xp progression indicator percentage 
                                  Center(
                                    child: Text(
                                      "${(_currentProgress * 100).toInt()}%",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                       // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, //ensures that the buttons are side by side 
                        children: [
                          ElevatedButton(
                            onPressed: () async { 
                              try {
                                await RewardRepository.saveRewardToUser(
                                  widget.userId,
                                  widget.rewardId,
                                  (widget.startProgress * 1000).toInt(),
                                  (widget.endProgress * 1000).toInt(),
                                );
                                
                                if (mounted) { //proceeds if screen is active 
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reward saved !'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to save reward: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            //equip the reward to the avatar ( if equippable)
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A148C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(

                              "Equip",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          //exit the current screen and return 
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Continue",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
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




                 



  


