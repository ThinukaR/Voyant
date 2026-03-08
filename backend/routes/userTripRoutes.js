const express = require("express");
const router = express.Router();
const userTripController = require("../controllers/userTripsController");
const UserSkill = require("../models/UserSkills");

// Routes
router
  .route("/")
  .post(userTripController.createTrip)
  .get(userTripController.getAllTrips);

router.get("/:id", userTripController.getTripById);

router.get("/user/:userId", userTripController.getAllUserTrips);
module.exports = router;
