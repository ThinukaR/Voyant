
const mongoose = require("mongoose");

// -- Quest Progress Schema
const userQuestProgressSchema = new mongoose.Schema({
  // identifying users
  userId: {
    type: String,
    required: true,
    ref: "User",
  },

  // identifying quests
  questId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Quest",
    required: true,
  },

  // identifying quest type
  questType: {
    type: String,
    enum: ["trip_quest", "main_quest", "location_quest", "npc_quest"],
    required: true,
  },

  // progress tracking
  status: {
    type: String,
    enum: ["locked", "available", "in_progress", "completed"],
    default: "locked",
  },

  // task progress
  taskProgress: [{
    taskId: {type: mongoose.Schema.Types.ObjectId, required: true},
    isCompleted: {type: Boolean, default: false},
    completedAt: {type: Date},
    xpAwarded: {type: Number, default: 0},
  }],

  // main quest fields
  currentSubQuestIndex: {
    type: Number,
    default: 0,
    required: function() {
      return this.questType === "main_quest";
    },
  },
  subQuestProgress: [{
    subQuestId: {type: mongoose.Schema.Types.ObjectId, required: true},
    status: {
      type: String,
      enum: ["locked", "available", "in_progress", "completed"],
      default: "locked",
    },
    currentDialogueNodeId: String,
    completedDialogueNodes: [String],
    userChoices: [{
      dialogueNodeId: String,
      optionId: String,
      choice: String,
      timestamp: {type: Date, default: Date.now},
    }],
    flags: [String],
    xpEarned: {type: Number, default: 0},
  }],


  totalXPEarned: {type: Number, default: 0},
  startedAt: {type: Date, default: Date.now},
  completedAt: {type: Date},
  lastPlayedAt: {type: Date, default: Date.now},
}, {timestamps: true});

// indexing for performance
userQuestProgressSchema.index({userId: 1, status: 1});
userQuestProgressSchema.index({userId: 1, questId: 1});

const UserQuestProgress = mongoose.model(
    "UserQuestProgress",
    userQuestProgressSchema,
);
module.exports = UserQuestProgress;
