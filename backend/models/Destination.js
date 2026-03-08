const mongoose = require("mongoose");

// Database schema for location
const locationSchema = new mongoose.Schema({
  destinationId: {
    type: Number,
    required: true,
    unique: true
  },
  name: {
    type: String,
    required: [true, "A destination must have a name"],
    unique: true,
    trim: true,
  },
  description: {
    type: String,
    required: [true, "Tell the travelers what to expect"],
  },
  noOfEvents: {
    type: Number,
    required: [true, "Destination should contain a set of events"],
  },
  xp: {
    type: Number,
    required: [true, "The destination should contain XP points"],
  },
  location: {
    type: {
      type: String,
      default: "Point",
      enum: ["Point"],
    },
    coordinates: {
      type: [Number],  // [longitude, latitude]
      required: true,
    }
  },
  address: {
    type: String,
  },
  rating: {
    type: Number,
  },
});

const Destination = mongoose.model("Destination", locationSchema);

module.exports = Destination;
