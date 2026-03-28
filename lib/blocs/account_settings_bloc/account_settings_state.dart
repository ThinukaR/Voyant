part of 'account_settings_bloc.dart';

enum AccountSettingsStatus {
  initial,
  loading,
  success,
  failure,
  accountDeleted,
}

class AccountSettingsState extends Equatable {
  final AccountSettingsStatus status;
  final String? displayName;
  final String? bio;
  final String? location;
  final String? profileImageUrl;
  final bool locationSharingEnabled;
  final bool twoFactorEnabled;
  final bool biometricLoginEnabled;
  final String? errorMessage;
  final String? downloadedData;
  final List<Map<String, dynamic>>? loginSessions;

  const AccountSettingsState({
    this.status = AccountSettingsStatus.initial,
    this.displayName,
    this.bio,
    this.location,
    this.profileImageUrl,
    this.locationSharingEnabled = false,
    this.twoFactorEnabled = false,
    this.biometricLoginEnabled = false,
    this.errorMessage,
    this.downloadedData,
    this.loginSessions,
  });

  const AccountSettingsState.initial()
      : this(status: AccountSettingsStatus.initial);

  AccountSettingsState copyWith({
    AccountSettingsStatus? status,
    String? displayName,
    String? bio,
    String? location,
    String? profileImageUrl,
    bool? locationSharingEnabled,
    bool? twoFactorEnabled,
    bool? biometricLoginEnabled,
    String? errorMessage,
    String? downloadedData,
    List<Map<String, dynamic>>? loginSessions,
  }) {
    return AccountSettingsState(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      biometricLoginEnabled: biometricLoginEnabled ?? this.biometricLoginEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadedData: downloadedData ?? this.downloadedData,
      loginSessions: loginSessions ?? this.loginSessions,
    );
  }

  @override
  List<Object?> get props => [
    status,
    displayName,
    bio,
    location,
    profileImageUrl,
    locationSharingEnabled,
    twoFactorEnabled,
    biometricLoginEnabled,
    errorMessage,
    downloadedData,
    loginSessions,
  ];
}