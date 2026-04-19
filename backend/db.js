const mongoose = require("mongoose");

async function connectToDatabase() {
  try {
    console.log("[DB] Attempting to connect to MongoDB...");
    console.log("[DB] Connection URI:", process.env.MONGO_URI ? "SET" : "NOT SET");

    if (!process.env.MONGO_URI) {
      throw new Error("MONGO_URI is not set");
    }

    const connection = await mongoose.connect(process.env.MONGO_URI, {
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });

    console.log("[DB] ✓ MongoDB connected successfully");
    console.log("[DB] Database:", connection.connection.db.databaseName);
    return connection;
  } catch (err) {
    console.error("[DB] Connection failed:", err.message);
    console.error("[DB] Error code:", err.code);
    console.error("[DB] Stack trace:", err.stack);
    throw err; // Re-throw to let the caller handle it
  }
}

module.exports = connectToDatabase;