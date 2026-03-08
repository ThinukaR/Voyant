const mongoose = require("mongoose");

const skillSchema = new mongoose.Schema({
  skillId: {
    type: Number,
    required: true,
    unique: true,
  },
  classId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "SkillClass",
    required: [true, "Every skill must belong to a class"],
  },
  name: {
    type: String,
    trim: true,
  },
  status: {
    type: String,
    enum: ["Locked", "Unlocked"],
    default: "Locked",
  },
  skillPoint: {
    type: Number,
    required: [
      true,
      "Each skill need to have his its own number of skill points to unlock",
    ],
  },
});

const Skill = mongoose.model("Skill", skillSchema);

module.exports = Skill;
