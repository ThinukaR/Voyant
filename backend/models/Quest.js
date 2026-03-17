const mongoose = require("mongoose");
const taskSchema = require("./Task");

const questSchema = new mongoose.Schema(
  {
    tripId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Trip",
      required: true,
    },
    destinationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Destination",
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    totalXP: {
      type: Number,
      required: true,
    },
    mapPosition: {
      type: {
        type: String,
        default: "Point",
        enum: ["Point"],
      },
    },
    instructions: {
      type: String,
      required: true,
    },
    difficulty: {
      type: String,
      enum: ["Easy", "Medium", "Hard"],
      message: "{VALUE} is not a valid difficulty level",
      default: "Easy",
    },
    achievements: {
      type: String,
    },
    tasks: [taskSchema],
  },
  { timestamps: true },
);

questSchema.index({ mapPosition: "2dsphere" });
const Quest = mongoose.model("Quest", questSchema);
module.exports = Quest;
