const express = require("express");
const createRouter = express.Router;
const router = createRouter();
const userTripController = require("../controllers/userTripsController");
const protect = require("../middleware/auth");

router.use(protect);

router
    .route("/")
    .post(userTripController.createTrip)
    .get(userTripController.getAllTrips);

router.get("/:id", userTripController.getTripById);

module.exports = router;
