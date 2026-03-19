const mongoose = require("mongoose");

const userAvatarSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, unique: true }, // Firebase UID
    skinColor: { type: String, default: "#F5CBA7" },

    // currently equipped item IDs per category
    equipped: {
      hat: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "CosmeticItem",
        default: null,
      },
      hair: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "CosmeticItem",
        default: null,
      },
      shirt: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "CosmeticItem",
        default: null,
      },
      pants: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "CosmeticItem",
        default: null,
      },
      shoes: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "CosmeticItem",
        default: null,
      },
    },

    // all items the user owns
    ownedItems: [{ type: mongoose.Schema.Types.ObjectId, ref: "CosmeticItem" }],
  },
  { timestamps: true },
);

module.exports = mongoose.model("UserAvatar", userAvatarSchema);
