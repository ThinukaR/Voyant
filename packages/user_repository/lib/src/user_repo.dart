import 'package:user_repository/src/models/models.dart';
import 'dart:io';

abstract class UserRepository {

  Stream<MyUser> get user;

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> setUserData(MyUser myUser);

  Future<void> signIn(String email, String password);

  Future<void> logOut();

  // Profile Management
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? location,
  });

  Future<String> uploadProfileImage(File imageFile);

  // Password Management
  Future<void> reauthenticateUser(String email, String password);

  Future<void> changePassword(String newPassword);

  // Preferences
  Future<void> updateLocationSharing(bool enabled);

  Future<void> updateTwoFA(bool enabled);

  Future<void> updateBiometric(bool enabled);

  // Account Management
  Future<List<Map<String, dynamic>>> getLoginSessions();

  Future<String> downloadPersonalData();

  Future<void> linkSocialAccount(String provider, String accessToken);

  Future<void> unlinkSocialAccount(String provider);

  Future<void> deleteAccountWithCleanup();

  // Notification Settings
  Future<Map<String, dynamic>> getNotificationSettings();

  Future<void> saveNotificationSettings(Map<String, dynamic> settings);

  // Privacy & Security Settings
  Future<Map<String, dynamic>> getPrivacySecuritySettings();

  Future<void> savePrivacySecuritySettings(Map<String, dynamic> settings);

  Future<void> logoutFromAllDevices();

}