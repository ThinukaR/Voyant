import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'account_settings_event.dart';
part 'account_settings_state.dart';

class AccountSettingsBloc extends Bloc<AccountSettingsEvent, AccountSettingsState> {
  final UserRepository userRepository;

  AccountSettingsBloc({
    required this.userRepository,
  }) : super(const AccountSettingsState.initial()) {
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<ChangePasswordEvent>(_onChangePassword);
    on<UpdateLocationSharingEvent>(_onUpdateLocationSharing);
    on<UpdateTwoFAEvent>(_onUpdateTwoFA);
    on<UpdateBiometricEvent>(_onUpdateBiometric);
    on<DownloadPersonalDataEvent>(_onDownloadPersonalData);
    on<LinkSocialAccountEvent>(_onLinkSocialAccount);
    on<UnlinkSocialAccountEvent>(_onUnlinkSocialAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<GetLoginSessionsEvent>(_onGetLoginSessions);
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      await userRepository.updateProfile(
        displayName: event.displayName,
        bio: event.bio,
        location: event.location,
      );
      emit(state.copyWith(status: AccountSettingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUploadProfileImage(
      UploadProfileImageEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      final imageUrl = await userRepository.uploadProfileImage(event.imageFile);
      emit(state.copyWith(
        status: AccountSettingsStatus.success,
        profileImageUrl: imageUrl,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangePassword(
      ChangePasswordEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      // First, re-authenticate the user
      await userRepository.reauthenticateUser(event.email, event.currentPassword);
      // Then update password
      await userRepository.changePassword(event.newPassword);
      emit(state.copyWith(status: AccountSettingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateLocationSharing(
      UpdateLocationSharingEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      await userRepository.updateLocationSharing(event.enabled);
      emit(state.copyWith(
        status: AccountSettingsStatus.success,
        locationSharingEnabled: event.enabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateTwoFA(
      UpdateTwoFAEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      await userRepository.updateTwoFA(event.enabled);
      emit(state.copyWith(
        status: AccountSettingsStatus.success,
        twoFactorEnabled: event.enabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateBiometric(
      UpdateBiometricEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      await userRepository.updateBiometric(event.enabled);
      emit(state.copyWith(
        status: AccountSettingsStatus.success,
        biometricLoginEnabled: event.enabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDownloadPersonalData(
      DownloadPersonalDataEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      final data = await userRepository.downloadPersonalData();
      emit(state.copyWith(
        status: AccountSettingsStatus.success,
        downloadedData: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLinkSocialAccount(
      LinkSocialAccountEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      await userRepository.linkSocialAccount(event.provider, event.accessToken);
      emit(state.copyWith(status: AccountSettingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUnlinkSocialAccount(
      UnlinkSocialAccountEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      await userRepository.unlinkSocialAccount(event.provider);
      emit(state.copyWith(status: AccountSettingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccountEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      // Re-authenticate before deleting account
      await userRepository.reauthenticateUser(event.email, event.password);
      await userRepository.deleteAccountWithCleanup();
      emit(state.copyWith(status: AccountSettingsStatus.accountDeleted));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGetLoginSessions(
      GetLoginSessionsEvent event,
      Emitter<AccountSettingsState> emit,
      ) async {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    try {
      final sessions = await userRepository.getLoginSessions();
      emit(state.copyWith(
        status: AccountSettingsStatus.success,
        loginSessions: sessions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}