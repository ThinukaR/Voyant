class AvatarEntity {
  String aid;
  String uid;
  List<String> characterData;
  List<String> cosmetics;

  AvatarEntity({
    required this.aid,
    required this.uid,
    required this.characterData,
    required this.cosmetics,
  });

  Map<String, Object?> toDocument() {
    return {
      'aid': aid,
      'uid': uid,
      'characterData': characterData,
      'cosmetics': cosmetics,
    };
  }

  static AvatarEntity fromDocument(Map<String, Object?> doc) {
    return AvatarEntity(
      aid: doc['aid'] as String,
      uid: doc['uid'] as String,
      characterData: List<String>.from(doc['characterData'] as List? ?? []),
      cosmetics: List<String>.from(doc['cosmetics'] as List? ?? []),
    );
  }
}
