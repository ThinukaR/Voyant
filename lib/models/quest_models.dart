class Quest {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int totalXP;
  final String questType;
  final Map<String, dynamic>? mapPosition;
  final String? tripId;
  final String? destinationId;
  final int? mainQuestOrder;
  final List<String>? prerequisites;
  final String? estimatedDuration;
  final int? totalSubQuests;
  final Map<String, dynamic>? startingLocation;
  final Map<String, dynamic>? triggerLocation;
  final int? triggerRadius;
  final String? npcId;
  final List<Task> tasks;
  final bool isActive;
  final Map<String, dynamic>? rewards;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  //--frontend fields
  final String userStatus;
  final int tasksCompleted;
  final int totalTasks;
  final QuestProgress? progress;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.totalXP,
    required this.questType,
    required this.tasks,
    required this.isActive,
    required this.userStatus,
    required this.tasksCompleted,
    required this.totalTasks,
    this.mapPosition,
    this.tripId,
    this.destinationId,
    this.mainQuestOrder,
    this.prerequisites,
    this.estimatedDuration,
    this.totalSubQuests,
    this.startingLocation,
    this.triggerLocation,
    this.triggerRadius,
    this.npcId,
    this.rewards,
    this.createdAt,
    this.updatedAt,
    this.progress,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
      totalXP: json['totalXP'] ?? 0,
      questType: json['questType'] ?? 'trip_quest',
      mapPosition: json['mapPosition'],
      tripId: json['tripId']?.toString(),
      destinationId: json['destinationId']?.toString(),
      mainQuestOrder: json['mainQuestOrder'],
      prerequisites: json['prerequisites']?.cast<String>(),
      estimatedDuration: json['estimatedDuration'],
      totalSubQuests: json['totalSubQuests'],
      startingLocation: json['startingLocation'],
      triggerLocation: json['triggerLocation'],
      triggerRadius: json['triggerRadius'],
      npcId: json['npcId']?.toString(),
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((task) => Task.fromJson(task))
          .toList() ?? [],
      isActive: json['isActive'] ?? true,
      rewards: json['rewards'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      userStatus: json['userStatus'] ?? 'not_started',
      tasksCompleted: json['tasksCompleted'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      progress: json['progress'] != null 
          ? QuestProgress.fromJson(json['progress'])
          : null,
    );
  }

  //getters ( helpers)
  bool get isCompleted => userStatus == 'completed';
  bool get isInProgress => userStatus == 'in_progress';
  bool get isNotStarted => userStatus == 'not_started';
  double get progressPercentage => totalTasks > 0 ? tasksCompleted / totalTasks : 0.0;
  
  //type checks 
  bool get isMainQuest => questType == 'main_quest';
  bool get isTripQuest => questType == 'trip_quest';
  bool get isLocationQuest => questType == 'location_quest';
  bool get isNpcQuest => questType == 'npc_quest';

  //location helpers
  bool get hasLocation => mapPosition != null || triggerLocation != null;
  double? get latitude => 
      mapPosition?['coordinates']?[1] ?? triggerLocation?['coordinates']?['lat'];
  double? get longitude => 
      mapPosition?['coordinates']?[0] ?? triggerLocation?['coordinates']?['lng'];
}

class Task {
  final String id;
  final String title;
  final String description;
  final int order;
  final String type;
  final bool isLocked;
  final bool isCompleted;
  final int xpReward;
  final Map<String, dynamic>? taskData;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.type,
    required this.isLocked,
    required this.isCompleted,
    required this.xpReward,
    this.taskData,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 1,
      type: json['type'] ?? 'multiple_choice',
      isLocked: json['isLocked'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      xpReward: json['xpReward'] ?? 0,
      taskData: _getTaskData(json),
    );
  }

  static Map<String, dynamic>? _getTaskData(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'multiple_choice':
        return json['multipleChoiceData'];
      case 'dialogue':
        return json['dialogueData'];
      case 'geofence':
        return json['geofenceData'];
      case 'checkin':
        return json['checkinData'];
      case 'number_input':
        return json['numberInputData'];
      case 'string_input':
        return json['stringInputData'];
      case 'true_false':
        return json['trueFalseData'];
      default:
        return json;
    }
  }

  //type helpers
  bool get isDialogue => type == 'dialogue';
  bool get isMultipleChoice => type == 'multiple_choice';
  bool get isGeofence => type == 'geofence';
  bool get isCheckin => type == 'checkin';
  bool get isNumberInput => type == 'number_input';
  bool get isStringInput => type == 'string_input';
  bool get isTrueFalse => type == 'true_false';
}

class QuestProgress {
  final String id;
  final String userId;
  final String questId;
  final String questType;
  final String status;
  final List<TaskProgress> taskProgress;
  final int currentSubQuestIndex;
  final List<SubQuestProgress>? subQuestProgress;
  final int totalXPEarned;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastPlayedAt;

