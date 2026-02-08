const mongoose = require('mongoose');

const userAvatarSchema = new mongoose.Schema({
  // Link to the specific User
  uid: {
    type: String,
    required: true,
    index: true // Multiple avatars might belong to one UID
  },
  // Unique ID for this specific avatar instance
  aid: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  // Array of cosmetic item names or IDs
  cosmetics: {
    type: [String],
    default: []
  },
});


const UserAvatar = mongoose.model('UserAvatar', userAvatarSchema);

module.exports = UserAvatar;