const express = require("express");
const createRouter = express.Router;
const router = createRouter();
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

router.get("/classes", skillController.getAllClasses);
router.get("/classes/:classId/skills", skillController.getSkillsForClass);

module.exports = router;
