const express = require("express");
const router = express.Router();
const userSkillController = require("../controllers/userSkillsController");
const protect = require("../middleware/auth");

// Require auth for all user skill operations
router.use(protect);

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

router.patch("/user/:userId", userSkillController.updateUserSkillLevel);
router.post("/select-class/:classId", userSkillController.selectClass);
router.get("/my-skills", userSkillController.getUserSkills);

module.exports = router;
