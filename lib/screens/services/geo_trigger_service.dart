import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

