const express = require("express");
const router = express.Router();
const avatarController = require("../controllers/avatarController");

// Routes
router
  .route("/:id")
  .get(avatarController.getAvatar)
  .patch(avatarController.updateAvatar)
  .delete(avatarController.deleteAvatar);

router.patch("/:id", avatarController.updateCosmetics);

router
  .route("/")
  .post(avatarController.createAvatar)
  .get(avatarController.getAllAvatars);
module.exports = router;
