const mongoose = require("mongoose");
const Quest = require("../models/Quest");
const UserQuestProgress = require("../models/UserQuestProgress");


const unifiedQuests = [
  //NPC quests 
  {
    questType: "main_quest",
    title: "Galle Quest",
    description: "Explore the historic coastal city of Galle and uncover its mysteries with the Adventurer's Guild.",
    mainQuestOrder: 1,
    prerequisites: [],
    estimatedDuration: "3-4 hours",
    totalSubQuests: 5,
    startingLocation: {
      name: "Galle Fort",
      coordinates: { lat: 6.0236, lng: 80.2172 }
    },
    rewards: {
      xp: 500,
      items: ["Established Membership Badge", "Mysterious Map Fragment"],
      unlocks: ["Guild Access"]
    },
    tasks: [
      {
        title: "Meet Guildmaster",
        description: "Meet Thorvald, Guildmaster of Galle",
        order: 1,
        type: "dialogue",
        dialogueData: {
          npcName: "Thorvald",
          npcAvatar: "guildmaster_avatar.png",
          dialogueText: "Hello there! It seems you are new to this area. The adventurers guild warmly welcomes you.",
          emotion: "neutral",
          options: [
            {
              text: "Continue listening",
              type: "choice",
              nextDialogueId: "welcome_02",
              action: "continue"
            }
          ]
        }
      }
    ],
    isActive: true
  },

  //Other quests 
  {
    questType: "trip_quest",
    tripId: "69b91bab534609313f75c46c",
    destinationId: "69b91b69534609313f75c467",
    title: "The Watchers of the West",
    description: "The western Wall was never the glamorous side of the fort. No lighthouse, no pretty streets.",
    difficulty: "Medium",
    totalXP: 300,
    mapPosition: {
      type: "Point",
      coordinates: [80.2138, 6.0291]
    },
    tasks: [
      {
        title: "The Sentry's Post",
        description: "You're standing at Sentry Point on the western wall.",
        order: 1,
        type: "multiple_choice",
        multipleChoiceData: {
          question: "What was a sentry's primary role at this position?",
          options: [
            { text: "Watch for enemies", value: "watchman" },
            { text: "Signal with flags", value: "signaler" },
            { text: "Guide ships", value: "pilot" }
          ],
          correctAnswer: "watchman"
        },
        xpReward: 50
      },
      {
        title: "Patrol Route",
        description: "Walk the western wall perimeter.",
        order: 2,
        type: "geofence",
        geofenceData: {
          coordinates: [
            [80.2138, 6.0291], // Sentry Point
            [80.2140, 6.0295]  // West Corner
          ],
          radiusMeters: 100
        },
        xpReward: 75
      }
    ],
    isActive: true
  },

  //location based 
  {
    questType: "location_quest",
    triggerLocation: {
      name: "Hidden Cove",
      coordinates: { lat: 6.0500, lng: 80.2000 }
    },
    triggerRadius: 50,
    title: "Discover Hidden Cove",
    description: "Find the secret cove hidden along the southern coast.",
    tasks: [
      {
        title: "Reach the Cove",
        description: "Travel to the hidden cove location.",
        order: 1,
        type: "checkin",
        checkinData: {
          coordinates: [6.0500, 80.2000],
          radiusMeters: 20
        },
        xpReward: 100
      }
    ],
    isActive: true
  }
];

//Seed functionality 
async function seedUnifiedQuests() {
  try {
    console.log("Seeding unified quest system...");
    
    //clear existing data
    await Quest.deleteMany({});
    await UserQuestProgress.deleteMany({});
    
    //insert unified quests
    await Quest.insertMany(unifiedQuests);
    
    console.log(`Seeded ${unifiedQuests.length} unified quests`);
    console.log("Quest types seeded:");
    console.log("  - Main quests:", unifiedQuests.filter(q => q.questType === 'main_quest').length);
    console.log("  - Trip quests:", unifiedQuests.filter(q => q.questType === 'trip_quest').length);
    console.log("  - Location quests:", unifiedQuests.filter(q => q.questType === 'location_quest').length);
    
    process.exit(0);
  } catch (error) {
    console.error("Error seeding unified quests:", error);
    process.exit(1);
  }
}

//run if called directly 
if (require.main === module) {
  seedUnifiedQuests();
}

module.exports = { seedUnifiedQuests, unifiedQuests };
