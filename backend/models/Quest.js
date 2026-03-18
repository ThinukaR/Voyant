const mongoose = require("mongoose");
const taskSchema = require("./Task");

const questSchema = new mongoose.Schema(
  {
    tripId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Trip",
      required: true,
    },
    destinationId: { type: mongoose.Schema.Types.ObjectId, ref: "Destination" },
    title: { type: String, required: true },
    description: { type: String },
    difficulty: {
      type: String,
      enum: ["Easy", "Medium", "Hard"],
      default: "Easy",
    },
    totalXP: { type: Number, required: true },
    mapPosition: {
      type: { type: String, default: "Point", enum: ["Point"] },
      coordinates: [Number],
    },
    tasks: [taskSchema],
  },
  { timestamps: true },
);

questSchema.index({ mapPosition: "2dsphere" });
const Quest = mongoose.model("Quest", questSchema);
module.exports = Quest;
