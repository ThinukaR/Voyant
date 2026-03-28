part of 'account_settings_bloc.dart';

abstract class AccountSettingsEvent extends Equatable {
  const AccountSettingsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileEvent extends AccountSettingsEvent {
  final String? displayName;
  final String? bio;
  final String? location;

  const UpdateProfileEvent({
    this.displayName,
    this.bio,
    this.location,
  });

  @override
  List<Object?> get props => [displayName, bio, location];
}

class UploadProfileImageEvent extends AccountSettingsEvent {
  final File imageFile;

  const UploadProfileImageEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class ChangePasswordEvent extends AccountSettingsEvent {
  final String email;
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.email,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, currentPassword, newPassword];
}

class UpdateLocationSharingEvent extends AccountSettingsEvent {
  final bool enabled;

  const UpdateLocationSharingEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateTwoFAEvent extends AccountSettingsEvent {
  final bool enabled;

  const UpdateTwoFAEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateBiometricEvent extends AccountSettingsEvent {
  final bool enabled;

  const UpdateBiometricEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class DownloadPersonalDataEvent extends AccountSettingsEvent {
  const DownloadPersonalDataEvent();
}

class LinkSocialAccountEvent extends AccountSettingsEvent {
  final String provider;
  final String accessToken;

  const LinkSocialAccountEvent({
    required this.provider,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [provider, accessToken];
}

class UnlinkSocialAccountEvent extends AccountSettingsEvent {
  final String provider;

  const UnlinkSocialAccountEvent(this.provider);

  @override
  List<Object?> get props => [provider];
}

class DeleteAccountEvent extends AccountSettingsEvent {
  final String email;
  final String password;

  const DeleteAccountEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class GetLoginSessionsEvent extends AccountSettingsEvent {
  const GetLoginSessionsEvent();
}