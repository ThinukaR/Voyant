const express = require("express");
const router = express.Router();
const controller = require("../controllers/cosmeticController");
const protect = require("../middleware/auth");

router.use(protect);

router.get("/", controller.getAvatar);
router.post("/equip/:itemId", controller.equipItem);
router.get("/items", controller.getAllItems);
router.post("/unlock/:itemId", controller.unlockItem);

module.exports = router;
