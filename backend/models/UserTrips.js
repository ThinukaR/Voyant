const mongoose = require("mongoose");

const userTripSchema = new mongoose.Schema({
  tripID: {
    type: Number,
    required: true,
    unique: true,
  },
  name: {
    type: String,
    required: true,
    trim: true,
  },
  location: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Destination",
    required: [true, "A quest must belong to a specific location"],
  },
  xpGained: {
    type: Number,
    required: [true, "Logged in trips should contain XP points"],
    default: 0,
  },
});

const UserTrips = mongoose.model("UserTrips", userTripSchema);

module.exports = UserTrips;
