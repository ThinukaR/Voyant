const AvatarData = require("../models/Avatar.js");

exports.createAvatar = async (req, res) => {
  try {
    const newAvatar = await AvatarData.create(req.body);
    res.status(201).json({
      status: "success",
      data: {avatar: newAvatar},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.getAvatar = async (req, res) => {
  try {
    const avatar = await AvatarData.findById(req.params.id);
    // Avatar not found
    if (!avatar) {
      return res.status(404).json({
        status: "fail",
        message: "Avatar not found",
      });
    }
    // Avatar found
    res.status(200).json({
      status: "success",
      data: {avatar: avatar},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.getAllAvatars = async (req, res) => {
  try {
    const avatars = await AvatarData.find({uid: req.params.uid});
    res.status(200).json({
      status: "success",
      data: {avatars},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.updateAvatar = async (req, res) => {
  try {
    const updatedAvatar = await AvatarData.findByIdAndUpdate(
        req.params.id,
        req.body,
        {new: true, runValidators: true},
    );

    // Checking if destination exists
    if (!updatedAvatar) {
      return res.status(404).json({
        status: "fail",
        message: "Avatar not found",
      });
    }

    // Avatar found and updated
    res.status(200).json({
      status: "success",
      data: {avatar: updatedAvatar},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.updateCosmetics = async (req, res) => {
  try {
    const updatedAvatar = await AvatarData.findByIdAndUpdate(
        req.params.id,
        {$set: {cosmetics: req.body.cosmetics}},
        {new: true, runValidators: true},
    );

    if (!updatedAvatar) {
      return res.status(404).json({
        status: "fail",
        message: "Avatar not found",
      });
    }

    res.status(200).json({
      status: "success",
      data: {avatar: updatedAvatar},
    });
  } catch (err) {
    res.status(400).json({
      status: "fail",
      message: err.message,
    });
  }
};

exports.deleteAvatar = async (req, res) => {
  try {
    const avatar = await AvatarData.findByIdAndDelete(req.params.id);
    if (!avatar) {
      return res.status(404).json({
        status: "fail",
        message: "Not found",
      });
    }
    return res.status(204).send();
  } catch (err) {
    return res.status(400).json({message: err.message});
  }
};
