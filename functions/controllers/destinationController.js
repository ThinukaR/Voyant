const Destination = require("../models/Destination.js");

exports.createDestination = async (req, res) => {
  try {
    const newDestination = await Destination.create(req.body);

    res.status(201).json({
      status: "success",
      data: {destination: newDestination},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.getDestinationDetails = async (req, res) => {
  try {
    const destination = await Destination.findById(req.params.id);
    if (!destination) {
      return res.status(404).json({
        status: "fail",
        message: "Destination not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: {destination},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.getAllDestinations = async (req, res) => {
  try {
    const destinations = await Destination.find({userId: req.params.userId});
    res.status(200).json({
      status: "success",
      results: destinations.length,
      data: destinations,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      message: err.message,
    });
  }
};
