import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'avatar_event.dart';
part 'avatar_state.dart';

class AvatarBloc extends Bloc<AvatarEvent, AvatarState> {
  final AvatarRepository _avatarRepository;
  final UserRepository _userRepository;

  AvatarBloc({
    required AvatarRepository avatarRepository,
    required UserRepository userRepository,
  })
      : _avatarRepository = avatarRepository,
        _userRepository = userRepository,
        super(const AvatarState()) {
    on<LoadUserAvatars>(_onLoadUserAvatars);
    on<LoadAvatars>(_onLoadAvatars);
    on<LoadAvatar>(_onLoadAvatar);
    on<CreateAvatar>(_onCreateAvatar);
    on<UpdateAvatarEvent>(_onUpdateAvatar);
    on<AddCosmetic>(_onAddCosmetic);
    on<RemoveCosmetic>(_onRemoveCosmetic);
    on<SaveAvatar>(_onSaveAvatar);
    on<DiscardAvatar>(_onDiscardAvatar);
    on<DeleteAvatar>(_onDeleteAvatar);
  }

  Future<void> _onLoadUserAvatars(
    LoadUserAvatars event,
    Emitter<AvatarState> emit,
  ) async {
    emit(state.copyWith(status: AvatarStatus.loading));
    try {
      // Get the current user from the stream
      final currentUser = await _userRepository.user.first;
      final avatars =
          await _avatarRepository.getAllAvatars(currentUser.userId);
      emit(state.copyWith(
        status: AvatarStatus.success,
        avatars: avatars,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvatarStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadAvatars(
    LoadAvatars event,
    Emitter<AvatarState> emit,
  ) async {
    emit(state.copyWith(status: AvatarStatus.loading));
    try {
      final avatars = await _avatarRepository.getAllAvatars(event.userId);
      emit(state.copyWith(
        status: AvatarStatus.success,
        avatars: avatars,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvatarStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadAvatar(
    LoadAvatar event,
    Emitter<AvatarState> emit,
  ) async {
    emit(state.copyWith(status: AvatarStatus.loading));
    try {
      final avatar = await _avatarRepository.getAvatar(event.avatarId);
      emit(state.copyWith(
        status: AvatarStatus.success,
        currentAvatar: avatar,
        draftAvatar: avatar,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvatarStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateAvatar(
    CreateAvatar event,
    Emitter<AvatarState> emit,
  ) async {
    emit(state.copyWith(status: AvatarStatus.loading));
    try {
      // Get the current user from the stream
      final currentUser = await _userRepository.user.first;
      final avatarWithUser = event.avatar.copyWith(uid: currentUser.userId);
      final avatar = await _avatarRepository.createAvatar(avatarWithUser);
      final updatedAvatars = [...state.avatars, avatar];
      emit(state.copyWith(
        status: AvatarStatus.success,
        avatars: updatedAvatars,
        currentAvatar: avatar,
        draftAvatar: avatar,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvatarStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateAvatar(
    UpdateAvatarEvent event,
    Emitter<AvatarState> emit,
  ) async {
    emit(state.copyWith(status: AvatarStatus.loading));
    try {
      final avatar = await _avatarRepository.updateAvatar(event.avatar);
      final updatedAvatars = state.avatars.map((a) {
        return a.aid == avatar.aid ? avatar : a;
      }).toList();
      emit(state.copyWith(
        status: AvatarStatus.success,
        avatars: updatedAvatars,
        currentAvatar: avatar,
        draftAvatar: avatar,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvatarStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddCosmetic(
    AddCosmetic event,
    Emitter<AvatarState> emit,
  ) async {
    final draft = state.draftAvatar;
    if (draft != null) {
      final updatedCosmetics = [...draft.cosmetics];
      if (!updatedCosmetics.contains(event.cosmetic)) {
        updatedCosmetics.add(event.cosmetic);
        final updatedDraft = draft.copyWith(cosmetics: updatedCosmetics);
        emit(state.copyWith(draftAvatar: updatedDraft));
      }
    }
  }

  Future<void> _onRemoveCosmetic(
    RemoveCosmetic event,
    Emitter<AvatarState> emit,
  ) async {
    final draft = state.draftAvatar;
    if (draft != null) {
      final updatedCosmetics = [...draft.cosmetics];
      updatedCosmetics.remove(event.cosmetic);
      final updatedDraft = draft.copyWith(cosmetics: updatedCosmetics);
      emit(state.copyWith(draftAvatar: updatedDraft));
    }
  }

  Future<void> _onSaveAvatar(
    SaveAvatar event,
    Emitter<AvatarState> emit,
  ) async {
    final draft = state.draftAvatar;
    if (draft != null) {
      try {
        emit(state.copyWith(status: AvatarStatus.loading));
        Avatar savedAvatar;
        if (state.currentAvatar == null) {
          savedAvatar = await _avatarRepository.createAvatar(draft);
        } else {
          savedAvatar = await _avatarRepository.updateAvatar(draft);
        }
        final updatedAvatars = state.currentAvatar == null
            ? [...state.avatars, savedAvatar]
            : state.avatars.map((a) {
                return a.aid == savedAvatar.aid ? savedAvatar : a;
              }).toList();
        emit(state.copyWith(
          status: AvatarStatus.success,
          avatars: updatedAvatars,
          currentAvatar: savedAvatar,
          draftAvatar: savedAvatar,
          errorMessage: null,
          showSaveSuccess: true,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: AvatarStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onDiscardAvatar(
    DiscardAvatar event,
    Emitter<AvatarState> emit,
  ) async {
    if (state.currentAvatar != null) {
      emit(state.copyWith(
        draftAvatar: state.currentAvatar,
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        draftAvatar: null,
        errorMessage: null,
      ));
    }
  }

  Future<void> _onDeleteAvatar(
    DeleteAvatar event,
    Emitter<AvatarState> emit,
  ) async {
    emit(state.copyWith(status: AvatarStatus.loading));
    try {
      // Get current user to determine whose avatar to delete
      final currentUser = await _userRepository.user.first;
      
      // Cast to Firestore repo to use the extended delete method
      if (_avatarRepository is FirestoreAvatarRepository) {
        final repo = _avatarRepository as FirestoreAvatarRepository;
        await repo.deleteAvatarForUser(currentUser.userId, event.avatarId);
      } else {
        await _avatarRepository.deleteAvatar(event.avatarId);
      }

      final updatedAvatars =
          state.avatars.where((a) => a.aid != event.avatarId).toList();
      emit(state.copyWith(
        status: AvatarStatus.success,
        avatars: updatedAvatars,
        currentAvatar: null,
        draftAvatar: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvatarStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
