
const express = require("express");
const createRouter = express.Router;
const router = createRouter();
const questController = require("../controllers/questController");
const protect = require("../middleware/auth");

// apply authentication middleware to all quest routes
router.use(protect);

// unified Quest Endpoints
router.get("/", questController.getAllUserQuests); // get all user quests
router.get("/:id", questController.getQuestById); // get specific quest
router.post("/:id/start", questController.startQuest); // start any quest
router.post(
    "/:id/tasks/:taskId/complete",
    questController.completeTask,
); // complete task
router.get("/:id/dialogue", questController.getQuestDialogue); // get dialogue
router.post(
    "/:id/dialogue",
    questController.processDialogueChoice,
); // process dialogue choice
router.get(
    "/triggers/nearby",
    questController.checkNearbyTriggers,
); // location triggers

module.exports = router;
