const mongoose = require('mongoose');

const userAvatarSchema = new mongoose.Schema({
  // Link to the specific User
  uid: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  // Unique ID for this specific avatar instance
  aid: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  characterData: {
    type: [String],
    default: [] // to be filled later
  },
  // Array of cosmetic item names or IDs
  cosmetics: {
    type: [String],
    default: [] // to be filled later
  },
});


const UserAvatar = mongoose.model('UserAvatar', userAvatarSchema);

module.exports = UserAvatar;