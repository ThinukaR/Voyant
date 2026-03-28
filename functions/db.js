const mongoose = require("mongoose");
let isConnected = false;

const connectToDatabase = async () => {
  if (isConnected) return;

  const uri = process.env.MONGO_URI;

  if (!uri) throw new Error("MONGO_URI is not set");

  await mongoose.connect(uri);
  isConnected = true;
  console.log("MongoDB connected");
};

module.exports = connectToDatabase;
