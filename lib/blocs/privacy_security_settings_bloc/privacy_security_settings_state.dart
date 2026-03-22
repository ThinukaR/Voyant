part of 'privacy_security_settings_bloc.dart';

enum PrivacySecuritySettingsStatus {
  initial,
  loading,
  success,
  failure,
}

class PrivacySecuritySettingsState extends Equatable {
  final PrivacySecuritySettingsStatus status;
  final Map<String, dynamic> accountSecuritySettings;
  final Map<String, dynamic> privacyControlSettings;
  final Map<String, dynamic> deviceManagementSettings;
  final Map<String, dynamic> permissionsSettings;
  final Map<String, dynamic> alertsMonitoringSettings;
  final Map<String, dynamic> blockSafetySettings;
  final List<Map<String, dynamic>>? activeSessions;
  final String? errorMessage;

  const PrivacySecuritySettingsState({
    this.status = PrivacySecuritySettingsStatus.initial,
    this.accountSecuritySettings = const {},
    this.privacyControlSettings = const {},
    this.deviceManagementSettings = const {},
    this.permissionsSettings = const {},
    this.alertsMonitoringSettings = const {},
    this.blockSafetySettings = const {},
    this.activeSessions,
    this.errorMessage,
  });

  const PrivacySecuritySettingsState.initial()
      : this(status: PrivacySecuritySettingsStatus.initial);

  PrivacySecuritySettingsState copyWith({
    PrivacySecuritySettingsStatus? status,
    Map<String, dynamic>? accountSecuritySettings,
    Map<String, dynamic>? privacyControlSettings,
    Map<String, dynamic>? deviceManagementSettings,
    Map<String, dynamic>? permissionsSettings,
    Map<String, dynamic>? alertsMonitoringSettings,
    Map<String, dynamic>? blockSafetySettings,
    List<Map<String, dynamic>>? activeSessions,
    String? errorMessage,
  }) {
    return PrivacySecuritySettingsState(
      status: status ?? this.status,
      accountSecuritySettings: accountSecuritySettings ?? this.accountSecuritySettings,
      privacyControlSettings: privacyControlSettings ?? this.privacyControlSettings,
      deviceManagementSettings: deviceManagementSettings ?? this.deviceManagementSettings,
      permissionsSettings: permissionsSettings ?? this.permissionsSettings,
      alertsMonitoringSettings: alertsMonitoringSettings ?? this.alertsMonitoringSettings,
      blockSafetySettings: blockSafetySettings ?? this.blockSafetySettings,
      activeSessions: activeSessions ?? this.activeSessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    accountSecuritySettings,
    privacyControlSettings,
    deviceManagementSettings,
    permissionsSettings,
    alertsMonitoringSettings,
    blockSafetySettings,
    activeSessions,
    errorMessage,
  ];
}
