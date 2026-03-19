const express = require("express");
const controller = require("../controllers/mainQuestController");

const router = express.Router();

//Get available main quests for user
router.get("/user/:userId/available", controller.getAvailableMainQuests);

//Start main quest
router.post("/start", controller.startMainQuest);

//Get current sub-quest and dialogue optons 
router.get("/user/:userId/main-quest/:mainQuestId/current", controller.getCurrentSubQuest);

//Process dialogue choice
router.post("/process-choice", controller.processDialogueChoice);

//Get users overall quest progress
router.get("/user/:userId/progress", controller.getUserQuestProgress);

module.exports = router;