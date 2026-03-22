part of 'privacy_security_settings_bloc.dart';

abstract class PrivacySecuritySettingsEvent extends Equatable {
  const PrivacySecuritySettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrivacySecuritySettingsEvent extends PrivacySecuritySettingsEvent {
  const LoadPrivacySecuritySettingsEvent();
}

class UpdateAccountSecurityEvent extends PrivacySecuritySettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateAccountSecurityEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdatePrivacyControlsEvent extends PrivacySecuritySettingsEvent {
  final Map<String, dynamic> settings;

  const UpdatePrivacyControlsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateDeviceManagementEvent extends PrivacySecuritySettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateDeviceManagementEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdatePermissionsEvent extends PrivacySecuritySettingsEvent {
  final Map<String, dynamic> settings;

  const UpdatePermissionsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateAlertsMonitoringEvent extends PrivacySecuritySettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateAlertsMonitoringEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateBlockSafetyEvent extends PrivacySecuritySettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateBlockSafetyEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class LogoutAllDevicesEvent extends PrivacySecuritySettingsEvent {
  const LogoutAllDevicesEvent();
}

class SaveAllSettingsEvent extends PrivacySecuritySettingsEvent {
  const SaveAllSettingsEvent();
}

class GetLoginSessionsEvent extends PrivacySecuritySettingsEvent {
  const GetLoginSessionsEvent();
}

