const mongoose = require("mongoose");

async function connectToDatabase() {
  try {
    console.log("MONGO_URI:", process.env.MONGO_URI);
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB connected");
  } catch (err) {
    console.error("Database connection failed:", err);
    process.exit(1);
  }
}

module.exports = connectToDatabase;