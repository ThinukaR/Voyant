const express = require("express");
const createRouter = express.Router;
const router = createRouter();
const userSkillController = require("../controllers/userSkillsController");
const protect = require("../middleware/auth");

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

router.use(protect);
router.post("/select-class/:classId", userSkillController.selectClass);
router.get("/my-skills", userSkillController.getUserSkills);


module.exports = router;
