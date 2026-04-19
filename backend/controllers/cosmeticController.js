const UserAvatar = require("../models/Avatar");
const CosmeticItem = require("../models/CosmeticItem");

exports.getAvatar = async (req, res) => {
  try {
    let avatar = await UserAvatar.findOne({ userId: req.userId })
      .populate("equipped.hat")
      .populate("equipped.hair")
      .populate("equipped.shirt")
      .populate("equipped.pants")
      .populate("equipped.shoes")
      .populate("ownedItems");

    if (!avatar) {
      const defaultItems = await CosmeticItem.find({ xpCost: 0 });
      try {
        avatar = await UserAvatar.create({
          userId: req.userId,
          ownedItems: defaultItems.map((i) => i._id),
        });
      } catch (createErr) {
        // If duplicate key error (E11000), user already exists, fetch it again
        if (createErr.code === 11000) {
          avatar = await UserAvatar.findOne({ userId: req.userId })
            .populate("equipped.hat")
            .populate("equipped.hair")
            .populate("equipped.shirt")
            .populate("equipped.pants")
            .populate("equipped.shoes")
            .populate("ownedItems");
        } else {
          throw createErr;
        }
      }

      // If still no avatar, return error
      if (!avatar) {
        return res.status(404).json({ message: "Could not create or retrieve avatar" });
      }
    }

    return res.json(avatar);
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.equipItem = async (req, res) => {
  try {
    const item = await CosmeticItem.findById(req.params.itemId);
    if (!item) return res.status(404).json({ message: "Item not found" });

    const avatar = await UserAvatar.findOne({ userId: req.userId });
    if (!avatar) return res.status(404).json({ message: "Avatar not found" });

    const ownsItem = avatar.ownedItems.some(
      (id) => id.toString() === item._id.toString(),
    );
    if (!ownsItem)
      return res.status(403).json({ message: "You don't own this item" });

    avatar.equipped[item.category] = item._id;
    await avatar.save();

    return res.json({ message: "Equipped", category: item.category });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.getAllItems = async (req, res) => {
  try {
    const items = await CosmeticItem.find();
    return res.json(items);
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.unlockItem = async (req, res) => {
  try {
    const item = await CosmeticItem.findById(req.params.itemId);
    if (!item) return res.status(404).json({ message: "Item not found" });

    const avatar = await UserAvatar.findOne({ userId: req.userId });
    if (!avatar) return res.status(404).json({ message: "Avatar not found" });

    // check not already owned
    const alreadyOwned = avatar.ownedItems.some(
      (id) => id.toString() === item._id.toString(),
    );
    if (alreadyOwned) return res.status(400).json({ message: "Already owned" });

    // add to owned items
    avatar.ownedItems.push(item._id);
    await avatar.save();

    return res.json({ message: "Unlocked", item });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};
