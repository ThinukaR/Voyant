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
  }
    }


