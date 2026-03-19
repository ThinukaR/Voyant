import 'package:freezed_annotation/freezed_annotation.dart';

part 'quest_models.freezed.dart';
part 'quest_models.g.dart';

@freezed
class MainQuest with _$MainQuest {
  const factory MainQuest({
    required String id,
    required String title,
    required String description,
    required String location,
    required bool isMainQuest,
    required int questOrder,
    required List<String> prerequisites,
    required String estimatedDuration,
    required int totalSubQuests,
    required bool isAvailable,
    required StartingLocation startingLocation,
    required QuestRewards rewards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MainQuest;

  factory MainQuest.fromJson(Map<String, dynamic> json) => _$MainQuestFromJson(json);
}

@freezed
class SubQuest with _$SubQuest {
  const factory SubQuest({
    required String id,
    required String mainQuestId,
    required String title,
    required String description,
    required int questOrder,
    required QuestLocation location,
    required NPC npc,
    required String type,
    required List<DialogueNode> dialogueNodes,
    required String startDialogueId,
    required bool isCompleted,
    required CompletionConditions completionConditions,
    required QuestRewards rewards,
    required QuestPrerequisites prerequisites,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SubQuest;

  factory SubQuest.fromJson(Map<String, dynamic> json) => _$SubQuestFromJson(json);
}

@freezed  
class DialogueNode with _$DialogueNode {

  const factory DialogueNode({
    required String id,
    required String npcName,
    required String npcAvatar,
    required String dialogueText,
    required String emotion,
    required List<DialogueOption> options,
    required bool isAutoAdvance,
    required int autoAdvanceDelay,
  }) = _DialogueNode;

  factory DialogueNode.fromJson(Map<String, dynamic> json) => _$DialogueNodeFromJson(json);
}

@freezed
class DialogueOption with _$DialogueOption {

  const factory DialogueOption({
    required String id,
    required String text,
    required String type,
    String? nextDialogueId,
    required DialogueAction action,
    required DialogueConditions conditions,
    required DialogueConsequences consequences,

  }) = _DialogueOption;

  factory DialogueOption.fromJson(Map<String, dynamic> json) => _$DialogueOptionFromJson(json);
}

@freezed
class MainQuestProgress with _$MainQuestProgress {
  const factory MainQuestProgress({
    required String id,
    required String userId,
    required String mainQuestId,
    required QuestStatus status,
    required int currentSubQuestIndex,
    required List<UserSubQuestProgress> subQuestProgress,
    required int totalXPEarned,
    required List<String> flags,
    DateTime? startedAt,
    DateTime? completedAt,
    required DateTime lastPlayedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserMainQuestProgress;

  factory MainQuestProgress.fromJson(Map<String, dynamic> json) => _$MainQuestProgressFromJson(json);
}

@freezed
class UserSubQuestProgress with _$UserSubQuestProgress {
  const factory UserSubQuestProgress({
    required String id,
    required String subQuestId,
    required QuestStatus status,
    String? currentDialogueNodeId,
    required List<String> completedDialogueNodes,
    required List<UserChoice> userChoices,
    required List<String> flags,
    DateTime? startedAt,
    DateTime? completedAt,
    required int xpEarned,
  }) = _UserSubQuestProgress;

  factory UserSubQuestProgress.fromJson(Map<String, dynamic> json) => _$UserSubQuestProgressFromJson(json);
}

@freezed
class UserChoice with _$UserChoice {
  const factory UserChoice({
    required String dialogueNodeId,
    required String optionId,
    required String choice,
    required DateTime timestamp,
  }) = _UserChoice;

  factory UserChoice.fromJson(Map<String, dynamic> json) => _$UserChoiceFromJson(json);
}

@freezed
class StartingLocation with _$StartingLocation {
  const factory StartingLocation({
    required String name,
    required Coordinates coordinates,
  }) = _StartingLocation;

  factory StartingLocation.fromJson(Map<String, dynamic> json) => _$StartingLocationFromJson(json);
}

@freezed
class QuestLocation with _$QuestLocation {
  const factory QuestLocation({
    String? name,
    Coordinates? coordinates,
  }) = _QuestLocation;

  factory QuestLocation.fromJson(Map<String, dynamic> json) => _$QuestLocationFromJson(json);
}

@freezed
class Coordinates with _$Coordinates {
  const factory Coordinates({
    required double lat,
    required double lng,
  }) = _Coordinates;

  factory Coordinates.fromJson(Map<String, dynamic> json) => _$CoordinatesFromJson(json);
}

@freezed
class NPC with _$NPC {
  const factory NPC({
    required String name,
    required String avatar,
    String? role,
  }) = _NPC;

  factory NPC.fromJson(Map<String, dynamic> json) => _$NPCFromJson(json);
}


@freezed
class QuestRewards with _$QuestRewards {
  const factory QuestRewards({
    int? xp,
    List<String>? items,
    List<String>? unlocks,
  }) = _QuestRewards;

  factory QuestRewards.fromJson(Map<String, dynamic> json) => _$QuestRewardsFromJson(json);
}

@freezed
class CompletionConditions with _$CompletionConditions {
  const factory CompletionConditions({
    required List<String> requiredFlags,
    required List<String> forbiddenFlags,
    required List<String> requiredDialogueNodes,
  }) = _CompletionConditions;

  factory CompletionConditions.fromJson(Map<String, dynamic> json) => _$CompletionConditionsFromJson(json);
}

@freezed
class QuestPrerequisites with _$QuestPrerequisites {
  const factory QuestPrerequisites({
    required List<String> completedSubQuests,
    required List<String> requiredFlags,
  }) = _QuestPrerequisites;

  factory QuestPrerequisites.fromJson(Map<String, dynamic> json) => _$QuestPrerequisitesFromJson(json);
}


@freezed
class DialogueConditions with _$DialogueConditions {
  const factory DialogueConditions({
    required bool requiresReference,
    String? referenceCode,
    String? checkField,
  }) = _DialogueConditions;

  factory DialogueConditions.fromJson(Map<String, dynamic> json) => _$DialogueConditionsFromJson(json);
}


@freezed
class DialogueConsequences with _$DialogueConsequences {
  const factory DialogueConsequences({
    String? addFlag,
    String? removeFlag,
    RelationshipChange? modifyRelationship,
  }) = _DialogueConsequences;

  factory DialogueConsequences.fromJson(Map<String, dynamic> json) => _$DialogueConsequencesFromJson(json);
}



@freezed
class RelationshipChange with _$RelationshipChange {
  const factory RelationshipChange({
    required String character,
    required int change,
  }) = _RelationshipChange;

  factory RelationshipChange.fromJson(Map<String, dynamic> json) => _$RelationshipChangeFromJson(json);
}


enum QuestStatus {
  @JsonValue('locked')
  locked,
  @JsonValue('available')
  available,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
}

enum DialogueAction { 

  @JsonValue('continue')
  continue,
  @JsonValue('complete_quest')
  completeQuest,
  @JsonValue('branch')
  branch,
  @JsonValue('require_input')
  requireInput,
  @JsonValue('check_reference')
  checkReference,
}
