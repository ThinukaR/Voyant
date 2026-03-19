import 'package:user_repository/src/models/models.dart';

abstract class AvatarRepository {
  Future<Avatar> createAvatar(Avatar avatar);

  Future<Avatar> getAvatar(String avatarId);

  Future<List<Avatar>> getAllAvatars(String userId);

  Future<Avatar> updateAvatar(Avatar avatar);

  Future<void> deleteAvatar(String avatarId);
}
