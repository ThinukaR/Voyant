const mongoose = require("mongoose");

const taskSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  order: { type: Number, required: true },
  isLocked: { type: Boolean, default: true },
  isCompleted: { type: Boolean, default: false },
  xpReward: { type: Number, default: 50 },
  type: {
    type: String,
    enum: [
      "geofence",
      "number_input",
      "string_input",
      "photo",
      "spot_diff",
      "find_object",
      "checkin",
      "multiple_choice",
      "true_false",
    ],
    required: true,
  },
  geofenceData: {
    coordinates: [Number],
    radiusMeters: Number,
  },
  numberInputData: {
    question: String,
    correctAnswer: Number,
  },
  stringInputData: {
    instruction: String,
    correctAnswer: String,
  },
  photoData: {
    instruction: String,
    aiPrompt: String,
  },
  spotDiffData: {
    imageAUrl: String,
    imageBUrl: String,
    instruction: String,
  },
  findObjectData: {
    hint: String,
    objectName: String,
    imageUrl: String,
  },
  multipleChoiceData: {
    question: String,
    options: [String],
    correctAnswer: String,
  },
  trueFalseData: {
    statement: String,
    correctAnswer: Boolean,
  },
});

// exporting the schema without a model, tasks will be embedded inside a quest document. Not a seperation collection in mongodb
module.exports = taskSchema;