  QuestProgress({
    required this.id,
    required this.userId,
    required this.questId,
    required this.questType,
    required this.status,
    required this.taskProgress,
    required this.currentSubQuestIndex,
    this.subQuestProgress,
    required this.totalXPEarned,
    this.startedAt,
    this.completedAt,
    this.lastPlayedAt,
  });

  factory QuestProgress.fromJson(Map<String, dynamic> json) {
    return QuestProgress(
      id: json['_id']?.toString() ?? '',
      userId: json['userId'] ?? '',
      questId: json['questId']?.toString() ?? '',
      questType: json['questType'] ?? '',
      status: json['status'] ?? 'not_started',
      taskProgress: (json['taskProgress'] as List<dynamic>?)
          ?.map((tp) => TaskProgress.fromJson(tp))
          .toList() ?? [],
      currentSubQuestIndex: json['currentSubQuestIndex'] ?? 0,
      subQuestProgress: (json['subQuestProgress'] as List<dynamic>?)
          ?.map((sp) => SubQuestProgress.fromJson(sp))
          .toList(),
      totalXPEarned: json['totalXPEarned'] ?? 0,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      lastPlayedAt: json['lastPlayedAt'] != null 
          ? DateTime.parse(json['lastPlayedAt']) 
          : null,
    );
  }

  //getters ( helper ) 
  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isNotStarted => status == 'not_started';
  double get progressPercentage {
    if (taskProgress.isEmpty) return 0.0;
    final completedTasks = taskProgress.where((tp) => tp.isCompleted).length;
    return completedTasks / taskProgress.length;
  }

  //getting completed task count 
  int get tasksCompleted => taskProgress.where((tp) => tp.isCompleted).length;
}

class TaskProgress {
  final String taskId;
  final bool isCompleted;
  final DateTime? completedAt;
  final int xpAwarded;

  TaskProgress({
    required this.taskId,
    required this.isCompleted,
    this.completedAt,
    required this.xpAwarded,
  });

  factory TaskProgress.fromJson(Map<String, dynamic> json) {
    return TaskProgress(
      taskId: json['taskId']?.toString() ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      xpAwarded: json['xpAwarded'] ?? 0,
    );
  }
}

class SubQuestProgress {
  final String subQuestId;
  final String status;
  final String? currentDialogueNodeId;
  final List<String> completedDialogueNodes;
  final List<UserChoice> userChoices;
  final List<String> flags;
  final int xpEarned;

  SubQuestProgress({
    required this.subQuestId,
    required this.status,
    this.currentDialogueNodeId,
    required this.completedDialogueNodes,
    required this.userChoices,
    required this.flags,
    required this.xpEarned,
  });

  factory SubQuestProgress.fromJson(Map<String, dynamic> json) {
    return SubQuestProgress(
      subQuestId: json['subQuestId']?.toString() ?? '',
      status: json['status'] ?? 'locked',
      currentDialogueNodeId: json['currentDialogueNodeId'],
      completedDialogueNodes: json['completedDialogueNodes']?.cast<String>() ?? [],
      userChoices: (json['userChoices'] as List<dynamic>?)
          ?.map((choice) => UserChoice.fromJson(choice))
          .toList() ?? [],
      flags: json['flags']?.cast<String>() ?? [],
      xpEarned: json['xpEarned'] ?? 0,
    );
  }
}

class UserChoice {
  final String choiceId;
  final String choiceText;
  final Map<String, dynamic>? nextDialogueId;
  final String? selectedOption;

  UserChoice({
    required this.choiceId,
    required this.choiceText,
    this.nextDialogueId,
    this.selectedOption,
  });

  factory UserChoice.fromJson(Map<String, dynamic> json) {
    return UserChoice(
      choiceId: json['choiceId']?.toString() ?? '',
      choiceText: json['choiceText'] ?? '',
      nextDialogueId: json['nextDialogueId'],
      selectedOption: json['selectedOption'],
    );
  }
}

class QuestListResponse {
  final List<Quest> mainQuests;
  final List<Quest> tripQuests;
  final List<Quest> locationQuests;
  final List<Quest> npcQuests;
  final List<dynamic> trips;

  QuestListResponse({
    required this.mainQuests,
    required this.tripQuests,
    required this.locationQuests,
    required this.npcQuests,
    required this.trips,
  });

  factory QuestListResponse.fromJson(Map<String, dynamic> json) {
  
    final questsData = json['quests'] ?? json;
    
    return QuestListResponse(
      mainQuests: (questsData['main_quests'] as List<dynamic>?)
          ?.map((quest) => Quest.fromJson(quest))
          .toList() ?? [],
      tripQuests: (questsData['trip_quests'] as List<dynamic>?)
          ?.map((quest) => Quest.fromJson(quest))
          .toList() ?? [],
      locationQuests: (questsData['location_quests'] as List<dynamic>?)
          ?.map((quest) => Quest.fromJson(quest))
          .toList() ?? [],
      npcQuests: (questsData['npc_quests'] as List<dynamic>?)
          ?.map((quest) => Quest.fromJson(quest))
          .toList() ?? [],
      trips: json['trips']?.cast<dynamic>() ?? [],
    );
  }
}
