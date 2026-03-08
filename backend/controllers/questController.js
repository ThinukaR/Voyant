// controllers/questController.js
const Quest = require("../models/Quest");

exports.createQuest = async (req, res) => {
  try {
    const doc = await Quest.create(req.body);
    return res.status(201).json(doc);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.getQuest = async (req, res) => {
  try {
    const doc = await Quest.findById(req.params.id);
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.json(doc);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.getQuestList = async (_req, res) => {
  try {
    const docs = await Quest.find();
    return res.json(docs);
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.updateQuest = async (req, res) => {
  try {
    const doc = await Quest.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.json(doc);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.deleteQuest = async (req, res) => {
  try {
    const doc = await Quest.findByIdAndDelete(req.params.id);
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.status(204).send();
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};
