const express = require("express");
const createRouter = express.Router;
const router = createRouter();
const statsController = require("../controllers/statsController");
const protect = require("../middleware/auth");

router.use(protect);

router.get("/home", statsController.getHomeStats);

module.exports = router;
