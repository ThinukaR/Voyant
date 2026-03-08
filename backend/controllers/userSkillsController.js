const UserSkill = require("../models/UserSkills.js");
const Skill = require("../models/Skill.js");
const User = require("../models/UserAccountDetails.js");

exports.getAllUserSkills = async (req, res) => {
  try {
    const userSkills = await UserSkill.find({
      userId: req.params.userId,
    }).populate("skillId", "name skillPoint classId");
    res.status(200).json({
      status: "success",
      results: userSkills.length,
      data: userSkills,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.getUserSkillData = async (req, res) => {
  try {
    // Reading the skill
    const skill = await UserSkill.findById(req.params.id);
    if (!skill) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: { skill },
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.updateUserSkill = async (req, res) => {
  try {
    // Updating destination
    const updatedSkill = await UserSkill.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true },
    );

    // Checking if destination exists
    if (!updatedSkill) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }
    res.status(200).json({
      status: "success",
      data: updatedSkill,
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.removeUserSkill = async (req, res) => {
  try {
    const skill = await UserSkill.findById(req.params.id);
    // Checking if document exists before deleting
    if (!skill) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }
    // Logging the data deleted
    console.log(skill);

    // Authentication check
    if (skill.userId.toString() !== req.user.id) {
      return res.status(403).json({
        status: "fail",
        message: "You do not have permission to delete this skill",
      });
    }

    // Deletion
    await skill.deleteOne();
    res.status(204).json({
      status: "success",
      data: null,
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

// Update skill level
exports.updateUserSkillLevel = async (req, res) => {
  try {
    const userSkillLevel = await UserSkill.findByIdAndUpdate(
      req.params.id,
      { level: req.body.level },
      { new: true, runValidators: true },
    );
    if (!userSkillLevel) {
      return res.status(404).json({
        status: "fail",
        message: "UserSkill not found",
      });
    }
    res.status(200).json({
      status: "success",
      data: userSkillLevel,
    });
  } catch (err) {
    res.status(400).json({ status: "fail", message: err.message });
  }
};

exports.unlockSkill = async (req, res) => {
  try {
    const { userId, skillId } = req.body;

    // Finding skill and checking if it exists
    const skill = await Skill.findById(skillId);
    if (!skill) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }
    if (skill.status == "locked") {
      return res.status(400).json({
        status: "fail",
        message: "This skill is not yet unlocked",
      });
    }

    // Checking if user has enough skill points
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        status: "fail",
        message: "User not found",
      });
    }

    if (user.skillPoints < skill.skillPoints) {
      return res.status(400).json({
        status: "fail",
        message: "Not enough skill points",
      });
    }

    // Subtracting skills points from user if successful
    user.skillPoints -= skill.skillPoint;
    await user.save();

    // Making the userSkill record
    const userSkill = await UserSkill.create({
      userId,
      skillId,
      name: skill.name,
    });
    res.status(201).json({
      status: "success",
      data: {
        userSkill,
        remainingSkillPoints: user.skillPoints,
      },
    });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(400).json({
        status: "fail",
        message: "Skill already unlocked",
      });
    }
    res.status(400).json({ status: "fail", message: err.message });
  }
};
