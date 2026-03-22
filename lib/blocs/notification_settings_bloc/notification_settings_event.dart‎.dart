part of 'notification_settings_bloc.dart';

abstract class NotificationSettingsEvent extends Equatable {
  const NotificationSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationSettingsEvent extends NotificationSettingsEvent {
  const LoadNotificationSettingsEvent();
}

class UpdateGeneralSettingsEvent extends NotificationSettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateGeneralSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateActivitySettingsEvent extends NotificationSettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateActivitySettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateSocialSettingsEvent extends NotificationSettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateSocialSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateReminderSettingsEvent extends NotificationSettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateReminderSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdateMessageSettingsEvent extends NotificationSettingsEvent {
  final Map<String, dynamic> settings;

  const UpdateMessageSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdatePromotionSettingsEvent extends NotificationSettingsEvent {
  final Map<String, dynamic> settings;

  const UpdatePromotionSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class UpdatePreferencesEvent extends NotificationSettingsEvent {
  final Map<String, dynamic> preferences;

  const UpdatePreferencesEvent(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class UpdatePrivacySettingsEvent extends NotificationSettingsEvent {
  final Map<String, dynamic> settings;

  const UpdatePrivacySettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SaveAllSettingsEvent extends NotificationSettingsEvent {
  const SaveAllSettingsEvent();
}
