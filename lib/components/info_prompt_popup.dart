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

