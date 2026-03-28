const UserReward = require("../models/UserReward");

// fetching rewards
exports.getUserRewards = async (req, res) => {
  // api endpoint
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const query = {userId: req.params.userId};

    const rewards = await UserReward.find(query)
        .populate("rewardId")
        .sort({unlockedAt: -1})
        .skip(skip)
        .limit(limit);

    const total = await UserReward.countDocuments(query);

    res.json({
      rewards,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(total / limit),
        totalRewards: total,
        hasNext: page * limit < total,
      },
    });
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};

// targetting a specific user to get rewards
exports.getUserReward = async (req, res) => {
  try {
    const userReward = await UserReward.findOne({
      userId: req.params.userId,
      rewardId: req.params.rewardId,
    }).populate("rewardId");

    if (!userReward) {
      return res.status(404).json({message: "Reward not found"});
    }

    res.json(userReward);
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};

// Unlock a reward
exports.unlockReward = async (req, res) => {
  try {
    const {userId, rewardId} = req.body;
    const xpPoints = Number(req.body.xpPoints) || 0;

    if (!rewardId) {
      return res.status(400).json({message: "rewardId is required"});
    }

    // is reward already unlocked - this prevents duplication of rewards
    const existingUnlock = await UserReward.findOne({
      userId,
      rewardId,
      unlockedAt: {$exists: true},
    });

    if (existingUnlock) {
      // if the condition returns true the if block will execute
      return res.status(409).json({message: "Reward already unlocked"});
    }

    // Create user reward
    const userReward = new UserReward({
      userId,
      rewardId,
      unlockedAt: new Date(),
      xpEarned: xpPoints,
      unlockProgress: 100,
    });

    await userReward.save(); // saving to database

    // TODO: update XP here once level scaling is finalized.

    res.status(201).json({
      message: "Reward unlocked successfully",
      userReward: await UserReward.findById(userReward._id).populate(
          "rewardId",
      ),
    });
  } catch (err) {
    res.status(400).json({message: err.message});
  }
};

// Reward popup - when a quest or sidequest has been completed
exports.claimReward = async (req, res) => {
  try {
    // XP reward is also factored in
    const {userId, rewardId, currentXP, newXP, claimedAt} = req.body;
    const xpPoints = Number(req.body.xpPoints) || 0;

    if (!rewardId) {
      return res.status(400).json({message: "rewardId is required"});
    }

    const existingClaim = await UserReward.findOne({
      userId,
      rewardId,
      unlockedAt: {$exists: true},
    });

    if (existingClaim) {
      return res.status(409).json({message: "Reward already claimed"});
    }

    // Creating user reward entry ( since the quest has been completed)
    const userReward = new UserReward({
      userId,
      rewardId,
      unlockedAt: new Date(claimedAt) || new Date(),
      xpEarned: xpPoints,
      unlockProgress: 100,
    });

    await userReward.save();

    // TODO - updating user exp should be done here

    res.status(201).json({
      message: "Reward claimed !",
      userReward: await UserReward.findById(userReward._id).populate(
          "rewardId",
      ),
      xpUpdated: {
        previous: currentXP,
        current: newXP,
        gained: newXP - currentXP,
      },
    });
  } catch (err) {
    res.status(400).json({message: err.message});
  }
};

exports.markRewardAsViewed = async (req, res) => {
  try {
    const {userId} = req.body;

    const userReward = await UserReward.findOneAndUpdate(
        {
          userId,
          rewardId: req.params.rewardId,
          unlockedAt: {$exists: true},
        },
        {viewedAt: new Date()}, // it is not marked as seen
        {new: true},
    );

    if (!userReward) {
      return res.status(404).json({message: "Reward not found"});
    }

    res.json({
      message: "Reward viewed",
      userReward: await UserReward.findById(userReward._id).populate(
          "rewardId",
      ),
    });
  } catch (err) {
    res.status(400).json({message: err.message});
  }
};

// Reward stats
exports.getRewardStats = async (req, res) => {
  try {
    const userId = req.params.userId;

    const basicStats = await UserReward.aggregate([
      {$match: {userId}},
      {
        $group: {
          _id: null,
          totalUnlocked: {$sum: 1},
          totalXP: {$sum: "$xpEarned"},
          favoriteCount: {
            $sum: {
              $cond: {if: {$eq: ["$isFavorite", true]}, then: 1, else: 0},
            },
          },
        },
      },
    ]);

    const recentUnlocks = await UserReward.find({userId}) // recent unlocks
        .populate("rewardId")
        .sort({unlockedAt: -1})
        .limit(5)
        .select("rewardId.title unlockedAt xpEarned");

    res.json({
      totalRewards: await UserReward.countDocuments({userId}),
      stats: basicStats[0] || {
        totalUnlocked: 0,
        totalXP: 0,
        favoriteCount: 0,
      },
      recentUnlocks: recentUnlocks,
    });
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};

// Favorite rewards for items users already unlocked.
exports.getFavoriteRewards = async (req, res) => {
  try {
    const favorites = await UserReward.find({
      userId: req.params.userId,
      isFavorite: true,
    })
        .populate("rewardId")
        .sort({unlockedAt: -1});

    res.json(favorites);
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};

// Add to favorites
exports.addToFavorites = async (req, res) => {
  try {
    const {userId, rewardId} = req.body;

    const userReward = await UserReward.findOneAndUpdate(
        {
          userId,
          rewardId,
          unlockedAt: {$exists: true},
        },
        {isFavorite: true},
        {new: true},
    );

    if (!userReward) {
      return res.status(404).json({message: "Reward not found"});
    }

    res.json({
      message: "Added to favorites",
      userReward: await UserReward.findById(userReward._id).populate(
          "rewardId",
      ),
    });
  } catch (err) {
    res.status(400).json({message: err.message});
  }
};

// Remove from favorites
exports.removeFromFavorites = async (req, res) => {
  try {
    const {userId} = req.body;

    const userReward = await UserReward.findOneAndUpdate(
        {
          userId,
          rewardId: req.params.rewardId,
          unlockedAt: {$exists: true},
        },
        {isFavorite: false},
        {new: true},
    );

    if (!userReward) {
      return res.status(404).json({message: "User reward not found"});
    }

    res.json({
      message: "Removed from favorites",
      userReward: await UserReward.findById(userReward._id).populate(
          "rewardId",
      ),
    });
  } catch (err) {
    res.status(400).json({message: err.message});
  }
};
