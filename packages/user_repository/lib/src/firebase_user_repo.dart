import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          log("Firestore stream error: $error");
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
      log("SignIn Error: $e");
      rethrow;
    }
  }

  /// Sign up new user and save to Firestore
  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );

      myUser.userId = userCredential.user!.uid;

      // Save the user immediately to Firestore
      await setUserData(myUser);

      return myUser;
    } catch (e) {
      log("SignUp Error: $e");
      rethrow;
    }
  }

  /// Log out the current user
  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      log("Logout Error: $e");
      rethrow;
    }
  }

  /// Set or update user data in Firestore
  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      log("setUserData: Writing user document for UID: ${myUser.userId}");
      log("setUserData: User data: ${myUser.toEntity().toDocument()}");
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument(), SetOptions(merge: true));
      log("setUserData: Successfully wrote document to Firestore");
    } catch (e) {
      log("SetUserData Error: $e");
      log("SetUserData Error Type: ${e.runtimeType}");
      rethrow;
    }
  }
}
