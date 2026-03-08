const mongoose = require('mongoose');

const loginDetailsSchema = new mongoose.Schema({
  // The unique ID that connects this login info to the User's profile
  uid: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  // this will store the hashed password, not plain text
  password: {
    type: String,
    required: true
  },
  created_date: {
    type: Date,
    default: Date.now,
    immutable: true
  }
});

const LoginDetails = mongoose.model('LoginDetails', loginDetailsSchema);

module.exports = LoginDetails;