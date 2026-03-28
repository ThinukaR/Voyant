const UserGroupData = require("../models/UserGroups.js");

// Create group
exports.createGroup = async (req, res) => {
  try {
    const newUserGroup = await UserGroupData.create(req.body);
    res.status(201).json({
      status: "success",
      data: {group: newUserGroup},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

// Get all groups
exports.getAllGroups = async (req, res) => {
  try {
    const groups = await UserGroupData.find({active: {$ne: false}});

    res.status(200).json({
      status: "success",
      results: groups.length,
      data: {groups: groups},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

// Get single group by ID
exports.getGroupById = async (req, res) => {
  try {
    const userGroup = await UserGroupData.findById(req.params.id);
    if (!userGroup) {
      return res.status(404).json({
        status: "fail",
        message: "User group not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: {userGroup},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

// Get user's groups - all the groups the user is in
exports.getUserGroups = async (req, res) => {
  try {
    const userId = req.params.userId;
    const userGroups = await UserGroupData.find({
      member_usernames: userId,
    });

    res.status(200).json({
      status: "success",
      results: userGroups.length,
      data: {groups: userGroups},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};
