const mongoose = require("mongoose");

const questSchema = new mongoose.schema({
  qid: {
    type: Number,
    required: true,
    unique: true,
  },
  name: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
    trim: true,
  },
  instructions: {
    type: String,
    required: true,
  },
  xpCount: {
    type: Number,
    required: true,
  },
  // Foreign key
  location: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Location",
    required: [true, "A quest must belong to a specific location"],
  },
  questType: {
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
    required: [true, 'A quest must provide achievements or xp']
} 
});

const Quest = mongoose.model("Quest", questSchema);

module.exports = Quest;
