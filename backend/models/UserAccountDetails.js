const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
    unique: true, // Prevents duplicates
    index: true   // Makes lookups super fast
  },
    name: {
    type: String,
    required: true,
    trim: true
  },
  username: {
    type: String,
    required: true,
    lowercase: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  level: {
    type: Number,
    default: 0,
    min: 0
  },
  xp: {
    // In JS, Number handles both integers and floats. 
    // If you need extreme precision, consider Decimal128.
    type: Number, 
    default: 0.0
  },
  skillPoints: {
    type: Number,
    default: 0
  },
  pfp: {
    type: String
  },
   // New profile fields
    displayName: {
      type: String,
      trim: true
    },
    bio: {
      type: String,
      trim: true
    },
    location: {
      type: String,
      trim: true
    },
    profileImageUrl: {
      type: String
    },
    // Preferences
    locationSharingEnabled: {
      type: Boolean,
      default: false
    },
    // Security settings
    twoFactorEnabled: {
      type: Boolean,
      default: false
    },
    biometricLoginEnabled: {
      type: Boolean,
      default: false
    },
    // Social accounts
    connectedAccounts: {
      google: {
        linkedAt: Date,
        email: String
      },
      facebook: {
        linkedAt: Date,
        email: String
      },
      type: Object,
      default: {}
    },
    // Activity tracking
    lastLoginAt: {
      type: Date
    },
    dataDownloadedAt: {
      type: Date
    },
    loginSessions: [{
      device: String,
      ip: String,
      lastActivity: Date,
      createdAt: {
        type: Date,
        default: Date.now
      }
    }],
  last_login: {
    type: Date,
    default: Date.now
  },
  created_date: {
    type: Date,
    default: Date.now,
    immutable: true // Prevents the creation date from being changed later
  }
});

// Create the model
const User = mongoose.model('User', userSchema);

module.exports = User;