import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Users collection reference
  late final CollectionReference<Map<String, dynamic>> usersCollection;

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
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
        return usersCollection
            .doc(firebaseUser.uid)
            .snapshots()
            .map((doc) {
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
    } catch (e) {
      debugPrint("❌ SignIn Error: $e");
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
      debugPrint("📝 setUserData: Writing user document for UID: ${myUser.userId}");
      debugPrint("📝 setUserData: User data: ${myUser.toEntity().toDocument()}");
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument(), SetOptions(merge: true));
      debugPrint("✅ setUserData: Successfully wrote document to Firestore");
    } catch (e, stackTrace) {
      debugPrint("❌ SetUserData Error: $e");
      debugPrint("❌ SetUserData Error Type: ${e.runtimeType}");
      debugPrint("❌ SetUserData StackTrace: $stackTrace");
      rethrow;
    }
  }
}

@override
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

@override
Future<void> updateEmail(String newEmail) async {
  try {
    await _firebaseAuth.currentUser?.updateEmail(newEmail);
  } catch (e) {
    debugPrint("Update Email Error: $e");
    rethrow;
  }
}

@override
Future<void> updatePassword(String newPassword) async {
  try {
    await _firebaseAuth.currentUser?.updatePassword(newPassword);
  } catch (e) {
    debugPrint("Update Password Error: $e");
    rethrow;
  }
}