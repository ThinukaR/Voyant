import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'notification_settings_event.dart';
part 'notification_settings_state.dart';

class NotificationSettingsBloc extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  final UserRepository userRepository;

  NotificationSettingsBloc({
    required this.userRepository,
  }) : super(const NotificationSettingsState.initial()) {
    on<LoadNotificationSettingsEvent>(_onLoadSettings);
    on<UpdateGeneralSettingsEvent>(_onUpdateGeneralSettings);
    on<UpdateActivitySettingsEvent>(_onUpdateActivitySettings);
    on<UpdateSocialSettingsEvent>(_onUpdateSocialSettings);
    on<UpdateReminderSettingsEvent>(_onUpdateReminderSettings);
    on<UpdateMessageSettingsEvent>(_onUpdateMessageSettings);
    on<UpdatePromotionSettingsEvent>(_onUpdatePromotionSettings);
    on<UpdatePreferencesEvent>(_onUpdatePreferences);
    on<UpdatePrivacySettingsEvent>(_onUpdatePrivacySettings);
    on<SaveAllSettingsEvent>(_onSaveAllSettings);
  }

  Future<void> _onLoadSettings(
    LoadNotificationSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationSettingsStatus.loading));
    try {
      final settings = await userRepository.getNotificationSettings();
      emit(state.copyWith(
        status: NotificationSettingsStatus.success,
        generalSettings: settings['general'] ?? {},
        activitySettings: settings['activity'] ?? {},
        socialSettings: settings['social'] ?? {},
        reminderSettings: settings['reminders'] ?? {},
        messageSettings: settings['messages'] ?? {},
        promotionSettings: settings['promotions'] ?? {},
        preferences: settings['preferences'] ?? {},
        privacySettings: settings['privacy'] ?? {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateGeneralSettings(
    UpdateGeneralSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      final updated = {...state.generalSettings, ...event.settings};
      emit(state.copyWith(generalSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateActivitySettings(
    UpdateActivitySettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      final updated = {...state.activitySettings, ...event.settings};
      emit(state.copyWith(activitySettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateSocialSettings(
    UpdateSocialSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      final updated = {...state.socialSettings, ...event.settings};
      emit(state.copyWith(socialSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateReminderSettings(
    UpdateReminderSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      final updated = {...state.reminderSettings, ...event.settings};
      emit(state.copyWith(reminderSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateMessageSettings(
    UpdateMessageSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      final updated = {...state.messageSettings, ...event.settings};
      emit(state.copyWith(messageSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdatePromotionSettings(
    UpdatePromotionSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      final updated = {...state.promotionSettings, ...event.settings};
      emit(state.copyWith(promotionSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdatePreferences(
    UpdatePreferencesEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      final updated = {...state.preferences, ...event.preferences};
      emit(state.copyWith(preferences: updated));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdatePrivacySettings(
    UpdatePrivacySettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    try {
      final updated = {...state.privacySettings, ...event.settings};
      emit(state.copyWith(privacySettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSaveAllSettings(
    SaveAllSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationSettingsStatus.loading));
    try {
      await userRepository.saveNotificationSettings({
        'general': state.generalSettings,
        'activity': state.activitySettings,
        'social': state.socialSettings,
        'reminders': state.reminderSettings,
        'messages': state.messageSettings,
        'promotions': state.promotionSettings,
        'preferences': state.preferences,
        'privacy': state.privacySettings,
      });
      emit(state.copyWith(status: NotificationSettingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

