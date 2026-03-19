part of 'avatar_bloc.dart';

abstract class AvatarEvent extends Equatable {
  const AvatarEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserAvatars extends AvatarEvent {
  const LoadUserAvatars();
}

class LoadAvatars extends AvatarEvent {
  final String userId;

  const LoadAvatars(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadAvatar extends AvatarEvent {
  final String avatarId;

  const LoadAvatar(this.avatarId);

  @override
  List<Object?> get props => [avatarId];
}

class CreateAvatar extends AvatarEvent {
  final Avatar avatar;

  const CreateAvatar(this.avatar);

  @override
  List<Object?> get props => [avatar];
}

class UpdateAvatarEvent extends AvatarEvent {
  final Avatar avatar;

  const UpdateAvatarEvent(this.avatar);

  @override
  List<Object?> get props => [avatar];
}

class AddCosmetic extends AvatarEvent {
  final String cosmetic;

  const AddCosmetic(this.cosmetic);

  @override
  List<Object?> get props => [cosmetic];
}

class RemoveCosmetic extends AvatarEvent {
  final String cosmetic;

  const RemoveCosmetic(this.cosmetic);

  @override
  List<Object?> get props => [cosmetic];
}

class SaveAvatar extends AvatarEvent {
  const SaveAvatar();
}

class DiscardAvatar extends AvatarEvent {
  const DiscardAvatar();
}

class DeleteAvatar extends AvatarEvent {
  final String avatarId;

  const DeleteAvatar(this.avatarId);

  @override
  List<Object?> get props => [avatarId];
}
