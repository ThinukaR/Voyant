const express = require("express");
const router = express.Router();
const userTripController = require("../controllers/userTripsController");
const protect = require("../middleware/auth");

router.use(protect);

router
  .route("/")
  .post(userTripController.createTrip)
  .get(userTripController.getAllTrips);

router.get("/:id", userTripController.getTripById);
router.post("/start/:tripId", userTripController.startTrip);
module.exports = router;
