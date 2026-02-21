const express = require("express");
const router = express.Router();
const userGroupController = require("../controllers/userGroupController");

// Routes
router
  .route("/")
  .post(userGroupController.createGroup)
  .get(userGroupController.getAllGroups);

router.route("/:id").get(userGroupController.getGroupById);
router.route("/user/:userId").get(userGroupController.getUserGroups);
module.exports = router;
