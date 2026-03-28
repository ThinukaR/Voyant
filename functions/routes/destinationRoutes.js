const express = require("express");
const createRouter = express.Router;
const router = createRouter();
const destinationController = require("../controllers/destinationController");

// Routes
router.get("/:id", destinationController.getDestinationDetails);
router
    .route("/")
    .post(destinationController.createDestination)
    .get(destinationController.getAllDestinations);
module.exports = router;
