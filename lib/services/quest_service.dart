//for handling api calls and management

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../models/quest_models.dart';

class QuestService {
  static final QuestService _instance = QuestService._internal();
  factory QuestService() => _instance;
  QuestService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //getting auth headers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  //auth token
  Future<String?> _getToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  //getting all quests 
  Future<QuestListResponse> getAllUserQuests() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quests'),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuestListResponse.fromJson(data);
      } else {
        throw Exception('Failed to load quests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading quests: $e');
    }
  }

  //getting quest by ID
  Future<Quest> getQuestById(String questId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quests/$questId'),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quest.fromJson(data);
      } else {
        throw Exception('Failed to load quest: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading quest: $e');
    }
  }

  // starting a quest
  Future<QuestProgress> startQuest(String questId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quests/$questId/start'),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return QuestProgress.fromJson(data);
      } else {
        throw Exception('Failed to start quest: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error starting quest: $e');
    }
  }

  //task completion 
  Future<Map<String, dynamic>> completeTask(
    String questId, 
    String taskId, 
    Map<String, dynamic> answer
  ) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quests/$questId/tasks/$taskId/complete'),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: json.encode(answer),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to complete task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error completing task: $e');
    }
  }

  //quest dialogue
  Future<Map<String, dynamic>> getQuestDialogue(String questId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quests/$questId/dialogue'),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get dialogue: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting dialogue: $e');
    }
  }

  //handling dialogue choice
  Future<Map<String, dynamic>> processDialogueChoice(
    String questId, 
    String choice, 
    String? nextDialogueId
  ) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quests/$questId/dialogue'),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'choice': choice,
          'nextDialogueId': nextDialogueId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to process dialogue choice: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error processing dialogue choice: $e');
    }
  }

  //location trigger check ( for triggers that will be close by)
  Future<Map<String, dynamic>> checkNearbyTriggers(
    double latitude, 
    double longitude, 
    {int radius = 100}
  ) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('User not authenticated');

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quests/triggers/nearby')
            .replace(queryParameters: {
              'userId': user.uid,
              'lat': latitude.toString(),
              'lng': longitude.toString(),
              'radius': radius.toString(),
            }),
        headers: {
          ..._getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check nearby triggers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error checking nearby triggers: $e');
    }
  }


  //starting the galle main quest 
  Future<QuestProgress> startGalleMainQuest() async {
    try {
      

      final questResponse = await getAllUserQuests();
      final galleQuest = questResponse.mainQuests.firstWhere(
        (quest) => quest.title.toLowerCase().contains('galle'),
        orElse: () => throw Exception('Galle quest not found'),
      );

      return await startQuest(galleQuest.id);
    } catch (e) {
      throw Exception('Error starting Galle main quest: $e');
    }
  }

  //getting specific quest 
  Future<List<Quest>> getQuestsForTrip(String tripId) async {
    try {
      final questResponse = await getAllUserQuests();
      return questResponse.tripQuests
          .where((quest) => quest.tripId == tripId)
          .toList();
    } catch (e) {
      throw Exception('Error getting quests for trip: $e');
    }
  }

  //getting all location based quests 
  Future<List<Quest>> getAvailableLocationQuests() async {
    try {
      final questResponse = await getAllUserQuests();
      return questResponse.locationQuests
          .where((quest) => quest.isActive && quest.isNotStarted)
          .toList();
    } catch (e) {
      throw Exception('Error getting location quests: $e');
    }
  }

  //conditional check for if the user can start the quest or not 
  bool canStartQuest(Quest quest, List<Quest> allQuests) {
    if (quest.prerequisites == null || quest.prerequisites!.isEmpty) {
      return true;
    }

    //check - to see if all prerequisite quests are completed
    for (final prereqId in quest.prerequisites!) {
      final prereqQuest = allQuests
          .where((q) => q.id == prereqId)
          .firstOrNull;
      
      if (prereqQuest == null || !prereqQuest.isCompleted) {
        return false;
      }
    }

    return true;
  }

  //getting next uncompleted task for quests 
  Task? getNextTask(Quest quest) {
    if (quest.tasks.isEmpty) return null;
    
    //finding the first incopmplete task 
    for (final task in quest.tasks) {
      if (!task.isCompleted) {
        return task;
      }
    }
    
    return null;
  }

  //calclating quest progress ( by percentage )
  double calculateProgress(Quest quest) {
    if (quest.tasks.isEmpty) return 0.0;
    
    final completedTasks = quest.tasks
        .where((task) => task.isCompleted)
        .length;
    
    return completedTasks / quest.tasks.length;
  }
}
