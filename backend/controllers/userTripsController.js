const UserTripData = require("../models/UserTrips.js");

// Create group
exports.createTrip = async (req, res) => {
  try {
    const newUserTrip = await UserTripData.create(req.body);
    res.status(201).json({
      status: "success",
      data: { trip: newUserTrip },
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

// Get all groups
exports.getAllTrips = async (req, res) => {
  try {
    const userTrips = await UserTripData.find();
    res.status(200).json(userTrips);
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

// Get single group by ID
exports.getTripById = async (req, res) => {
  try {
    const userTrip = await UserTripData.findById(req.params.id);
    if (!userTrip) {
      return res.status(404).json({
        status: "fail",
        message: "User trip not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: { userTrip },
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

// Get user's groups - all the groups the user is in
exports.getAllUserTrips = async (req, res) => {
  try {
    const userId = req.params.userId;
    const userTrips = await UserTripData.find({
      userId: userId,
    });

    res.status(200).json({
      status: "success",
      results: userTrips.length,
      data: { trips: userTrips },
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.startTrip = async (req, res) => {
  try {
    const trip = await UserTripData.findById(req.params.tripId);
    if (!trip) return res.status(404).json({ message: "Trip not found" });
    return res.json({ message: "Trip started", trip });
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};
