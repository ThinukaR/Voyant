const mongoose = require("mongoose");

const userSkillSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: "User",
  },
  skillId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: "Skill",
  },
  name: {
    type: String,
    trim: true,
  },
  unlockedAt: {
    type: Date,
    default: Date.now,
  },
  level: {
    type: String,
    enum: ["beginner", "intermediate", "advanced"], // Define valid levels
    default: "beginner",
  },
});

// Avoiding duplicates
userSkillSchema.index({ userId: 1, skillId: 1 }, { unique: true });

const UserSkill = mongoose.model("UserSkill", userSkillSchema);

module.exports = UserSkill;
