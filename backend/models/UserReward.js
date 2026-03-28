const mongoose = require("mongoose");

const userRewardSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: [true, "A user reward must belong to a user"],
  },
  rewardId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Reward",
    required: [true, "A user reward must reference a reward"],
  },
  unlockedAt: {
    type: Date,
    default: Date.now,
  },
  viewedAt: {
    type: Date,
  },
  xpEarned: {
    type: Number,
    required: true,
    min: 0,
  },
  isFavorite: {
    type: Boolean,
    default: false,
  },
  unlockProgress: {
    type: Number,
    min: 0,
    max: 100,
    default: 0,
  },
});

userRewardSchema.index({ userId: 1, rewardId: 1 });
userRewardSchema.index({ unlockedAt: 1 });

const UserReward = mongoose.model("UserReward", userRewardSchema);

module.exports = UserReward;