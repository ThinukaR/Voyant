const express = require("express");
const controller = require("../controllers/userRewardController");

const router = express.Router();

// Get user rewards 
router.get("/user/:userId", controller.getUserRewards);

// Get specific user reward
router.get("/user/:userId/reward/:rewardId", controller.getUserReward);

// Unlock a reward
router.post("/unlock", controller.unlockReward);

// Claim a reward ( During quest completion )
router.post("/claim", controller.claimReward);

// Mark reward as viewed
router.put("/reward/:rewardId/viewed", controller.markRewardAsViewed);

// Get reward stats
router.get("/user/:userId/stats", controller.getRewardStats);

// Get favorite rewards
router.get("/user/:userId/favorites", controller.getFavoriteRewards);

// Add to favorites
router.post("/reward/:rewardId/favorite", controller.addToFavorites);

// Remove from favorites
router.delete("/reward/:rewardId/favorite", controller.removeFromFavorites);

module.exports = router;
