part of 'notification_settings_bloc.dart';

enum NotificationSettingsStatus {
  initial,
  loading,
  success,
  failure,
}

class NotificationSettingsState extends Equatable {
  final NotificationSettingsStatus status;
  final Map<String, dynamic> generalSettings;
  final Map<String, dynamic> activitySettings;
  final Map<String, dynamic> socialSettings;
  final Map<String, dynamic> reminderSettings;
  final Map<String, dynamic> messageSettings;
  final Map<String, dynamic> promotionSettings;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> privacySettings;
  final String? errorMessage;

  const NotificationSettingsState({
    this.status = NotificationSettingsStatus.initial,
    this.generalSettings = const {},
    this.activitySettings = const {},
    this.socialSettings = const {},
    this.reminderSettings = const {},
    this.messageSettings = const {},
    this.promotionSettings = const {},
    this.preferences = const {},
    this.privacySettings = const {},
    this.errorMessage,
  });

  const NotificationSettingsState.initial()
      : this(status: NotificationSettingsStatus.initial);

  NotificationSettingsState copyWith({
    NotificationSettingsStatus? status,
    Map<String, dynamic>? generalSettings,
    Map<String, dynamic>? activitySettings,
    Map<String, dynamic>? socialSettings,
    Map<String, dynamic>? reminderSettings,
    Map<String, dynamic>? messageSettings,
    Map<String, dynamic>? promotionSettings,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? privacySettings,
    String? errorMessage,
  }) {
    return NotificationSettingsState(
      status: status ?? this.status,
      generalSettings: generalSettings ?? this.generalSettings,
      activitySettings: activitySettings ?? this.activitySettings,
      socialSettings: socialSettings ?? this.socialSettings,
      reminderSettings: reminderSettings ?? this.reminderSettings,
      messageSettings: messageSettings ?? this.messageSettings,
      promotionSettings: promotionSettings ?? this.promotionSettings,
      preferences: preferences ?? this.preferences,
      privacySettings: privacySettings ?? this.privacySettings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    generalSettings,
    activitySettings,
    socialSettings,
    reminderSettings,
    messageSettings,
    promotionSettings,
    preferences,
    privacySettings,
    errorMessage,
  ];
}

