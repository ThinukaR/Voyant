const mongoose = require("mongoose");

const mainQuestSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  location: {
    type: String,
    required: true,
    enum: ["colombo", "galle", "kandy", "other"]
  },
  isMainQuest: {
    type: Boolean,
    default: true
  },
  //order for the main quests 
  questOrder: {
    type: Number,
    required: true 
  },
  prerequisites: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MainQuest'
  }],
  estimatedDuration: {
    type: String, //estimated quest duration 
    required: true
  },
  totalSubQuests: {
    type: Number,
    required: true
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  startingLocation: {
    name: String,
    coordinates: {
      lat: Number,
      lng: Number
    }
  },
  rewards: {
    xp: Number,
    items: [String],
    unlocks: [String]
  }
}, {
  timestamps: true
});

const MainQuest = mongoose.model("MainQuest", mainQuestSchema);
module.exports = MainQuest;