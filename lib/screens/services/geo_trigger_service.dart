import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class QuestTrigger {
  final String id; //refers to the id of the specific trigger 
  final String subQuestId;
  final String triggerType; //if it's via location or npc
  final TriggerLocation location;
  final TriggerActions actions;
  final double distance;

  const QuestTrigger({
    required this.id,
    required this.subQuestId,
    required this.triggerType,
    required this.location,
    required this.actions,
    required this.distance,
  });

//a sinle quest trigger on the map 
  factory QuestTrigger.fromJson(Map<String, dynamic> json) {
    return QuestTrigger(
      id: json['triggerId']?.toString() ?? '',
      subQuestId: json['subQuestId']?.toString() ?? '',
      triggerType: json['triggerType'] ?? '',
      location: TriggerLocation.fromJson(json['location'] ?? {}),
      actions: TriggerActions.fromJson(json['actions'] ?? {}),
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }
}
 
class TriggerLocation {
  final String name;
  final double lat; //coordinates 
  final double lng; 
  final double radius; //activation zone ( current standard can be meters)
  final String? description; 

  const TriggerLocation({
    required this.name,
    required this.lat,
    required this.lng,
    required this.radius,
    this.description,
  });

  factory TriggerLocation.fromJson(Map<String, dynamic> json) {
    return TriggerLocation(
      name: json['name'] ?? '',
      lat: (json['coordinates']?['lat'] ?? 0).toDouble(),
      lng: (json['coordinates']?['lng'] ?? 0).toDouble(),
      radius: (json['radius'] ?? 50).toDouble(),
      description: json['description'],
    );
  }
}

//what happens when player reaches the trigger
class TriggerActions {
  final bool startQuest;
  final QuestNotification? showNotification; //for popup message
  final NPCInfo? spawnNPC; 
  final DialogueInfo? showDialogue; //if dialogue should start 

  const TriggerActions({
    required this.startQuest,
    this.showNotification,
    this.spawnNPC,
    this.showDialogue,
  });

  factory TriggerActions.fromJson(Map<String, dynamic> json) {
    return TriggerActions(
      startQuest: json['startQuest'] ?? false,
      showNotification: json['showNotification'] != null 
          ? QuestNotification.fromJson(json['showNotification'])
          : null,
      spawnNPC: json['spawnNPC'] != null 
          ? NPCInfo.fromJson(json['spawnNPC'])
          : null,
      showDialogue: json['showDialogue'] != null 
          ? DialogueInfo.fromJson(json['showDialogue'])
          : null,
    );
  }
}

//This does not overlap with the info prompts which will happen throughout the quest
//These notifications are alerts to available quests 
class QuestNotification {
  final String title;
  final String message;
  final String? icon;

  const QuestNotification({
    required this.title,
    required this.message,
    this.icon,
  });

  factory QuestNotification.fromJson(Map<String, dynamic> json) {
    return QuestNotification(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      icon: json['icon'],
    );
  }
}

//npc info when for when npc triggers/spawns
class NPCInfo {
  final String name;
  final String avatar;
  final MapLocation location;

  const NPCInfo({
    required this.name,
    required this.avatar,
    required this.location,
  });

  factory NPCInfo.fromJson(Map<String, dynamic> json) {
    return NPCInfo(
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      location: MapLocation.fromJson(json['location'] ?? {}),
    );
  }
}

class DialogueInfo {
  final String npcName;
  final String dialogueId;

  const DialogueInfo({
    required this.npcName,
    required this.dialogueId,
  });

  factory DialogueInfo.fromJson(Map<String, dynamic> json) {
    return DialogueInfo(
      npcName: json['npcName'] ?? '',
      dialogueId: json['dialogueId'] ?? '',
    );
  }
}


class MapLocation {
  final double lat;
  final double lng;

  const MapLocation({
    required this.lat,
    required this.lng,
  });

  factory MapLocation.fromJson(Map<String, dynamic> json) {
    return MapLocation(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

class GeoTriggerService {
  static const String _baseUrl = 'http://192.168.8.148/api/quest-triggers';
  static const Duration _checkInterval = Duration(seconds: 5); // checks every 5 seconds 
  // only detects triggers that are within a 100m range 
  static const double _triggerRadius = 100.0; 
  
  //runs repeated checks 
  Timer? _locationCheckTimer;
  final String userId;
  final Function(List<QuestTrigger>) onTriggersFound; //UI trigger display 
  final Function(QuestTrigger) onTriggerActivated;
  
  // preventing dulicate triggers ( by caching it )
  final Set<String> _activeTriggerIds = {};
  final Set<String> _activatedTriggerIds = {};

  GeoTriggerService({
    required this.userId,
    required this.onTriggersFound,
    required this.onTriggerActivated,
  });

//location monitoring when started will repeatedly check the user location every 5 seconds 
//it can be canclled as well to stop monitoring ( for performance and api token preservation)
  void startLocationMonitoring() {
    _locationCheckTimer?.cancel();
    _locationCheckTimer = Timer.periodic(_checkInterval, (_) {
      _checkForNearbyTriggers();
    });
  }

  void stopLocationMonitoring() {
    _locationCheckTimer?.cancel();
  }

    
  Future<void> _checkForNearbyTriggers() async {
    try {
      // get current user location 
      final currentLocation = await _getCurrentUserLocation();
      if (currentLocation == null) return;

      final response = await http.get(
        Uri.parse('$_baseUrl/nearby')
            .replace(queryParameters: {
          'userId': userId,
          'lat': currentLocation!.lat.toString(),
          'lng': currentLocation!.lng.toString(),
          'radius': _triggerRadius.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> triggersJson = data['triggers'];
        final triggers = triggersJson
            .map((json) => QuestTrigger.fromJson(json))
            .toList();

        // filter for new triggers and avoiding duplicates
        final newTriggers = triggers.where((trigger) {
          return !_activeTriggerIds.contains(trigger.id) &&
              !_activatedTriggerIds.contains(trigger.id);
        }).toList();

        if (newTriggers.isNotEmpty) {
          // add to active triggers to the UI
          for (final trigger in newTriggers) {
            _activeTriggerIds.add(trigger.id);
          }
          
          onTriggersFound(newTriggers);
        }
      }
    } catch (e) {
      debugPrint('Error found when checking nearby triggers: $e');
    }
  }

  Future<void> activateTrigger(QuestTrigger trigger) async {
    try {
      final currentLocation = await _getCurrentUserLocation();
      if (currentLocation == null) return;

      final response = await http.post(
        Uri.parse('$_baseUrl/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        //backend verification for if user is close enough -> trigger becomes valid 
        body: json.encode({
          'userId': userId,
          'triggerId': trigger.id,
          'userLocation': {
            'lat': currentLocation!.lat,
            'lng': currentLocation.lng,
          },
        }),
      );

      if (response.statusCode == 200) {
        // move triggers from active to activated 
        _activeTriggerIds.remove(trigger.id);
        _activatedTriggerIds.add(trigger.id);
        
        onTriggerActivated(trigger);
      }
    } catch (e) {
      debugPrint('Error activating trigger: $e');
    }
  }


  Future<MapLocation?> _getCurrentUserLocation() async {
    try {
      //checks if live service is enabled and if not it returns null and stops execution 
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      //chcks for location perms 
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions have been denied');
        return null;
      }

      //getting current position 
      //this is a more accurate fetch since location accuracy is set to high , hence there can be higher battery usage
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('Current location: ${position.latitude}, ${position.longitude}'); //cords are printed in the console
      
      return MapLocation(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      
      //prevents failing ( stops the app from crashing)
      debugPrint('fallback location: Galle Fort');
      return MapLocation(lat: 6.0236, lng: 80.2172);
    }
  }

  void clearCache() {
    _activeTriggerIds.clear();
    _activatedTriggerIds.clear();
  }
}
