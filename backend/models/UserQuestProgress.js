// seperate collection to track each user's quest progress
const mongoose = require("mongoose");

const taskProgressSchema = new mongoose.Schema({
  taskId: { type: mongoose.Schema.Types.ObjectId, required: true },
  isCompleted: { type: Boolean, default: false },
  completedAt: { type: Date },
  xpAwarded: { type: Number, default: 0 },
});

const userQuestProgressSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true }, // Firebase UID
    questId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Quest",
      required: true,
    },
    tripId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Trip",
      required: true,
    },
    status: {
      type: String,
      enum: ["locked", "active", "completed"],
      default: "active",
    },
    taskProgress: [taskProgressSchema],
    totalXPEarned: { type: Number, default: 0 },
    startedAt: { type: Date, default: Date.now },
    completedAt: { type: Date },
  },
  { timestamps: true },
);

module.exports = mongoose.model("UserQuestProgress", userQuestProgressSchema);
