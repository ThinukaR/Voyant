const mongoose = require("mongoose");

//quest save system 

const subQuestProgressSchema = new mongoose.Schema({
  subQuestId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SubQuest',
    required: true
  },
  status: { //status and control of the sub quest 
    type: String,
    enum: ["locked", "available", "in_progress", "completed"],
    default: "locked"
  },
  currentDialogueNodeId: String, //where user is in the npc conversation | latest npc conversation
  completedDialogueNodes: [String], //completed npc dialogue node ids
  userChoices: [{ //records user chocies
    dialogueNodeId: String,
    optionId: String,
    choice: String,
    timestamp: {
      type: Date,
      default: Date.now
    }
  }],
  flags: [String], //any user specific decision that the user makes 
  //the flag can be used as a control option for quests 
  startedAt: Date,
  completedAt: Date,
  xpEarned: Number
});

const mainQuestProgressSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    ref: 'User'
  },
  mainQuestId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MainQuest',
    required: true
  },
  status: { //status for entire quest series 
    type: String,
    enum: ["locked", "available", "in_progress", "completed"],
    default: "locked"
  },
  //whcih sub quest the player currently is in 
  currentSubQuestIndex: { 
    type: Number,
    default: 0
  },
  subQuestProgress: [subQuestProgressSchema],
  totalXPEarned: {
    type: Number,
    default: 0
  },
  flags: [String], //this will be flags that can affect the entirety of sub quests 
  startedAt: Date,
  completedAt: Date,
  lastPlayedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

//indxing
mainQuestProgressSchema.index({ userId: 1, status: 1 });
mainQuestProgressSchema.index({ userId: 1, mainQuestId: 1 });

const MainQuestProgress = mongoose.model("MainQuestProgress", mainQuestProgressSchema);
module.exports = MainQuestProgress;