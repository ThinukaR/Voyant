import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'privacy_security_settings_event.dart';
part 'privacy_security_settings_state.dart';

class PrivacySecuritySettingsBloc extends Bloc<PrivacySecuritySettingsEvent, PrivacySecuritySettingsState> {
  final UserRepository userRepository;

  PrivacySecuritySettingsBloc({
    required this.userRepository,
  }) : super(const PrivacySecuritySettingsState.initial()) {
    on<LoadPrivacySecuritySettingsEvent>(_onLoadSettings);
    on<UpdateAccountSecurityEvent>(_onUpdateAccountSecurity);
    on<UpdatePrivacyControlsEvent>(_onUpdatePrivacyControls);
    on<UpdateDeviceManagementEvent>(_onUpdateDeviceManagement);
    on<UpdatePermissionsEvent>(_onUpdatePermissions);
    on<UpdateAlertsMonitoringEvent>(_onUpdateAlertsMonitoring);
    on<UpdateBlockSafetyEvent>(_onUpdateBlockSafety);
    on<LogoutAllDevicesEvent>(_onLogoutAllDevices);
    on<SaveAllSettingsEvent>(_onSaveAllSettings);
    on<GetLoginSessionsEvent>(_onGetLoginSessions);
  }

  Future<void> _onLoadSettings(
    LoadPrivacySecuritySettingsEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    emit(state.copyWith(status: PrivacySecuritySettingsStatus.loading));
    try {
      final settings = await userRepository.getPrivacySecuritySettings();
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.success,
        accountSecuritySettings: settings['accountSecurity'] ?? {},
        privacyControlSettings: settings['privacyControls'] ?? {},
        deviceManagementSettings: settings['deviceManagement'] ?? {},
        permissionsSettings: settings['permissions'] ?? {},
        alertsMonitoringSettings: settings['alertsMonitoring'] ?? {},
        blockSafetySettings: settings['blockSafety'] ?? {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateAccountSecurity(
    UpdateAccountSecurityEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    try {
      final updated = {...state.accountSecuritySettings, ...event.settings};
      emit(state.copyWith(accountSecuritySettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdatePrivacyControls(
    UpdatePrivacyControlsEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    try {
      final updated = {...state.privacyControlSettings, ...event.settings};
      emit(state.copyWith(privacyControlSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateDeviceManagement(
    UpdateDeviceManagementEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    try {
      final updated = {...state.deviceManagementSettings, ...event.settings};
      emit(state.copyWith(deviceManagementSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdatePermissions(
    UpdatePermissionsEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    try {
      final updated = {...state.permissionsSettings, ...event.settings};
      emit(state.copyWith(permissionsSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateAlertsMonitoring(
    UpdateAlertsMonitoringEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    try {
      final updated = {...state.alertsMonitoringSettings, ...event.settings};
      emit(state.copyWith(alertsMonitoringSettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateBlockSafety(
    UpdateBlockSafetyEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    try {
      final updated = {...state.blockSafetySettings, ...event.settings};
      emit(state.copyWith(blockSafetySettings: updated));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLogoutAllDevices(
    LogoutAllDevicesEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    emit(state.copyWith(status: PrivacySecuritySettingsStatus.loading));
    try {
      await userRepository.logoutFromAllDevices();
      emit(state.copyWith(status: PrivacySecuritySettingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGetLoginSessions(
    GetLoginSessionsEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    emit(state.copyWith(status: PrivacySecuritySettingsStatus.loading));
    try {
      final sessions = await userRepository.getLoginSessions();
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.success,
        activeSessions: sessions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSaveAllSettings(
    SaveAllSettingsEvent event,
    Emitter<PrivacySecuritySettingsState> emit,
  ) async {
    emit(state.copyWith(status: PrivacySecuritySettingsStatus.loading));
    try {
      await userRepository.savePrivacySecuritySettings({
        'accountSecurity': state.accountSecuritySettings,
        'privacyControls': state.privacyControlSettings,
        'deviceManagement': state.deviceManagementSettings,
        'permissions': state.permissionsSettings,
        'alertsMonitoring': state.alertsMonitoringSettings,
        'blockSafety': state.blockSafetySettings,
      });
      emit(state.copyWith(status: PrivacySecuritySettingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacySecuritySettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

