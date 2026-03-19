const mongoose = require("mongoose");

const skillSchema = new mongoose.Schema({
  skillId: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    // e.g. "e1a", "w2b", "m3a" — matches Flutter node IDs
  },
  branch: {
    type: String,
    required: true,
    enum: ["trailblazer", "wanderer", "prime", "seeker"],
  },
  tier: {
    type: Number,
    required: true,
    enum: [1, 2, 3],
  },
  label: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
    trim: true,
  },
  icon: {
    type: String,
    required: true,
    trim: true,
    // Store the icon name as a string e.g. "visibility_rounded"
  },
  state: {
    type: String,
    enum: ["available", "locked", "unlocked"],
    default: "locked",
  },
  skillPoint: {
    type: Number,
    required: true,
    default: 0,
    // Cost in skill points to unlock this skill
  },
});

const Skill = mongoose.model("Skill", skillSchema);

module.exports = Skill;