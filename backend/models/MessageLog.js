const mongoose = require("mongoose");

const messageLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: [true, "A message log must belong to a user"],
  },
  characterName: {
    type: String,
    required: [true, "Character name is required"],
    enum: ["Guildmaster", "Merchant", "Guard", "QuestGiver", "Blacksmith"],
  },
  characterAvatar: {
    type: String,
    required: [true, "Character avatar URL is required"],
  },
  message: {
    type: String,
    required: [true, "Message content is required"],
    maxlength: [500, "Message cannot exceed 500 characters"],
  },
  messageType: {
    type: String,
    enum: ["hint", "info", "warning", "quest_update", "reward"],
    default: "info",
  },
  location: {
    type: String,
    required: [true, "Location where message was triggered"],
  },
  isRead: {
    type: Boolean,
    default: false,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
  expiresAt: {
    type: Date,
    default: () => new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
  },
});

// indexing this increases performance 
messageLogSchema.index({ userId: 1, timestamp: -1 });
messageLogSchema.index({ userId: 1, isRead: 1 });
messageLogSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// cleanup expired messages
messageLogSchema.pre('save', function(next) {
  if (this.isModified('expiresAt') && this.expiresAt < new Date()) {
    return next(new Error('Expiration date cannot be in the past'));
  }
  next();
});

const MessageLog = mongoose.model("MessageLog", messageLogSchema);

module.exports = MessageLog;