part of 'avatar_bloc.dart';

enum AvatarStatus { initial, loading, success, failure }

class AvatarState extends Equatable {
  final AvatarStatus status;
  final List<Avatar> avatars;
  final Avatar? currentAvatar;
  final Avatar? draftAvatar;
  final String? errorMessage;
  final bool showSaveSuccess;

  const AvatarState({
    this.status = AvatarStatus.initial,
    this.avatars = const [],
    this.currentAvatar,
    this.draftAvatar,
    this.errorMessage,
    this.showSaveSuccess = false,
  });

  AvatarState copyWith({
    AvatarStatus? status,
    List<Avatar>? avatars,
    Avatar? currentAvatar,
    Avatar? draftAvatar,
    String? errorMessage,
    bool? showSaveSuccess,
  }) {
    return AvatarState(
      status: status ?? this.status,
      avatars: avatars ?? this.avatars,
      currentAvatar: currentAvatar ?? this.currentAvatar,
      draftAvatar: draftAvatar ?? this.draftAvatar,
      errorMessage: errorMessage ?? this.errorMessage,
      showSaveSuccess: showSaveSuccess ?? this.showSaveSuccess,
    );
  }

  @override
  List<Object?> get props =>
      [status, avatars, currentAvatar, draftAvatar, errorMessage, showSaveSuccess];
}
