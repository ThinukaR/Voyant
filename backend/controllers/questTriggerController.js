const QuestTrigger = require("../models/QuestTrigger");
const UserMainQuestProgress = require("../models/MainQuestProgress");
const SubQuest = require("../models/SubQuest");

//Checking for triggers near user location 
exports.checkNearbyTriggers = async (req, res) => {
  try {
    const { userId, lat, lng, radius = 100 } = req.query; 
    
    //convert to numbers for calculations 
    const userLat = parseFloat(lat);
    const userLng = parseFloat(lng);
    const searchRadius = parseInt(radius);
    
    //finding active nearby location triggers
    const nearbyTriggers = await QuestTrigger.find({
      triggerType: 'location',
      isActive: true,
      //triggers within a certain amount of radius within the user 
      'location.coordinates': {
        $near: {
          $geometry: {
            type: "Point",
            coordinates: [userLng, userLat] // mongo uses lng and lat 
          },
          $maxDistance: searchRadius
        }
      }
    }).populate('subQuestId').sort({ priority: -1 });
    
    //filtering triggers based on user conditions
    const availableTriggers = [];
    
    for (const trigger of nearbyTriggers) {
      //trigger check 
      const alreadyTriggered = trigger.triggeredBy.some(
        t => t.userId === userId
      );
      
      //if trigger is one time and it's already triggered, skip
      if (trigger.triggerOnce && alreadyTriggered) {
        continue; 
      }
      
      //check for nessesary quest progress
      if (trigger.subQuestId) {
        const userProgress = await UserMainQuestProgress.findOne({
          userId,
          'subQuestProgress.subQuestId': trigger.subQuestId._id
        });
        
        //skip if quest is completed or locked or user has not started the quest yet
        if (!userProgress || 
            userProgress.status === 'completed' ||
            userProgress.status === 'locked') {
          continue;
        }
        
        //find the sub quest
        const subQuestProgress = userProgress.subQuestProgress.find(
          sq => sq.subQuestId.toString() === trigger.subQuestId._id.toString()
        );
        
        if (!subQuestProgress || subQuestProgress.status !== 'available') {
          continue;
        }
      }
      
      availableTriggers.push({
        triggerId: trigger._id,
        subQuestId: trigger.subQuestId._id,
        triggerType: trigger.triggerType,
        location: trigger.location,
        actions: trigger.actions,
        distance: calculateDistance(
          userLat, userLng,
          trigger.location.coordinates.lat,
          trigger.location.coordinates.lng
        )
      });
    }
    
    res.json({
      triggers: availableTriggers,
      userLocation: { lat: userLat, lng: userLng },
      searchRadius
    });
    
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

//triggering a quest when user enters the quest zone 
exports.activateTrigger = async (req, res) => {
  try {
    const { userId, triggerId, userLocation } = req.body;
    

    //finding the trigger
    const trigger = await QuestTrigger.findById(triggerId).populate('subQuestId');
    
    if (!trigger || !trigger.isActive) {
      return res.status(404).json({ message: "Trigger not found/innactive" });
    }
    const alreadyTriggered = trigger.triggeredBy.some(
      t => t.userId === userId
    );
    
    if (trigger.triggerOnce && alreadyTriggered) {
      return res.status(409).json({ message: "Trigger has been already activated" });
    }
    
    //saving trigger activation 
    trigger.triggeredBy.push({
      userId,
      triggeredAt: new Date()
    });
    
    await trigger.save();
    
    //execute it and enable frontend to work 
    const result = await executeTriggerActions(trigger, userId, userLocation);
    
    res.json({
      message: "Trigger has been activated",
      trigger: {
        id: trigger._id,
        type: trigger.triggerType,
        location: trigger.location
      },
      result
    });
    
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

//get triggers for quest ( testing )
exports.getQuestTriggers = async (req, res) => {
  try {
    const { subQuestId } = req.params;
    
    const triggers = await QuestTrigger.find({
      subQuestId,
      isActive: true
    }).populate('subQuestId');
    
    res.json(triggers);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

//calculating distance (haversine formula)
function calculateDistance(lat1, lon1, lat2, lon2) { //;at1 and lon1 - first coordinates, lat2 and lon2 - second coordinates 
  const R = 6371e3; //earths radius 
  //convert degrees to radians 
  const φ1 = lat1 * Math.PI/180; 
  const φ2 = lat2 * Math.PI/180;
  //calculating differences 
  const Δφ = (lat2-lat1) * Math.PI/180;
  const Δλ = (lon2-lon1) * Math.PI/180;

  //haversine formula 
  const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
          Math.cos(φ1) * Math.cos(φ2) *
          Math.sin(Δλ/2) * Math.sin(Δλ/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

  return R * c; //the distance in meters
}

//executing trigger actions to get events 
async function executeTriggerActions(trigger, userId, userLocation) {
  const results = [];
  
  try {
    if (trigger.actions.startQuest && trigger.subQuestId) {
      //check - seeing if quest progress exists 
      let userProgress = await UserMainQuestProgress.findOne({
        userId,
        mainQuestId: trigger.subQuestId.mainQuestId
      });
      
      if (!userProgress) {
        //if quest progress does not exist - create new quest
        userProgress = new UserMainQuestProgress({
          userId,
          mainQuestId: trigger.subQuestId.mainQuestId,
          status: 'in_progress',
          startedAt: new Date()
        });
        
        const allSubQuests = await SubQuest.find({
          mainQuestId: trigger.subQuestId.mainQuestId
        }).sort({ questOrder: 1 });
        
        userProgress.subQuestProgress = allSubQuests.map((subQuest, index) => ({
          subQuestId: subQuest._id,
          status: index === 0 ? 'in_progress' : 'locked',
          currentDialogueNodeId: subQuest.startDialogueId,
          completedDialogueNodes: [],
          userChoices: [],
          flags: [],
          xpEarned: 0
        }));
        
        await userProgress.save();
        results.push({ action: 'quest_started', questId: userProgress._id });
      }
    }
    
    //notification action 
    if (trigger.actions.showNotification) {
      results.push({ 
        action: 'notification', 
        notification: trigger.actions.showNotification 
      });
    }
    
    //NPC spawn action
    if (trigger.actions.spawnNPC) {
      results.push({ 
        action: 'npc_spawned', 
        npc: trigger.actions.spawnNPC 
      });
    }
    
    //dialogue action
    if (trigger.actions.showDialogue) {
      results.push({ 
        action: 'dialogue_triggered', 
        dialogue: trigger.actions.showDialogue 
      });
    }
    
    return results;
    
  } catch (error) {
    console.error('Error executing trigger actions:', error);
    throw error;
  }
}