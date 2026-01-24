
class MyUserEntity {

  String userId;
  String email;
  String username;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.username,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
    };
  }

  static MyUserEntity fromDocument(Map<String, Object?> doc) {
    return MyUserEntity(
      userId: doc['userId'] as String,
      email: doc['email'] as String,
      username: doc['username'] as String,
    );
  }

}