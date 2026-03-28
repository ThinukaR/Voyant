const mongoose = require("mongoose");

const cosmeticItemSchema = new mongoose.Schema({
  name: {type: String, required: true},
  category: {
    type: String,
    enum: ["hat", "hair", "shirt", "pants", "shoes"],
    required: true,
  },
  color: {type: String, required: true}, // hex color e.g. "#FF5733"
  rarity: {
    type: String,
    enum: ["common", "rare", "epic"],
    default: "common",
  },
  xpCost: {type: Number, default: 0}, // 0 = free/default item
});

module.exports = mongoose.model("CosmeticItem", cosmeticItemSchema);
