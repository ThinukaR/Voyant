const { MongoClient } = require('mongodb');
require('dotenv').config();

const client = new MongoClient(process.env.MONGO_URI);

async function connectToDatabase() {
  try {
    await client.connect();
    console.log("Connected successfully to Atlas");
    return client.db(); // This returns the DB instance
  } catch (err) {
    console.error("Database connection failed:", err);
    process.exit(1); // Stop the app if DB fails
  }
}

module.exports = connectToDatabase;