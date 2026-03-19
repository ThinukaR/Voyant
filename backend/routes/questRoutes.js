// routes/questRoutes.js
const express = require("express");
const controller = require("../controllers/questController");
const protect = require("../middleware/auth");
const router = express.Router();

router.use(protect); // make routes require firebae token

// Quest progress
router.get("/trip/:tripId", controller.getQuestsForTrip); // get all quest icons for the map
router.get("/:id", controller.getQuest); // get one quest + user's progress

// Progress
router.post("/:id/start", controller.startQuest); // user taps the quest icon
router.post("/:id/tasks/:taskId/complete", controller.completeTask); // submit a task answer

// Admin — you adding data via Postman
router.post("/", controller.createQuest);
router.put("/:id", controller.updateQuest);
router.delete("/:id", controller.deleteQuest);

module.exports = router;
