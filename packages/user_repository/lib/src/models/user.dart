import '../entities/entities.dart';

export 'user.dart';

class MyUser {

  String userId;
  String email;
  String username;
  String? displayName;
  String? bio;
  String? location;
  String? profileImageUrl;
  bool locationSharingEnabled;
  bool twoFactorEnabled;
  bool biometricLoginEnabled;
  DateTime? lastLoginAt;
  Map<String, dynamic>? connectedAccounts;
  DateTime? dataDownloadedAt;

  MyUser({
    required this.userId,
    required this.email,
    required this.username,
    this.displayName,
    this.bio,
    this.location,
    this.profileImageUrl,
    this.locationSharingEnabled = false,
    this.twoFactorEnabled = false,
    this.biometricLoginEnabled = false,
    this.lastLoginAt,
    this.connectedAccounts,
    this.dataDownloadedAt,
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    username: '',
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      username: username,
      displayName: displayName,
      bio: bio,
      location: location,
      profileImageUrl: profileImageUrl,
      locationSharingEnabled: locationSharingEnabled,
      twoFactorEnabled: twoFactorEnabled,
      biometricLoginEnabled: biometricLoginEnabled,
      lastLoginAt: lastLoginAt,
      connectedAccounts: connectedAccounts,
      dataDownloadedAt: dataDownloadedAt,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      username: entity.username,
      displayName: entity.displayName,
      bio: entity.bio,
      location: entity.location,
      profileImageUrl: entity.profileImageUrl,
      locationSharingEnabled: entity.locationSharingEnabled,
      twoFactorEnabled: entity.twoFactorEnabled,
      biometricLoginEnabled: entity.biometricLoginEnabled,
      lastLoginAt: entity.lastLoginAt,
      connectedAccounts: entity.connectedAccounts,
      dataDownloadedAt: entity.dataDownloadedAt,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $username';
  }

}