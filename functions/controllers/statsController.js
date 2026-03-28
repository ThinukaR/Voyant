const Quest = require("../models/Quest");
const UserQuestProgress = require("../models/UserQuestProgress");
const UserTripData = require("../models/UserTrips");
const mongoose = require("mongoose");

exports.getHomeStats = async (req, res) => {
  try {
    const questCount = await UserQuestProgress.countDocuments({
      userId: req.userId,
    });

    const tripCount = await UserTripData.countDocuments();

    const activeTrip = await UserTripData.findOne().sort({_id: -1});

    let activeTripProgress = null;
    if (activeTrip) {
      const questsForTrip = await Quest.find({tripId: activeTrip._id});
      const completedQuests = await UserQuestProgress.countDocuments({
        userId: req.userId,
        questId: {
          $in: questsForTrip.map((q) => new mongoose.Types.ObjectId(q._id)),
        },
        status: "completed",
      });
      activeTripProgress = {
        name: activeTrip.name,
        completedQuests,
        totalQuests: questsForTrip.length,
      };
    }

    return res.json({
      questCount,
      tripCount,
      activeTrip: activeTripProgress,
    });
  } catch (err) {
    return res.status(500).json({message: err.message});
  }
};
