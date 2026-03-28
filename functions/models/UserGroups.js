const mongoose = require("mongoose");

const groupSchema = new mongoose.Schema({
  gid: {
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  group_name: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  // We'll store the count here for fast querying
  no_of_members: {
    type: Number,
    default: 0,
  },
  // An array of strings containing the userId's
  member_userId: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
  ],
  xp: {
    type: Number,
    default: 0.0,
  },
  level: {
    type: Number,
    default: 0,
    min: 0,
  },
  created_date: {
    type: Date,
    default: Date.now,
    immutable: true,
  },
});

// Middleware: Automatically update the member count before saving
groupSchema.pre("save", function(next) {
  if (this.isModified("member_userId")) {
    this.no_of_members = this.member_userId.length;
  }
  next();
});

const Group = mongoose.model("Group", groupSchema);

module.exports = Group;
