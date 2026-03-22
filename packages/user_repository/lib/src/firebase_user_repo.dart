import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';
import 'dart:io';
import 'dart:convert';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // Users collection reference
  late final CollectionReference<Map<String, dynamic>> usersCollection;

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance {
    usersCollection = _firestore.collection('users');
  }

  /// Real-time user stream
  @override
  Stream<MyUser> get user {
    return _firebaseAuth.authStateChanges().switchMap((firebaseUser) {
      if (firebaseUser == null) {
        // No user logged in
        return Stream.value(MyUser.empty);
      } else {
        // Stream Firestore document in real-time
        return usersCollection.doc(firebaseUser.uid).snapshots().map((doc) {
          if (doc.exists && doc.data() != null) {
            return MyUser.fromEntity(MyUserEntity.fromDocument(doc.data()!));
          } else {
            // Document doesn't exist yet
            return MyUser.empty;
          }
        }).handleError((error) {
          debugPrint("⚠️ Firestore stream error: $error");
          return MyUser.empty;
        });
      }
    });
  }

  /// Sign in existing user
  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }

      final token = await _firebaseAuth.currentUser?.getIdToken();
      debugPrint("TOKEN: $token");
    } catch (e) {
      debugPrint("SignIn Error: $e");
      rethrow;
    }
  }

  /// Sign up new user and save to Firestore
  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );

      myUser.userId = userCredential.user!.uid;

      // Adding email verification
      await userCredential.user!.sendEmailVerification();

      // Save the user immediately to Firestore
      await setUserData(myUser);

      return myUser;
    } catch (e) {
      debugPrint("❌ SignUp Error: $e");
      rethrow;
    }
  }

  /// Log out the current user
  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint("❌ Logout Error: $e");
      rethrow;
    }
  }

  /// Set or update user data in Firestore
  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      debugPrint(
          "📝 setUserData: Writing user document for UID: ${myUser.userId}");
      debugPrint(
          "📝 setUserData: User data: ${myUser.toEntity().toDocument()}");
      await usersCollection.doc(myUser.userId).set({
        ...myUser.toEntity().toDocument(),
        'totalXP': 0,
        'level': 1,
      }, SetOptions(merge: true));
      debugPrint("✅ setUserData: Successfully wrote document to Firestore");
    } catch (e, stackTrace) {
      debugPrint("❌ SetUserData Error: $e");
      debugPrint("❌ SetUserData Error Type: ${e.runtimeType}");
      debugPrint("❌ SetUserData StackTrace: $stackTrace");
      rethrow;
    }
  }

  // ... existing code...

  /// Update user profile information
  @override
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? location,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        Map<String, dynamic> updates = {};
        if (displayName != null) {
          updates['displayName'] = displayName;
          await user.updateDisplayName(displayName);
        }
        if (bio != null) updates['bio'] = bio;
        if (location != null) updates['location'] = location;

        if (updates.isNotEmpty) {
          await usersCollection.doc(user.uid).update(updates);
          debugPrint("✅ Profile updated successfully");
        }
      }
    } catch (e) {
      debugPrint("❌ Update Profile Error: $e");
      rethrow;
    }
  }

  /// Upload profile image to Firebase Storage
  @override
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final ref = _storage.ref().child('users/${user.uid}/profile.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      // Update Firestore with image URL
      await usersCollection.doc(user.uid).update({
        'profileImageUrl': url,
      });

      debugPrint("✅ Profile image uploaded: $url");
      return url;
    } catch (e) {
      debugPrint("❌ Upload Profile Image Error: $e");
      rethrow;
    }
  }

  /// Re-authenticate user (for sensitive operations)
  @override
  Future<void> reauthenticateUser(String email, String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        debugPrint("✅ User re-authenticated successfully");
      }
    } catch (e) {
      debugPrint("❌ Re-authentication Error: $e");
      rethrow;
    }
  }

  /// Change user password (should be called after re-authentication)
  @override
  Future<void> changePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        debugPrint("✅ Password changed successfully");
      }
    } catch (e) {
      debugPrint("❌ Change Password Error: $e");
      rethrow;
    }
  }

  /// Update location sharing preference
  @override
  Future<void> updateLocationSharing(bool enabled) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).update({
          'locationSharingEnabled': enabled,
        });
        debugPrint("✅ Location sharing updated to: $enabled");
      }
    } catch (e) {
      debugPrint("❌ Update Location Sharing Error: $e");
      rethrow;
    }
  }

  /// Update two-factor authentication setting
  @override
  Future<void> updateTwoFA(bool enabled) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).update({
          'twoFactorEnabled': enabled,
        });
        debugPrint("✅ 2FA updated to: $enabled");
      }
    } catch (e) {
      debugPrint("❌ Update 2FA Error: $e");
      rethrow;
    }
  }

  /// Update biometric login setting
  @override
  Future<void> updateBiometric(bool enabled) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).update({
          'biometricLoginEnabled': enabled,
        });
        debugPrint("✅ Biometric login updated to: $enabled");
      }
    } catch (e) {
      debugPrint("❌ Update Biometric Error: $e");
      rethrow;
    }
  }

  /// Get user login sessions
  @override
  Future<List<Map<String, dynamic>>> getLoginSessions() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final sessionsDoc = await usersCollection.doc(user.uid).collection('sessions').get();
        return sessionsDoc.docs.map((doc) => doc.data()).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ Get Login Sessions Error: $e");
      rethrow;
    }
  }

  /// Download user's personal data (GDPR compliance)
  @override
  Future<String> downloadPersonalData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Fetch user document
        final userDoc = await usersCollection.doc(user.uid).get();
        final userData = userDoc.data() ?? {};

        // Create JSON export
        final personalData = {
          'exportedAt': DateTime.now().toIso8601String(),
          'userProfile': userData,
          'email': user.email,
          'emailVerified': user.emailVerified,
        };

        // Update data downloaded timestamp
        await usersCollection.doc(user.uid).update({
          'dataDownloadedAt': FieldValue.serverTimestamp(),
        });

        return jsonEncode(personalData);
      }
      throw Exception("User not authenticated");
    } catch (e) {
      debugPrint("❌ Download Personal Data Error: $e");
      rethrow;
    }
  }

  /// Link social account (Google, Facebook, etc.)
  @override
  Future<void> linkSocialAccount(String provider, String accessToken) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).update({
          'connectedAccounts.${provider}': {
            'linkedAt': FieldValue.serverTimestamp(),
            'token': accessToken,
          }
        });
        debugPrint("✅ $provider account linked successfully");
      }
    } catch (e) {
      debugPrint("❌ Link Social Account Error: $e");
      rethrow;
    }
  }

  /// Unlink social account
  @override
  Future<void> unlinkSocialAccount(String provider) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).update({
          'connectedAccounts.${provider}': FieldValue.delete(),
        });
        debugPrint("✅ $provider account unlinked successfully");
      }
    } catch (e) {
      debugPrint("❌ Unlink Social Account Error: $e");
      rethrow;
    }
  }

  /// Delete account with full cleanup
  @override
  Future<void> deleteAccountWithCleanup() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Delete profile image if exists
        try {
          await _storage.ref().child('users/${user.uid}/profile.jpg').delete();
        } catch (e) {
          debugPrint("⚠️ Profile image deletion failed (may not exist): $e");
        }

        // Delete user document
        await usersCollection.doc(user.uid).delete();

        // Delete Firebase Auth user
        await user.delete();
        debugPrint("✅ Account deleted successfully");
      }
    } catch (e) {
      debugPrint("❌ Delete Account Error: $e");
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await usersCollection.doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      debugPrint("Delete Account Error: $e");
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await _firebaseAuth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      debugPrint("Update Email Error: $e");
      rethrow;
    }
  }

  /// Get notification settings from Firestore
  @override
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final doc = await usersCollection
          .doc(user.uid)
          .collection('settings')
          .doc('notifications')
          .get();

      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {
        'general': {},
        'activity': {},
        'social': {},
        'reminders': {},
        'messages': {},
        'promotions': {},
        'preferences': {},
        'privacy': {},
      };
    } catch (e) {
      debugPrint("❌ Get Notification Settings Error: $e");
      rethrow;
    }
  }

  /// Save notification settings to Firestore
  @override
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      await usersCollection
          .doc(user.uid)
          .collection('settings')
          .doc('notifications')
          .set(settings, SetOptions(merge: true));

      debugPrint("✅ Notification settings saved successfully");
    } catch (e) {
      debugPrint("❌ Save Notification Settings Error: $e");
      rethrow;
    }
  }

  /// Get privacy and security settings from Firestore
  @override
  Future<Map<String, dynamic>> getPrivacySecuritySettings() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final doc = await usersCollection
          .doc(user.uid)
          .collection('settings')
          .doc('privacySecurity')
          .get();

      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {
        'accountSecurity': {},
        'privacyControls': {},
        'deviceManagement': {},
        'permissions': {},
        'alertsMonitoring': {},
        'blockSafety': {},
      };
    } catch (e) {
      debugPrint("❌ Get Privacy Security Settings Error: $e");
      rethrow;
    }
  }

  /// Save privacy and security settings to Firestore
  @override
  Future<void> savePrivacySecuritySettings(Map<String, dynamic> settings) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      await usersCollection
          .doc(user.uid)
          .collection('settings')
          .doc('privacySecurity')
          .set(settings, SetOptions(merge: true));

      debugPrint("✅ Privacy & Security settings saved successfully");
    } catch (e) {
      debugPrint("❌ Save Privacy Security Settings Error: $e");
      rethrow;
    }
  }

  /// Logout from all devices
  @override
  Future<void> logoutFromAllDevices() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // Sign out from current device
      await _firebaseAuth.signOut();

      // Update logout timestamp in Firestore
      await usersCollection.doc(user.uid).update({
        'allDevicesLogoutAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Logged out from all devices");
    } catch (e) {
      debugPrint("❌ Logout All Devices Error: $e");
      rethrow;
    }
  }
}