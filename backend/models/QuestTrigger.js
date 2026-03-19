const mongoose = require("mongoose");

const questTriggerSchema = new mongoose.Schema({
//triggers are tied to a specific sub quest, hence referencing sub quest 
  subQuestId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SubQuest', 
    required: true
  },
  triggerType: {
    type: String,
    enum: ['location', 'npc_proximity', 'item_pickup', 'time_based', 'custom'],
    required: true
  },
  
  //location based triggers
  location: {
    name: String,
    coordinates: {
      lat: { type: Number, required: true },
      lng: { type: Number, required: true }
    },
    radius: { //the trigger activates if player is within this distance
      type: Number, 
      default: 50 
    },
    address: String,
    description: String
  },
  
  //triggers that are based on npc
  npcId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'NPC' 
  },
  npcName: String,
  npcLocation: {
    lat: Number,
    lng: Number
  },
  
  //controlling when trigger is allowed
  conditions: {
    requiredLevel: Number, //level restriction 
    requiredItems: [String], //item restriction ( for future quests)
    requiredFlags: [String], //requirements for next steps in quest 
    timeOfDay: { //for quests that activate on a specific time 
      start: String, 
      end: String   
    },
    weather: [String], //weather triggers that could be optionally added later 
    dayOfWeek: [Number] //if there is a day restrctio for the quest 
  },
  
  //trigger behaviours 
  triggerOnce: {
    type: Boolean,
    default: true
  },
  isActive: {
    type: Boolean,
    default: true
  },
  
  //actions that happen from triggers
  actions: {
    startQuest: Boolean,
    showNotification: {
      title: String,
      message: String,
      icon: String
    },
    spawnNPC: {
      name: String,
      avatar: String,
      location: {
        lat: Number,
        lng: Number
      }
    },
    //optional sold effects 
    playSound: String,
    showDialogue: {
      npcName: String,
      dialogueId: String
    }
  },
  
  //to track user triggers properly and avoid any repeats 
  triggeredBy: [{
    userId: String,
    triggeredAt: {
      type: Date,
      default: Date.now
    },
    questProgressId: mongoose.Schema.Types.ObjectId
  }],
  
  //meta data
  priority: {
    type: Number,
    default: 0 //triggers with higher priority will resolve first 
  },
  category: {
    type: String,
    enum: ['main_quest', 'side_quest', 'event', 'tutorial'],
    default: 'main_quest'
  }
}, {
  timestamps: true
});

//indexing 
questTriggerSchema.index({ 'location.coordinates': '2dsphere' });
questTriggerSchema.index({ subQuestId: 1 });
questTriggerSchema.index({ triggerType: 1, isActive: 1 });

const QuestTrigger = mongoose.model("QuestTrigger", questTriggerSchema);
module.exports = QuestTrigger;