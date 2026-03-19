import '../entities/entities.dart';

export 'avatar.dart';

class Avatar {
  String aid;
  String uid;
  List<String> characterData;
  List<String> cosmetics;

  Avatar({
    required this.aid,
    required this.uid,
    required this.characterData,
    required this.cosmetics,
  });

  static final empty = Avatar(
    aid: '',
    uid: '',
    characterData: [],
    cosmetics: [],
  );

  AvatarEntity toEntity() {
    return AvatarEntity(
      aid: aid,
      uid: uid,
      characterData: characterData,
      cosmetics: cosmetics,
    );
  }

  static Avatar fromEntity(AvatarEntity entity) {
    return Avatar(
      aid: entity.aid,
      uid: entity.uid,
      characterData: entity.characterData,
      cosmetics: entity.cosmetics,
    );
  }

  Avatar copyWith({
    String? aid,
    String? uid,
    List<String>? characterData,
    List<String>? cosmetics,
  }) {
    return Avatar(
      aid: aid ?? this.aid,
      uid: uid ?? this.uid,
      characterData: characterData ?? this.characterData,
      cosmetics: cosmetics ?? this.cosmetics,
    );
  }

  @override
  String toString() {
    return 'Avatar: $aid, $uid, $characterData, $cosmetics';
  }
}
