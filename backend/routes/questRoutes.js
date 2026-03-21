
const express = require("express");
const router = express.Router();
const questController = require("../controllers/questController");
const protect = require("../middleware/authMiddleware");

//apply authentication middleware to all quest routes
router.use(protect);

//unified Quest Endpoints
router.get("/", questController.getAllUserQuests); //get all user quests
router.get("/:id", questController.getQuestById); //get specific quest
router.post("/:id/start", questController.startQuest); //start any quest
router.post("/:id/tasks/:taskId/complete", questController.completeTask); //complete task
router.get("/triggers/nearby", questController.checkNearbyTriggers); //location triggers

module.exports = router;
