// routes/questRoutes.js
const express = require("express");
const controller = require("../controllers/questController");

const router = express.Router();

router.post("/", controller.createQuest);
router.get("/", controller.getQuestList);
router.get("/:id", controller.getQuest);
router.put("/:id", controller.updateQuest);
router.delete("/:id", controller.deleteQuest);

module.exports = router;
