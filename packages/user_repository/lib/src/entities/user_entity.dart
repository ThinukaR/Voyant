import 'package:cloud_firestore/cloud_firestore.dart';

class MyUserEntity {

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

  MyUserEntity({
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

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'locationSharingEnabled': locationSharingEnabled,
      'twoFactorEnabled': twoFactorEnabled,
      'biometricLoginEnabled': biometricLoginEnabled,
      'lastLoginAt': lastLoginAt,
      'connectedAccounts': connectedAccounts,
      'dataDownloadedAt': dataDownloadedAt,
    };
  }

  static MyUserEntity fromDocument(Map<String, Object?> doc) {
    return MyUserEntity(
      userId: doc['userId'] as String,
      email: doc['email'] as String,
      username: doc['username'] as String,
      displayName: doc['displayName'] as String?,
      bio: doc['bio'] as String?,
      location: doc['location'] as String?,
      profileImageUrl: doc['profileImageUrl'] as String?,
      locationSharingEnabled: doc['locationSharingEnabled'] as bool? ?? false,
      twoFactorEnabled: doc['twoFactorEnabled'] as bool? ?? false,
      biometricLoginEnabled: doc['biometricLoginEnabled'] as bool? ?? false,
      lastLoginAt: doc['lastLoginAt'] != null ? (doc['lastLoginAt'] as Timestamp).toDate() : null,
      connectedAccounts: doc['connectedAccounts'] as Map<String, dynamic>?,
      dataDownloadedAt: doc['dataDownloadedAt'] != null ? (doc['dataDownloadedAt'] as Timestamp).toDate() : null,
    );
  }

}