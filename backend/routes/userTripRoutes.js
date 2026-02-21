const express = require("express");
const router = express.Router();
const userTripController = require("../controllers/userTripsController");

// Routes
router
  .route("/")
  .post(userTripController.createTrip)
  .get(userTripController.getAllTrips);

router
  .route("/:id")
  .get(userTripController.getTripById)
  .get(userTripController.getAllUserTrips);
