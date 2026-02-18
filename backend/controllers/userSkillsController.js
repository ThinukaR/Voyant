const SkillData = require("../models/UserSkills.js");

exports.createSkill = async (req, res) => {
  try {
    // Creating skill
    const newSkill = await SkillData.create(req.body);
    res.status(201).json({
      status: "success",
      data: { skill: newSkill },
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.getUserSkillData = async (req, res) => {
  try {
    // Reading the skill
    const skill = await SkillData.findById(req.params.id);
    if (!skill) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: { destination },
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.updateUserSkillData = async (req, res) => {
  try {
    // Updating destination
    const updatedSkills = await SkillData.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true },
    );

    // Checking if destination exists
    if (!updatedSkills) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.deleteUserSkillData = async (req, res) => {
  try {
    const skillToDelete = await SkillData.findById(req.params.id);
    // Checking if document exists before deleting
    if (!skillToDelete) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }
    // Logging the data deleted
    console.log(skillToDelete);

    // Authentication check
    if (skillToDelete.createdBy.toString() !== req.user.id) {
      return res.status(403).json({
        status: "fail",
        message: "You do not have permission to delete this skill",
      });
    }

    // Deletion
    await skillToDelete.deleteOne();
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

exports.getAllUserSkillData = async (req, res) => {
  const skills = await SkillData.find({ active: { $ne: false } });
};
