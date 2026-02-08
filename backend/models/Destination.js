const mongoose = require("mongoose");

// Database schema for location
const databaseSchema = new mongoose.Schema({
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
    coordinates: [Number],
    required: true,
    address: String,
  },
  rating: {
    type: Number,
  },
});

const Destination = mongoose.model("Destination", databaseSchema);

module.exports = Destination;
