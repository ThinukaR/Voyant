const express = require("express");
const router = express.Router();
const destinationController = require("../controllers/destinationController");

// Routes
router.get("/:id", destinationController.getDestinationDetails);
router
  .route("/")
  .post(destinationController.createDestination)
  .get(destinationController.getAllDestinations);
module.exports = router;
