const mongoose = require("mongoose");
const taskSchema = require("./Task");

// --Quest Schema
const questSchema = new mongoose.Schema({
  // quest info
  title: {type: String, required: true},
  description: {type: String},
  difficulty: {
    type: String,
    enum: ["Easy", "Medium", "Hard"],
    default: "Easy",
  },
  totalXP: {type: Number, required: true},

  // identifying quest type
  questType: {
    type: String,
    enum: ["trip_quest", "main_quest", "location_quest", "npc_quest"],
    required: true,
  },

  // location data
  mapPosition: {
    type: {type: String, default: "Point", enum: ["Point"]},
    coordinates: [Number],
  },

  // trip based
  tripId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Trip",
    required: function() {
      return this.questType === "trip_quest";
    },
  },
  destinationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Destination",
    required: function() {
      return this.questType === "trip_quest";
    },
  },

  // main quests
  mainQuestOrder: {
    type: Number,
    required: function() {
      return this.questType === "main_quest";
    },
  },
  prerequisites: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: "Quest",
    required: function() {
      return this.questType === "main_quest";
    },
  }],
  estimatedDuration: {
    type: String,
    required: function() {
      return this.questType === "main_quest";
    },
  },
  totalSubQuests: {
    type: Number,
    required: function() {
      return this.questType === "main_quest";
    },
  },
  startingLocation: {
    name: {type: String},
    coordinates: {
      lat: Number,
      lng: Number,
    },
  },

  // location based
  triggerLocation: {
    name: String,
    coordinates: {
      lat: Number,
      lng: Number,
    },
  },
  triggerRadius: {
    type: Number,
    default: 50,
  },

  // NPC based
  npcId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "NPC",
  },


  tasks: [taskSchema],
  isActive: {
    type: Boolean,
    default: true,
  },
  rewards: {
    xp: Number,
    items: [String],
    unlocks: [String],
    cosmetics: [String],
  },
}, {timestamps: true});

// indxing for performance
questSchema.index({mapPosition: "2dsphere"});
questSchema.index({questType: 1, isActive: 1});
questSchema.index({tripId: 1});

const Quest = mongoose.model("Quest", questSchema);
module.exports = Quest;
