const Skill = require("../models/Skill.js");
const SkillClass = require("../models/SkillClass.js");

exports.getAllSkills = async (req, res) => {
  try {
    const skillData = await Skill.find();
    res.status(200).json(skillData); // plain array for Flutter
  } catch (err) {
    res.status(500).json({ status: "fail", message: err.message });
  }
};

exports.getSkill = async (req, res) => {
  try {
    const skill = await Skill.findById(req.params.id);
    if (!skill) {
      return res
        .status(404)
        .json({ status: "fail", message: "Skill not found" });
    }
    res.status(200).json({ status: "success", data: skill });
  } catch (err) {
    res.status(500).json({ status: "fail", message: err.message });
  }
};

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
      return res
        .status(404)
        .json({ status: "fail", message: "Skill not found" });
    }
    res.status(200).json({ status: "success", data: skill });
  } catch (err) {
    res.status(400).json({ status: "fail", message: err.message });
  }
};

exports.deleteSkill = async (req, res) => {
  try {
    const doc = await Skill.findByIdAndDelete(req.params.id);
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.status(204).send();
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.getAllClasses = async (req, res) => {
  try {
    const classes = await SkillClass.find();
    return res.json(classes);
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.getSkillsForClass = async (req, res) => {
  try {
    const skills = await Skill.find({ branch: req.params.branch }); // use branch not classId
    return res.json(skills);
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};
