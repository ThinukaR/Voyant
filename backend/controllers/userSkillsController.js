const UserSkill = require("../models/UserSkills.js");
const Skill = require("../models/Skill.js");
const User = require("../models/UserAccountDetails.js");
const admin = require("../firebase/firebaseAdmin");
const SkillClass = require("../models/SkillClass.js");

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
    const { skillId } = req.body;
    const userId = req.userId; // from auth middleware

    const skill = await Skill.findById(skillId);
    if (!skill) return res.status(404).json({ message: "Skill not found" });

    // check already unlocked
    const existing = await UserSkill.findOne({ userId, skillId: skill._id });
    if (existing) return res.status(400).json({ message: "Already unlocked" });

    // check + deduct SP in Firestore
    const db = admin.firestore();
    const userRef = db.collection("users").doc(userId);

    const result = await db.runTransaction(async (t) => {
      const doc = await t.get(userRef);
      const currentSP = doc.exists ? doc.data().skillPoints || 0 : 0;
      if (currentSP < skill.skillPoint) {
        return { success: false, message: `Not enough SP. Need ${skill.skillPoint}, have ${currentSP}` };
      }
      t.set(userRef, { skillPoints: currentSP - skill.skillPoint }, { merge: true });
      return { success: true, remainingSP: currentSP - skill.skillPoint };
    });

    if (!result.success) return res.status(400).json({ message: result.message });

    const userSkill = await UserSkill.create({
      userId,
      skillId: skill._id,
      name: skill.name,
    });

    return res.json({
      message: "Skill unlocked",
      skill: skill.name,
      remainingSP: result.remainingSP,
    });
  } catch (err) {
    if (err.code === 11000) return res.status(400).json({ message: "Already unlocked" });
    return res.status(400).json({ message: err.message });
  }
};

exports.selectClass = async (req, res) => {
  try {
    const skillClass = await SkillClass.findById(req.params.classId);
    if (!skillClass) return res.status(404).json({ message: "Class not found" });

    const db = admin.firestore();
    await db.collection("users").doc(req.userId).set(
      { selectedClass: skillClass.name },
      { merge: true }
    );

    return res.json({ message: "Class selected", className: skillClass.name });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.getUserSkills = async (req, res) => {
  try {
    const userSkills = await UserSkill.find({ userId: req.userId }).populate("skillId");
    return res.json(userSkills);
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};