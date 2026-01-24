import '../entities/entities.dart';

export 'user.dart';

class MyUser {

  String userId;
  String email;
  String username;

  MyUser({
    required this.userId,
    required this.email,
    required this.username,
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
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      username: entity.username,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $username';
  }

}