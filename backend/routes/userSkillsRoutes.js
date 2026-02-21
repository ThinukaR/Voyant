const express = require("express");
const router = express.Router();
const userSkillController = require("../controllers/userSkillsController");

// Routes
router
  .route("/")
  .get(userSkillController.getAllUserSkills)
  .post(userSkillController.unlockSkill);

router
  .route("/:id")
  .get(userSkillController.getUserSkillData)
  .patch(userSkillController.updateUserSkill)
  .delete(userSkillController.removeUserSkill);

router.patch("/:id", userSkillController.updateUserSkillLevel);
module.exports = router;
