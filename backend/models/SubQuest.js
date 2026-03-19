const mongoose = require("mongoose");

const dialogueOptionSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true,
  },
  text: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ["text", "input", "choice"],
    default: "choice",
  },
  nextDialogueId: String /*
  action: {
    type: {
      type: String,
      enum: ["continue", "complete_quest", "branch", "require_input", "check_reference"]
    },
    default: "continue"
  },*/,
  conditions: {
    requiresReference: Boolean,
    referenceCode: String,
    checkField: String,
  },
  consequences: {
    addFlag: String,
    removeFlag: String,
    modifyRelationship: {
      character: String,
      change: Number,
    },
  },
});

const dialogueNodeSchema = new mongoose.Schema({
  id: {
    type: String,
    required: true,
  },
  npcName: {
    type: String,
    required: true,
  },
  npcAvatar: {
    type: String,
    required: true,
  },
  dialogueText: {
    type: String,
    required: true,
  },
  emotion: {
    type: String,
    enum: ["neutral", "happy", "concerned", "excited", "serious"],
    default: "neutral",
  },
  options: [dialogueOptionSchema],
  isAutoAdvance: {
    type: Boolean,
    default: false,
  },
  autoAdvanceDelay: {
    type: Number,
    default: 2000,
  },
});

const subQuestSchema = new mongoose.Schema(
  {
    mainQuestId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "MainQuest",
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    questOrder: {
      type: Number,
      required: true,
    },
    location: {
      name: String,
      coordinates: {
        lat: Number,
        lng: Number,
      },
    },
    npc: {
      name: {
        type: String,
        required: true,
      },
      avatar: {
        type: String,
        required: true,
      },
      role: String,
    },
    type: {
      type: String,
      enum: ["dialogue", "collection", "combat", "exploration", "puzzle"],
      default: "dialogue",
    },
    dialogueNodes: [dialogueNodeSchema],
    startDialogueId: {
      type: String,
      required: true,
    },
    isCompleted: {
      type: Boolean,
      default: false,
    },
    completionConditions: {
      requiredFlags: [String],
      forbiddenFlags: [String],
      requiredDialogueNodes: [String],
    },
    rewards: {
      xp: Number,
      items: [String],
      flags: [String],
    },
    prerequisites: {
      completedSubQuests: [
        {
          type: mongoose.Schema.Types.ObjectId,
          ref: "SubQuest",
        },
      ],
      requiredFlags: [String],
    },
  },
  {
    timestamps: true,
  },
);

//indexing
subQuestSchema.index({ mainQuestId: 1, questOrder: 1 });
subQuestSchema.index({ "npc.name": 1 });

const SubQuest = mongoose.model("SubQuest", subQuestSchema);
module.exports = SubQuest;
