// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:user_repository/src/models/models.dart';
import 'package:user_repository/src/entities/entities.dart';
import 'package:user_repository/src/avatar_repo.dart';

class FirebaseAvatarRepository implements AvatarRepository {
  final String baseUrl; // e.g., 'http://your-backend-url'
  final http.Client client;

  FirebaseAvatarRepository({
    required this.baseUrl,
    required this.client,
  });

  @override
  Future<Avatar> createAvatar(Avatar avatar) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/avatars'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': avatar.uid,
          'aid': avatar.aid,
          'characterData': avatar.characterData,
          'cosmetics': avatar.cosmetics,
        }),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return Avatar.fromEntity(
          AvatarEntity.fromDocument(
            Map<String, Object?>.from(jsonData['data']['avatar'] as Map),
          ),
        );
      } else {
        throw Exception('Failed to create avatar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating avatar: $e');
    }
  }

  @override
  Future<Avatar> getAvatar(String avatarId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/avatars/$avatarId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Avatar.fromEntity(
          AvatarEntity.fromDocument(
            Map<String, Object?>.from(jsonData['data']['avatar'] as Map),
          ),
        );
      } else {
        throw Exception('Failed to get avatar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching avatar: $e');
    }
  }

  @override
  Future<List<Avatar>> getAllAvatars(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/avatars/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final avatarsList = jsonData['data']['avatars'] as List;
        return avatarsList
            .map((avatar) => Avatar.fromEntity(
                  AvatarEntity.fromDocument(
                    Map<String, Object?>.from(avatar as Map),
                  ),
                ))
            .toList();
      } else {
        throw Exception('Failed to get all avatars: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching avatars: $e');
    }
  }

  @override
  Future<Avatar> updateAvatar(Avatar avatar) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/avatars/${avatar.aid}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'characterData': avatar.characterData,
          'cosmetics': avatar.cosmetics,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Avatar.fromEntity(
          AvatarEntity.fromDocument(
            Map<String, Object?>.from(jsonData['data']['avatar'] as Map),
          ),
        );
      } else {
        throw Exception('Failed to update avatar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating avatar: $e');
    }
  }

  @override
  Future<void> deleteAvatar(String avatarId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/avatars/$avatarId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete avatar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting avatar: $e');
    }
  }
}
