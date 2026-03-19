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