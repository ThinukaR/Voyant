const Quest = require("../models/Quest");
const UserQuestProgress = require("../models/UserQuestProgress");
const UserTrips = require("../models/UserTrips");
const admin = require("../firebase/firebaseAdmin");
const mongoose = require("mongoose");

//get all quests
exports.getAllUserQuests = async (req, res) => {
  try {
    const userId = req.userId;

    //get user's trips with their quests
    const userTrips = await UserTrips.find({ userId });
    const tripIds = userTrips.map((trip) => trip.tripID);

    //get all quests for user (trip, main, location, npc)
    const allQuests = await Quest.find({
      $or: [
        { tripId: { $in: tripIds } }, // Trip quests
        { questType: "main_quest" }, // Main quests (always available)
        { questType: "location_quest" }, // Location quests
        { questType: "npc_quest" }, // NPC quests
      ],
    });

    //get user's progress for these quests
    const progressList = await UserQuestProgress.find({
      userId,
      questId: { $in: allQuests.map((q) => q._id) },
    });

    //merge progress into quests
    const result = allQuests.map((quest) => {
      const progress = progressList.find(
        (p) => p.questId.toString() === quest._id.toString(),
      );

      return {
        ...quest.toObject(),
        userStatus: progress ? progress.status : "not_started",
        tasksCompleted: progress
          ? progress.taskProgress.filter((t) => t.isCompleted).length
          : 0,
        totalTasks: quest.tasks.length,
        progress: progress || null,
      };
    });

    //grouping quests by type
    const groupedQuests = {
      main_quests: result.filter((q) => q.questType === "main_quest"),
      trip_quests: result.filter((q) => q.questType === "trip_quest"),
      location_quests: result.filter((q) => q.questType === "location_quest"),
      npc_quests: result.filter((q) => q.questType === "npc_quest"),
    };

    return res.json({
      quests: groupedQuests,
      trips: userTrips,
      allQuests: result,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

//get quest by ID
exports.getQuestById = async (req, res) => {
  try {
    const quest = await Quest.findById(req.params.id);
    if (!quest) return res.status(404).json({ message: "Quest not found" });

    const progress = await UserQuestProgress.findOne({
      userId: req.userId,
      questId: new mongoose.Types.ObjectId(req.params.id),
    });

    return res.json({
      ...quest.toObject(),
      userStatus: progress?.status || "not_started",
      totalXPEarned: progress?.totalXPEarned || 0,
      progress: progress || null, // <-- ADD THIS
    });
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

//start quest
exports.startQuest = async (req, res) => {
  try {
    const quest = await Quest.findById(req.params.id);
    if (!quest) return res.status(404).json({ message: "Quest not found" });

    //checks if already started
    const existing = await UserQuestProgress.findOne({
      userId: req.userId,
      questId: new mongoose.Types.ObjectId(req.params.id),
    });

    if (existing) return res.json(existing);

    const questType = quest.questType;
    //creating progress record
    const taskProgress = (quest.tasks || []).map((task) => ({
      taskId: task._id,
      isCompleted: false,
      xpAwarded: 0,
    }));

    // For main quests: create placeholder subQuestProgress entries so index 0 is valid
    const totalSubQuests =
      questType === "main_quest" ? quest.totalSubQuests || 0 : 0;

    const subQuestProgress =
      questType === "main_quest" && totalSubQuests > 0
        ? Array.from({ length: totalSubQuests }, (_, idx) => ({
            // placeholder ObjectId; schema requires subQuestId
            subQuestId: new mongoose.Types.ObjectId(),
            status: idx === 0 ? "available" : "locked",
            xpEarned: 0,
            completedDialogueNodes: [],
            userChoices: [],
            flags: [],
          }))
        : [];

    const progress = await UserQuestProgress.create({
      userId: req.userId,
      questId: quest._id,
      tripId: quest.tripId,
      taskProgress,
      status: "in_progress",
      startedAt: new Date(),
      questType: questType,

      // main quest fields (safe)
      currentSubQuestIndex:
        questType === "main_quest" && totalSubQuests > 0 ? 0 : 0,
      subQuestProgress,
    });

    return res.status(201).json(progress);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

//complete task
exports.completeTask = async (req, res) => {
  try {
    const quest = await Quest.findById(req.params.id);
    if (!quest) return res.status(404).json({ message: "Quest not found" });

    const task = quest.tasks.id(req.params.taskId);
    if (!task) return res.status(404).json({ message: "Task not found" });

    //award XP in Firestore
    const { leveledUp, newLevel } = await awardXP(req.userId, task.xpReward);

    const progress = await UserQuestProgress.findOne({
      userId: req.userId,
      questId: new mongoose.Types.ObjectId(req.params.id),
    });

    if (!progress)
      return res.status(400).json({ message: "Start the quest first" });

    //check - if task is alredy done or not
    const taskProgress = progress.taskProgress.find(
      (tp) => tp.taskId.toString() === task._id.toString(),
    );

    if (taskProgress?.isCompleted) {
      return res.status(400).json({ message: "Task already completed" });
    }

    //validation of answer
    const validationResult = await validateTaskAnswer(task, req.body);
    if (!validationResult.passed) {
      return res.status(400).json({ message: validationResult.reason });
    }

    //mark complete
    taskProgress.isCompleted = true;
    taskProgress.completedAt = new Date();
    taskProgress.xpAwarded = task.xpReward;
    progress.totalXPEarned += task.xpReward;

    //check - if all the tasks done
    const allDone = progress.taskProgress.every((tp) => tp.isCompleted);
    if (allDone) {
      progress.status = "completed";
      progress.completedAt = new Date();
    }

    await progress.save();

    return res.json({
      passed: true,
      xpAwarded: task.xpReward,
      questCompleted: allDone,
      totalXPEarned: progress.totalXPEarned,
      leveledUp,
      newLevel,
    });
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

//get dialogue for quest
exports.getQuestDialogue = async (req, res) => {
  try {
    const quest = await Quest.findById(req.params.id);
    if (!quest) return res.status(404).json({ message: "Quest not found" });

    const progress = await UserQuestProgress.findOne({
      userId: req.userId,
      questId: new mongoose.Types.ObjectId(req.params.id),
    });

    if (!progress) {
      return res.status(400).json({ message: "Start the quest first" });
    }

    //get current dialogue based on progress
    const currentTask = quest.tasks.id(
      progress.taskProgress.find((tp) => !tp.isCompleted)?.taskId,
    );

    if (!currentTask || currentTask.type !== "dialogue") {
      return res.status(400).json({ message: "No dialogue available" });
    }

    return res.json({
      dialogue: currentTask.dialogueData,
      questId: quest._id,
      taskId: currentTask._id,
      progress: progress,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

//process dialogue choice
exports.processDialogueChoice = async (req, res) => {
  try {
    const { choice, nextDialogueId } = req.body;
    const questId = req.params.id;

    const quest = await Quest.findById(questId);
    if (!quest) return res.status(404).json({ message: "Quest not found" });

    const progress = await UserQuestProgress.findOne({
      userId: req.userId,
      questId: new mongoose.Types.ObjectId(questId),
    });

    if (!progress) {
      return res.status(400).json({ message: "Start the quest first" });
    }

    //records user choice
    progress.userChoices = progress.userChoices || [];
    progress.userChoices.push({
      choice: choice,
      timestamp: new Date(),
    });

    //check - seeing if dialogue is complete
    if (nextDialogueId === "complete" || !nextDialogueId) {
      const currentTask = quest.tasks.id(
        progress.taskProgress.find((tp) => !tp.isCompleted)?.taskId,
      );
      if (currentTask && currentTask.type === "dialogue") {
        const taskProgress = progress.taskProgress.find(
          (tp) => tp.taskId.toString() === currentTask._id.toString(),
        );

        if (taskProgress) {
          taskProgress.isCompleted = true;
          taskProgress.completedAt = new Date();
          taskProgress.xpAwarded = currentTask.xpReward || 0;
          progress.totalXPEarned += taskProgress.xpAwarded;
        }
      }
    }

    await progress.save();

    return res.json({
      success: true,
      nextDialogueId: nextDialogueId,
      progress: progress,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

//location-based quest triggers
exports.checkNearbyTriggers = async (req, res) => {
  try {
    const { userId, lat, lng, radius = 100 } = req.query;

    const userLat = parseFloat(lat);
    const userLng = parseFloat(lng);
    const searchRadius = parseInt(radius);

    //find active nearby location triggers
    const nearbyTriggers = await QuestTrigger.find({
      triggerType: "location",
      isActive: true,
      "location.coordinates": {
        $near: {
          $geometry: {
            type: "Point",
            coordinates: [userLng, userLat],
          },
          $maxDistance: searchRadius,
        },
      },
    }).sort({ priority: -1 });

    //filter triggers based on user conditions
    const availableTriggers = [];

    for (const trigger of nearbyTriggers) {
      const alreadyTriggered = trigger.triggeredBy.some(
        (t) => t.userId === userId,
      );

      if (trigger.triggerOnce && alreadyTriggered) {
        continue;
      }

      availableTriggers.push({
        triggerId: trigger._id,
        triggerType: trigger.triggerType,
        location: trigger.location,
        actions: trigger.actions,
        distance: calculateDistance(
          userLat,
          userLng,
          trigger.location.coordinates.lat,
          trigger.location.coordinates.lng,
        ),
      });
    }

    res.json({
      triggers: availableTriggers,
      userLocation: { lat: userLat, lng: userLng },
      searchRadius,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

//helper functions
async function awardXP(userId, xp) {
  const db = admin.firestore();
  const userRef = db.collection("users").doc(userId);

  let leveledUp = false;
  let newLevel = 0;

  await db.runTransaction(async (t) => {
    const doc = await t.get(userRef);
    const currentXP = doc.exists ? doc.data().totalXP || 0 : 0;
    const currentLevel = doc.exists ? doc.data().level || 0 : 0;

    const newTotalXP = currentXP + xp;
    const newTotalSP = Math.floor(newTotalXP / 100);

    newLevel = Math.floor(newTotalXP / 1000);

    if (newLevel > currentLevel) {
      leveledUp = true;
    }

    t.set(
      userRef,
      {
        totalXP: newTotalXP,
        skillPoints: newTotalSP,
        level: newLevel,
      },
      { merge: true },
    );
  });

  return { leveledUp, newLevel };
}

function calculateDistance(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

async function validateTaskAnswer(task, body) {
  switch (task.type) {
    case "geofence":
      const distance = getDistanceMeters(
        body.userLat,
        body.userLng,
        task.geofenceData.coordinates[1],
        task.geofenceData.coordinates[0],
      );
      if (distance > task.geofenceData.radiusMeters) {
        return {
          passed: false,
          reason: `You are ${Math.round(distance)}m away. Get closer.`,
        };
      }
      return { passed: true };

    case "number_input":
      if (parseInt(body.answer) !== task.numberInputData.correctAnswer) {
        return { passed: false, reason: "Wrong answer, try again" };
      }
      return { passed: true };

    case "string_input":
      const correct = task.stringInputData.correctAnswer.toLowerCase().trim();
      const given = body.answer.toLowerCase().trim();
      if (given !== correct) {
        return { passed: false, reason: "Wrong answer, try again" };
      }
      return { passed: true };

    case "multiple_choice":
      const multipleChoiceCorrect = task.multipleChoiceData.correctAnswer
        .toLowerCase()
        .trim();
      const multipleChoiceGiven = (body.answer || "").toLowerCase().trim();
      if (multipleChoiceGiven !== multipleChoiceCorrect) {
        return { passed: false, reason: "Wrong answer, try again" };
      }
      return { passed: true };

    case "true_false":
      const trueFalseGiven = body.answer === true || body.answer === "true";
      if (trueFalseGiven !== task.trueFalseData.correctAnswer) {
        return { passed: false, reason: "Wrong answer, try again" };
      }
      return { passed: true };

    default:
      return { passed: true };
  }
}
