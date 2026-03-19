import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/src/models/models.dart';
import 'package:user_repository/src/entities/entities.dart';
import 'package:user_repository/src/avatar_repo.dart';

class FirestoreAvatarRepository implements AvatarRepository {
  final FirebaseFirestore _firestore;

  FirestoreAvatarRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection path for avatars: /users/{uid}/avatars/{aid}
  CollectionReference _userAvatarsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('avatars');
  }

  @override
  Future<Avatar> createAvatar(Avatar avatar) async {
    try {
      final docRef = _userAvatarsCollection(avatar.uid).doc(avatar.aid);
      await docRef.set({
        'aid': avatar.aid,
        'uid': avatar.uid,
        'characterData': avatar.characterData,
        'cosmetics': avatar.cosmetics,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      return Avatar.fromEntity(
        AvatarEntity.fromDocument(
          Map<String, Object?>.from(doc.data() as Map),
        ),
      );
    } catch (e) {
      throw Exception('Error creating avatar: $e');
    }
  }

  @override
  Future<Avatar> getAvatar(String avatarId) async {
    try {
      // Note: This requires knowing the userId. Consider updating the interface
      // or storing avatarId as unique across all users.
      throw UnimplementedError(
        'Use LoadAvatars to fetch avatars. Single avatar retrieval requires userId.',
      );
    } catch (e) {
      throw Exception('Error fetching avatar: $e');
    }
  }

  @override
  Future<List<Avatar>> getAllAvatars(String userId) async {
    try {
      final querySnapshot = await _userAvatarsCollection(userId).get();
      return querySnapshot.docs
          .map((doc) => Avatar.fromEntity(
                AvatarEntity.fromDocument(
                  Map<String, Object?>.from(doc.data() as Map),
                ),
              ))
          .toList();
    } catch (e) {
      throw Exception('Error fetching avatars: $e');
    }
  }

  @override
  Future<Avatar> updateAvatar(Avatar avatar) async {
    try {
      final docRef = _userAvatarsCollection(avatar.uid).doc(avatar.aid);
      await docRef.update({
        'characterData': avatar.characterData,
        'cosmetics': avatar.cosmetics,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      return Avatar.fromEntity(
        AvatarEntity.fromDocument(
          Map<String, Object?>.from(doc.data() as Map),
        ),
      );
    } catch (e) {
      throw Exception('Error updating avatar: $e');
    }
  }

  @override
  Future<void> deleteAvatar(String avatarId) async {
    try {
      // Note: This requires knowing the userId. Consider updating the interface
      throw UnimplementedError(
        'Delete requires userId. Update interface or implementation.',
      );
    } catch (e) {
      throw Exception('Error deleting avatar: $e');
    }
  }

  // Optional: Add a method that takes userId for delete operations
  Future<void> deleteAvatarForUser(String userId, String avatarId) async {
    try {
      await _userAvatarsCollection(userId).doc(avatarId).delete();
    } catch (e) {
      throw Exception('Error deleting avatar: $e');
    }
  }
}
