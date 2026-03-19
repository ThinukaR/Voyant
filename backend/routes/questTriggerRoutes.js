const express = require("express");
const controller = require("../controllers/questTriggerController");

const router = express.Router();

//Check for triggers near the usr's location 
router.get("/nearby", controller.checkNearbyTriggers);

//Activate a trigger (when user enters the quest zone)
router.post("/activate", controller.activateTrigger);

//Get all triggers for a specific quest
router.get("/quest/:subQuestId", controller.getQuestTriggers);

module.exports = router;