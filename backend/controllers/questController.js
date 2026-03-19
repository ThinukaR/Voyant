// controllers/questController.js
const Quest = require("../models/Quest");
const UserQuestProgress = require("../models/UserQuestProgress");
const admin = require("../firebase/firebaseAdmin");
const mongoose = require("mongoose");

// get all quests for trip (including map icons)
exports.getQuestsForTrip = async (req, res) => {
  try {
    const quests = await Quest.find({ tripId: req.params.tripId }).select(
      " title difficulty totalXP mapPosition tasks",
    );
    // taking the progress of user in each quest
    const progressList = await UserQuestProgress.find({
      userId: req.userId,
      tripId: req.params.tripId,
    });

    // merge progress into each quest
    const result = quests.map((quest) => {
      const progress = progressList.find(
        (p) => p.questId.toString() === quest._id.toString(),
      );
      return {
        ...quest.toObject(),
        userStatus: progress ? progress.status : "not_started",
        tasksCompleted: progress
          ? progress.taskProgress.filter((t) => t.isCompleted).length
          : 0,
      };
    });

    return res.json(result);
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// get quest with all task details + user progress
exports.getQuest = async (req, res) => {
  console.log("req.userId:", req.userId);
  console.log("questId:", req.params.id);
  try {
    const quest = await Quest.findById(req.params.id);
    if (!quest) return res.status(404).json({ message: "Quest not found" });

    console.log("Query:", { userId: req.userId, questId: req.params.id });
    const progress = await UserQuestProgress.findOne({
      userId: req.userId,
      questId: new mongoose.Types.ObjectId(req.params.id),
    });

    console.log("Progress:", progress);
    console.log("Collection:", UserQuestProgress.collection.name);
    console.log("Searching for userId:", req.userId, "questId:", req.params.id);
    console.log("All progress docs:", await UserQuestProgress.find({}));
    console.log("Progress found:", JSON.stringify(progress)); // ← add this

    // merge task-level completion into quest tasks
    const tasks = quest.tasks.map((task) => {
      const taskProgress = progress?.taskProgress.find(
        (tp) => tp.taskId.toString() === task._id.toString(),
      );

      console.log(
        "Task:",
        task._id,
        "TaskProgress:",
        JSON.stringify(taskProgress),
      );

      return {
        ...task.toObject(),
        isCompleted: taskProgress?.isCompleted || false,
        // locked if previous task not done (linear unlock)
        isLocked: !isTaskUnlocked(task.order, progress),
      };
    });

    return res.json({
      ...quest.toObject(),
      tasks,
      userStatus: progress?.status || "not_started",
      totalXPEarned: progress?.totalXPEarned || 0,
    });
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.startQuest = async (req, res) => {
  try {
    const quest = await Quest.findById(req.params.id);
    if (!quest) return res.status(404).json({ message: "Quest not found" });

    // if it is already started
    const existing = await UserQuestProgress.findOne({
      userId: req.userId,
      questId: new mongoose.Types.ObjectId(req.params.id),
    });

    if (existing) return res.json(existing);

    // creating progress record
    const taskProgress = quest.tasks.map((task) => ({
      taskId: task._id,
      isCompleted: false,
      xpAwarded: 0,
    }));

    const progress = await UserQuestProgress.create({
      userId: req.userId,
      questId: quest._id,
      tripId: quest.tripId,
      taskProgress,
    });

    return res.status(201).json(progress);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.completeTask = async (req, res) => {
  try {
    const quest = await Quest.findById(req.params.id);
    if (!quest) return res.status(404).json({ message: "Quest not found" });

    const task = quest.tasks.id(req.params.taskId);
    if (!task) return res.status(404).json({ message: "Task not found" });

    // award XP in Firestore
    const { leveledUp, newLevel } = await awardXP(
      req.userId,
      taskProgress.xpAwarded,
    );

    const progress = await UserQuestProgress.findOne({
      userId: req.userId,
      questId: new mongoose.Types.ObjectId(req.params.id),
    });
    if (!progress)
      return res.status(400).json({ message: "Start the quest first" });

    // check task isn't already done
    const taskProgress = progress.taskProgress.find(
      (tp) => tp.taskId.toString() === task._id.toString(),
    );
    if (taskProgress?.isCompleted) {
      return res.status(400).json({ message: "Task already completed" });
    }

    // check task is actually unlocked
    if (!isTaskUnlocked(task.order, progress)) {
      return res.status(400).json({ message: "Task is locked" });
    }

    // validate the answer based on task type
    const validationResult = await validateTaskAnswer(task, req.body);
    if (!validationResult.passed) {
      return res.status(400).json({ message: validationResult.reason });
    }

    // mark complete
    taskProgress.isCompleted = true;
    taskProgress.completedAt = new Date();
    taskProgress.xpAwarded = task.xpReward;
    progress.totalXPEarned += task.xpReward;

    // check if all tasks done
    const allDone = progress.taskProgress.every((tp) => tp.isCompleted);
    if (allDone) {
      progress.status = "completed";
      progress.completedAt = new Date();
    }

    await progress.save();

    // award XP in Firestore
    await awardXP(req.userId, task.xpReward);

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

function isTaskUnlocked(taskOrder, progress) {
  if (taskOrder === 1) return true;
  if (!progress) return false;
  // count how many tasks completed
  const completedCount = progress.taskProgress.filter(
    (tp) => tp.isCompleted,
  ).length;
  return completedCount >= taskOrder - 1;
}

async function validateTaskAnswer(task, body) {
  switch (task.type) {
    case "geofence": {
      // body = { userLat, userLng }
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
    }

    case "number_input": {
      // body = { answer: 14 }
      if (parseInt(body.answer) !== task.numberInputData.correctAnswer) {
        return { passed: false, reason: "Wrong answer, try again" };
      }
      return { passed: true };
    }

    case "string_input": {
      console.log("task stringInputData:", task.stringInputData);
      console.log("full task:", JSON.stringify(task));
      const correct = task.stringInputData.correctAnswer.toLowerCase().trim();
      const given = body.answer.toLowerCase().trim();
      if (given !== correct) {
        return { passed: false, reason: "Wrong answer, try again" };
      }
      return { passed: true };
    }

    case "multiple_choice": {
      const correct = task.multipleChoiceData.correctAnswer
        .toLowerCase()
        .trim();
      const given = (body.answer || "").toLowerCase().trim();
      if (given !== correct) {
        return { passed: false, reason: "Wrong answer, try again" };
      }
      return { passed: true };
    }

    case "true_false": {
      // body = { answer: true } or { answer: false }
      const given = body.answer === true || body.answer === "true";
      if (given !== task.trueFalseData.correctAnswer) {
        return { passed: false, reason: "Wrong answer, try again" };
      }
      return { passed: true };
    }

    case "photo": {
    }
    case "checkin":
    case "find_object":
    case "spot_diff": {
    }

    default:
      return { passed: true };
  }
}

function getDistanceMeters(lat1, lng1, lat2, lng2) {
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

    // level = floor(totalXP / 1000), starts at 0
    newLevel = Math.floor(newTotalXP / 1000);

    // check if user crossed a level threshold
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

exports.createQuest = async (req, res) => {
  try {
    const doc = await Quest.create(req.body);
    return res.status(201).json(doc);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.updateQuest = async (req, res) => {
  try {
    const doc = await Quest.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.json(doc);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.deleteQuest = async (req, res) => {
  try {
    const doc = await Quest.findByIdAndDelete(req.params.id);
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.status(204).send();
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};
