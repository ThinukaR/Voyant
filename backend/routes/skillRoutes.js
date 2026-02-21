const express = require("express");
const router = express.Router();
const skillController = require("../controllers/skillController");

// Routes
router
  .route("/")
  .get(skillController.getAllSkills)
  .post(skillController.createSkill);

router
  .route("/:id")
  .get(skillController.getSkill)
  .patch(skillController.updateSkill)
  .delete(skillController.deleteSkill);
