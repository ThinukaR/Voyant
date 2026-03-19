const mongoose = require("mongoose");
const Quest = require("../models/Quest");

const TRIP_ID = "69b91bab534609313f75c46c";
const DEST_ID = "69b91b69534609313f75c467";

const quests = [
  {
    tripId: TRIP_ID,
    destinationId: DEST_ID,
    title: "The Watchers of the West",
    description:
      "The western wall was never the glamorous side of the fort. No lighthouse, no pretty streets. Just stone, wind, and men whose only job was to watch the sea and not blink.",
    difficulty: "Medium",
    totalXP: 300,
    mapPosition: {
      type: "Point",
      coordinates: [80.2138, 6.0291],
    },
    tasks: [
      {
        title: "The Sentry's Post",
        description: "You're standing at the Sentry Point on the western wall.",
        order: 1,
        isLocked: false,
        isCompleted: false,
        xpReward: 50,
        type: "multiple_choice",
        multipleChoiceData: {
          question: "What was a sentry's primary role at this position?",
          options: [
            "To fire the opening cannon shot in battle",
            "To watch the sea and signal approaching ships or threats",
            "To guard the gate at night",
            "To raise and lower the fort flag daily",
          ],
          correctAnswer:
            "To watch the sea and signal approaching ships or threats",
        },
      },
      {
        title: "The White Structure",
        description:
          "Near the sea over the edge of the rampart, there is a white open-roofed structure with a horizontal teal object in the middle.",
        order: 2,
        isLocked: true,
        isCompleted: false,
        xpReward: 60,
        type: "true_false",
        trueFalseData: {
          statement:
            "There is a white open-roofed structure with a teal horizontal object in the middle, visible near the sea from the rampart edge.",
          correctAnswer: true,
        },
      },
      {
        title: "Who Built the Signal Station?",
        description: "Look at the Naval Signal Station on the western wall.",
        order: 3,
        isLocked: true,
        isCompleted: false,
        xpReward: 50,
        type: "true_false",
        trueFalseData: {
          statement:
            "The Naval Signal Station on the western wall was built by the Portuguese during the original fort construction.",
          correctAnswer: false,
        },
      },
      {
        title: "Signals Across the Sea",
        description:
          "The Naval Signal Station communicated with ships before modern radio.",
        order: 4,
        isLocked: true,
        isCompleted: false,
        xpReward: 50,
        type: "multiple_choice",
        multipleChoiceData: {
          question:
            "What method did the signal station use to communicate with ships?",
          options: [
            "Cannon fire patterns",
            "Flag signals and light patterns",
            "Messenger boats",
            "Smoke signals from the tower roof",
          ],
          correctAnswer: "Flag signals and light patterns",
        },
      },
      {
        title: "Aeolus Bastion",
        description: "Stand at Aeolus Bastion without moving.",
        order: 5,
        isLocked: true,
        isCompleted: false,
        xpReward: 60,
        type: "number_input",
        numberInputData: {
          question:
            "How many cannons are in the whole area (covering up to clock tower)",
          correctAnswer: 18, // update from your data
        },
      },
      {
        title: "Bonus — Eyes on the Green",
        description: "Keep your eyes open along the western rampart grass.",
        order: 6,
        isLocked: true,
        isCompleted: false,
        xpReward: 30,
        type: "number_input",
        numberInputData: {
          question:
            "Peacocks have been spotted along this stretch. How many do you see? Enter 0 if none.",
          correctAnswer: 0,
        },
      },
    ],
  },

  {
    tripId: TRIP_ID,
    destinationId: DEST_ID,
    title: "Land's End",
    description:
      "The furthest corner of the fort from the gate — where the land stops and hands everything to the Indian Ocean. Most people never find the staircase.",
    difficulty: "Easy",
    totalXP: 200,
    mapPosition: {
      type: "Point",
      coordinates: [80.2194, 6.0247],
    },
    tasks: [
      {
        title: "Oldest Light",
        description: "Look up at the Galle Lighthouse.",
        order: 1,
        isLocked: false,
        isCompleted: false,
        xpReward: 50,
        type: "true_false",
        trueFalseData: {
          statement:
            "The Galle Lighthouse is the oldest surviving lighthouse in Sri Lanka.",
          correctAnswer: true,
        },
      },
      {
        title: "What is a Bastion?",
        description:
          "Aurora Bastion wraps around the lighthouse end of the fort.",
        order: 2,
        isLocked: true,
        isCompleted: false,
        xpReward: 50,
        type: "multiple_choice",
        multipleChoiceData: {
          question: "What does 'bastion' mean in fort architecture?",
          options: [
            "A watchtower built above the main wall",
            "A projecting section of wall that lets defenders fire along the wall's face",
            "An underground tunnel connecting two fort sections",
            "A reinforced gate with a drawbridge",
          ],
          correctAnswer:
            "A projecting section of wall that lets defenders fire along the wall's face",
        },
      },
      {
        title: "Read the Lighthouse",
        description: "Look closely at the lighthouse structure itself.",
        order: 3,
        isLocked: true,
        isCompleted: false,
        xpReward: 60,
        type: "number_input",
        numberInputData: {
          question: "What year is written on the lighthouse?",
          correctAnswer: 1938,
        },
      },
      {
        title: "Who Built Aurora?",
        description: "Look at the Aurora Bastion.",
        order: 4,
        isLocked: true,
        isCompleted: false,
        xpReward: 50,
        type: "true_false",
        trueFalseData: {
          statement:
            "Aurora Bastion was built by the British during their occupation of the fort.",
          correctAnswer: false,
        },
      },
    ],
  },

  {
    tripId: TRIP_ID,
    destinationId: DEST_ID,
    title: "The Living Streets",
    description:
      "Most people walk the inner fort streets looking up at old buildings. But people actually live here. Walk slowly.",
    difficulty: "Easy",
    totalXP: 280,
    mapPosition: {
      type: "Point",
      coordinates: [80.2151, 6.03],
    },
    tasks: [
      {
        title: "The Clockmaker's Lie",
        description: "Stand in front of the Clock Tower.",
        order: 1,
        isLocked: false,
        isCompleted: false,
        xpReward: 50,
        type: "number_input",
        numberInputData: {
          question:
            "How many clock faces can you see from where you're standing?",
          correctAnswer: 2,
        },
      },
      {
        title: "Who Built the Clock?",
        description: "Read the Clock Tower information board.",
        order: 2,
        isLocked: true,
        isCompleted: false,
        xpReward: 50,
        type: "true_false",
        trueFalseData: {
          statement:
            "The Galle Clock Tower was built during the Dutch colonial period.",
          correctAnswer: false,
        },
      },
      {
        title: "The Flag",
        description: "Look up at the Clock Tower.",
        order: 3,
        isLocked: true,
        isCompleted: false,
        xpReward: 50,
        type: "string_input",
        stringInputData: {
          instruction: "What flag is flying on the Clock Tower right now?",
          correctAnswer: "Sri Lankan flag",
        },
      },
      {
        title: "The Gem Trade",
        description: "You're standing near Geo Gems on Church Street.",
        order: 4,
        isLocked: true,
        isCompleted: false,
        xpReward: 50,
        type: "multiple_choice",
        multipleChoiceData: {
          question:
            "Galle has historically been famous for trading which gemstone?",
          options: ["Diamonds", "Rubies", "Blue Sapphires", "Emeralds"],
          correctAnswer: "Blue Sapphires",
        },
      },
      {
        title: "Still Alive",
        description: "Look around the streets inside the fort.",
        order: 5,
        isLocked: true,
        isCompleted: false,
        xpReward: 40,
        type: "true_false",
        trueFalseData: {
          statement:
            "People still live permanently inside the Galle Fort walls today.",
          correctAnswer: true,
        },
      },
    ],
  },

  {
    tripId: TRIP_ID,
    destinationId: DEST_ID,
    title: "Museum of the Deep",
    description:
      "Everything in this building was pulled from the ocean floor. Shipwrecks, lost cargo, personal belongings of sailors who never made it home. The Maritime Archaeology Museum inside Galle Fort holds 800 years of the sea's secrets.",
    difficulty: "Easy",
    totalXP: 260,
    mapPosition: {
      type: "Point",
      coordinates: [80.2178, 6.0261],
    },
    tasks: [
      {
        title: "The Main Wreck",
        description:
          "Most of the artifacts in this museum were recovered from one specific shipwreck.",
        order: 1,
        isLocked: false,
        isCompleted: false,
        xpReward: 60,
        type: "multiple_choice",
        multipleChoiceData: {
          question:
            "Which ship were most of the museum's artifacts recovered from?",
          options: ["Avondster", "De Rijp", "Hercules", "Nassau"],
          correctAnswer: "Avondster",
        },
      },
      {
        title: "Where Did They Come From?",
        description:
          "Look at the origin of the vessels represented in the museum displays.",
        order: 2,
        isLocked: true,
        isCompleted: false,
        xpReward: 60,
        type: "multiple_choice",
        multipleChoiceData: {
          question:
            "Looking at the trade vessels represented in the museum, which foreign country had the most ships passing through Galle's waters historically?",
          options: ["China", "Japan", "Indonesia", "Korea"],
          correctAnswer: "China",
        },
      },
      {
        title: "The Mannequin Display",
        description:
          "Somewhere in the museum there is a dedicated display of full-sized mannequins.",
        order: 3,
        isLocked: true,
        isCompleted: false,
        xpReward: 60,
        type: "number_input",
        numberInputData: {
          question: "How many mannequins are in the display?",
          correctAnswer: 9,
        },
      },
      {
        title: "Pipes from the Avondster",
        description:
          "Among the recovered items from the Avondster are a set of smoking pipes.",
        order: 4,
        isLocked: true,
        isCompleted: false,
        xpReward: 80,
        type: "true_false",
        trueFalseData: {
          statement:
            "There are 6 smoking pipes recovered from the Avondster on display in the museum.",
          correctAnswer: false,
        },
      },
    ],
  },
];

const seedQuests = async () => {
  try {
    await mongoose
      .connect
      //  "mongodb connection string",
      ();

    // drop the bad leftover index
    await mongoose.connection
      .collection("quests")
      .dropIndex("questId_1")
      .catch(() => {});

    // delete any null docs
    await mongoose.connection
      .collection("quests")
      .deleteMany({ questId: null });

    await Quest.deleteMany({});
    await Quest.insertMany(quests);
    console.log("Quests seeded successfully");
    mongoose.connection.close();
  } catch (err) {
    console.error("Seed failed:", err);
    mongoose.connection.close();
  }
};

seedQuests();
