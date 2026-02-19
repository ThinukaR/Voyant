const Skill = require("../models/Skill.js");
const SkillClass = require("../models/SkillClass.js");

exports.getAllSkills = async (req, res) => {
  try {
    const skillData = await Skill.find().populate("classId", "name");
    res.status(200).json({
      status: "success",
      results: skillData.length,
      data: skillData,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.getSkill = async (req, res) => {
  try {
    const skill = await Skill.findById(req.params.id).populate(
      "classId",
      "name",
    );
    if (!skill) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }
    res.status(200).json({
      status: "success",
      data: skill,
    });
  } catch (err) {
    res.status(500).json({
      status: "fail",
      message: err.message,
    });
  }
};

// Need to restrict access only to admins here -❗❗❗
exports.createSkill = async (req, res) => {
  try {
    const skill = await Skill.create(req.body);
    res.status(201).json({ status: "success", data: skill });
  } catch (err) {
    res.status(400).json({ status: "fail", message: err.message });
  }
};

exports.updateSkill = async (req, res) => {
  try {
    const skill = await Skill.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!skill) {
      return res.status(404).json({
        status: "fail",
        message: "Skill not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: skill,
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};
