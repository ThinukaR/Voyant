const mongoose = require("mongoose");

const skillClassSchema = new mongoose.Schema({
  classId: {
    type: Number,
    required: true,
    unique: true,
  },
  name: {
    type: String,
    trim: true,
  },
  skillsArray: {
    type: [mongoose.Schema.Types.ObjectId],
    ref: "Skill",
  },
});

const Skill_Class = mongoose.model("SkillClass", skillClassSchema);

module.exports = Skill_Class;
