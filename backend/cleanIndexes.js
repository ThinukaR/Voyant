// CLEANUP SCRIPT: Drop problematic indexes

require("dotenv").config();
const connectToDatabase = require("./db");
const UserAvatar = require("./models/Avatar");

async function cleanIndexes() {
  try {
    await connectToDatabase();
    console.log("[CLEANUP] Connected to database");

    // Get the collection
    const collection = UserAvatar.collection;

    // List current indexes before
    console.log("[CLEANUP] Current indexes before cleanup:");
    const indexesBefore = await collection.getIndexes();
    console.log(indexesBefore);

    // Drop all indexes except the default _id index
    console.log("[CLEANUP] Dropping indexes on UserAvatar collection...");
    try {
      await collection.dropIndexes();
      console.log("[CLEANUP] ✓ All indexes dropped");
    } catch (err) {
      console.log("[CLEANUP] No indexes to drop or error:", err.message);
    }

    // Sync indexes from schema
    console.log("[CLEANUP] Syncing indexes from schema...");
    await UserAvatar.syncIndexes();
    console.log("[CLEANUP] ✓ Indexes synced");

    // List new indexes
    const indexesAfter = await collection.getIndexes();
    console.log("[CLEANUP] Current indexes after cleanup:");
    console.log(indexesAfter);

    console.log("[CLEANUP] ✓ Cleanup complete!");
    process.exit(0);
  } catch (err) {
    console.error("[CLEANUP] Error:", err.message);
    console.error("[CLEANUP] Stack:", err.stack);
    process.exit(1);
  }
}

cleanIndexes();



