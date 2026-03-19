const MainQuest = require("../models/MainQuest");
const SubQuest = require("../models/SubQuest");
const QuestTrigger = require("../models/QuestTrigger");


//main quest - Galle
const galleMainQuest = {
  title: "Galle Quest",
  description: "Explore the historic coastal city of Galle and uncover its mysteries with the Adventurer's Guild. ",
  location: "galle",
  isMainQuest: true,
  questOrder: 1,
  prerequisites: [],
  estimatedDuration: "3 -4 hours",
  totalSubQuests: 5,
  isAvailable: true,
  startingLocation: {
    name: "Galle Fort",
    coordinates: { lat: 6.0236, lng: 80.2172 }
  },
  rewards: {
    xp: 500,
    items: ["Established Membership Badge", "Mysterious Map Fragment"],
    //unlocks something else as well  
  }
};

//Sub Quest 01  - Meeting Guild Master 
const meetingGuildmasterSubQuest = {
  title: "Meeting the Guildmaster",
  description: "Meet Thorvald, the Guildmaster of Galle, introduce yourself to the Adventurers Guild.",
  questOrder: 1,
  location: {
    name: "Adventurers Guild - Galle",
    coordinates: { lat: 6.0236, lng: 80.2172 }
  },
  npc: {
    name: "Thorvald",
    avatar: " ", //add png of the guildmaster 
    role: "Guildmaster"
  },
  type: "dialogue",
  dialogueNodes: [
    {
      id: "welcome_01",
      npcName: "Thorvald",
      npcAvatar: " ", //add png of the guildmaster 
      dialogueText: "Hello there! It seems you are new to this area. The adventurers guild warmly welcomes you. My name is Thorvald and I am the guildmaster of this area.",
      emotion: "neutral",
      isAutoAdvance: false,
      autoAdvanceDelay: 2000,
      options: [
        {
          id: "continue_01",
          text: "Continue listening",
          type: "choice",
          nextDialogueId: "welcome_02",
          action: "continue",
          conditions: {
            requiresReference: false
          },
          consequences: {}
        }
      ]
    },
    {
      id: "welcome_02",
      npcName: "Thorvald",
      npcAvatar: " ", //add png of the guildmaster 
      dialogueText: "It's quite refreshing to see a new face. Did perhaps another guild member recommend you?",
      emotion: "neutral",
      isAutoAdvance: false,
      autoAdvanceDelay: 2000,
      options: [
        {
          id: "yes_referral",
          text: "Yes, someone recommended me",
          type: "input",
          nextDialogueId: "referral_response",
          action: "check_reference",
          conditions: {
            requiresReference: true
          },
          consequences: {
            addFlag: "has_referral"
          }
        },
        {
          id: "no_referral",
          text: "Nope, I came on my own",
          type: "choice",
          nextDialogueId: "no_referral_response",
          action: "continue",
          conditions: {
            requiresReference: false
          },
          consequences: {
            addFlag: "self_started"
          }
        }
      ]
    },
    {
      id: "referral_response",
      npcName: "Thorvald",
      npcAvatar: " ",
      dialogueText: "Oh ho, so you were recommended by them. That's wonderful! Any friend of theirs is a friend of mine.",
      emotion: "happy",
      isAutoAdvance: false,
      autoAdvanceDelay: 2000,
      options: [
        {
          id: "complete_quest_referral",
          text: "Thank you for the warm welcome",
          type: "choice",
          nextDialogueId: null,
          action: "complete_quest",
          conditions: {
            requiresReference: false
          },
          consequences: {
            addFlag: "welcomed_with_referral"
          }
        }
      ]
    },
    {
      id: "no_referral_response",
      npcName: "Thorvald",
      npcAvatar: " ",
      dialogueText: "Oh no worries, no worries. I was just a tad curious. It takes courage to venture out on your own!",
      emotion: "neutral",
      isAutoAdvance: false,
      autoAdvanceDelay: 2000,
      options: [
        {
          id: "complete_quest_no_referral",
          text: "Thank you for understanding",
          type: "choice",
          nextDialogueId: null,
          action: "complete_quest",
          conditions: {
            requiresReference: false
          },
          consequences: {
            addFlag: "welcomed_without_referral"
          }
        }
      ]
    }
  ],
  startDialogueId: "welcome_01",
  isCompleted: false,
  completionConditions: {
    requiredFlags: [],
    forbiddenFlags: [],
    requiredDialogueNodes: []
  },
  rewards: {
    xp: 50,
    items: ["Guild Introduction Letter"],
    flags: ["guild_access_granted"]
  },
  prerequisites: {
    completedSubQuests: [],
    requiredFlags: []
  }
};

//inserting info into mongoDB
async function seedQuestData() {
  try {
    console.log("Seeding quest data...");

    //creating main quest
    const mainQuest = new MainQuest(galleMainQuest);
    const savedMainQuest = await mainQuest.save();
    console.log("Created main quest:", savedMainQuest.title);

    //creating sub-quest connected to the main quest
    const subQuestData = {
      ...meetingGuildmasterSubQuest,
      mainQuestId: savedMainQuest._id
    };
    
    const subQuest = new SubQuest(subQuestData);
    const savedSubQuest = await subQuest.save();
    console.log("Created sub-quest:", savedSubQuest.title);

    //creating quest trigger for guildmaster location
    const guildmasterTrigger = new QuestTrigger({
      subQuestId: savedSubQuest._id,
      triggerType: 'location',
      location: {
        name: "Adventurers Guild - Galle",
        coordinates: {
          lat: 6.0236,
          lng: 80.2172
        },
        radius: 50, 
        address: "Galle Fort, Galle, Sri Lanka",
        description: "The Guildmaster awaits"
      },
      conditions: {
        requiredLevel: 1,
        requiredItems: [],
        requiredFlags: []
      },
      triggerOnce: true,
      isActive: true,
      actions: {
        startQuest: true,
        showNotification: {
          title: "Quest Available!",
          message: "Meet Thorvald, the Guildmaster of Galle",
          icon: "quest_marker"
        },
        spawnNPC: {
          name: "Thorvald",
          avatar: " ", 
          location: {
            lat: 6.0236,
            lng: 80.2172
          }
        }
      },
      priority: 10,
      category: 'main_quest'
    });

    const savedTrigger = await guildmasterTrigger.save();
    console.log("Created quest trigger:", savedTrigger.location.name);

    console.log("Quest data seeded successfully!");
    return { 
      mainQuest: savedMainQuest, 
      subQuest: savedSubQuest,
      trigger: savedTrigger
    };
  } catch (error) {
    console.error("Error seeding quest data:", error);
    throw error;
  }
}

module.exports = { seedQuestData };
