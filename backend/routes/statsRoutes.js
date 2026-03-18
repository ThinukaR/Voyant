const express = require("express");
const router = express.Router();
const statsController = require("../controllers/statsController");
const protect = require("../middleware/auth");

router.use(protect);

router.get("/home", statsController.getHomeStats);

module.exports = router;
