const express = require("express");
const createRouter = express.Router;
const router = createRouter();
const avatarController = require("../controllers/avatarController");

// Routes
router
    .route("/:id")
    .get(avatarController.getAvatar)
    .patch(avatarController.updateAvatar)
    .delete(avatarController.deleteAvatar);

router.patch("/user/:userId", avatarController.updateCosmetics);

router
    .route("/")
    .post(avatarController.createAvatar)
    .get(avatarController.getAllAvatars);
module.exports = router;
