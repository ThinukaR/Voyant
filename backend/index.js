// Add global error handlers FIRST before anything else
process.on("uncaughtException", (error) => {
  console.error("[FATAL] Uncaught Exception:", error);
  process.exit(1);
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("[FATAL] Unhandled Rejection at:", promise, "reason:", reason);
  process.exit(1);
});

const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, ".env") });

console.log("[STARTUP] Starting Voyant Backend Server...");
console.log("[STARTUP] Looking for .env at:", path.resolve(__dirname, ".env"));
console.log("[STARTUP] Environment variables loaded:");
console.log("[STARTUP]   MONGO_URI:", process.env.MONGO_URI ? "SET" : "NOT SET");
console.log("[STARTUP]   PORT:", process.env.PORT ? "SET" : "NOT SET");
console.log("[STARTUP]   FIREBASE_CONFIG:", process.env.FIREBASE_CONFIG ? "SET" : "NOT SET");

// Set defaults if not provided (for Render and production)
const MONGO_URI = process.env.MONGO_URI;
const PORT = process.env.PORT || 3000;

if (!MONGO_URI) {
  console.error("[ERROR] MONGO_URI environment variable is not set");
  console.error("[ERROR] Please set MONGO_URI in Render dashboard environment variables");
  process.exit(1);
}

// Initialize Firebase early and catch any errors
console.log("[STARTUP] Initializing Firebase Admin...");
try {
  require("./firebase/firebaseAdmin");
  console.log("[STARTUP] ✓ Firebase Admin initialized successfully");
} catch (firebaseError) {
  console.error("[ERROR] Failed to initialize Firebase:", firebaseError.message);
  console.error("[ERROR] Stack trace:", firebaseError.stack);
  process.exit(1);
}

const express = require("express");
console.log("[STARTUP] ✓ Express loaded");

const connectToDatabase = require("./db");
console.log("[STARTUP] ✓ Database module loaded");

// Load all routes with error handling
console.log("[STARTUP] Loading routes...");
let avatarRoutes, destinationRoutes, questRoutes, skillRoutes,
    userAccountDetailsRoutes, userGroupRoutes, userSkillRoutes,
    userTripRoutes, userRewardRoutes, messageLogRoutes;

try {
  avatarRoutes = require("./routes/avatarRoutes");
  destinationRoutes = require("./routes/destinationRoutes");
  questRoutes = require("./routes/questRoutes");
  skillRoutes = require("./routes/skillRoutes");
  userAccountDetailsRoutes = require("./routes/userAccountDetailsRoutes");
  userGroupRoutes = require("./routes/userGroupRoutes");
  userSkillRoutes = require("./routes/userSkillsRoutes");
  userTripRoutes = require("./routes/userTripRoutes");
  userRewardRoutes = require("./routes/userRewardRoutes");
  messageLogRoutes = require("./routes/messageLogRoutes");
  console.log("[STARTUP] ✓ All routes loaded successfully");
} catch (err) {
  console.error("[ERROR] Failed to load routes:", err.message);
  console.error("[ERROR] Stack trace:", err.stack);
  process.exit(1);
}

const app = express();

// Routes
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Server is running' });
});

app.use("/api/user-account-details", userAccountDetailsRoutes);
app.use("/api/avatars", avatarRoutes);
app.use("/api/destinations", destinationRoutes);
app.use("/api/quests", questRoutes);
app.use("/api/skills", skillRoutes);
app.use("/api/user-groups", userGroupRoutes);
app.use("/api/user-skills", userSkillRoutes);
app.use("/api/user-trips", userTripRoutes);
app.use("/api/rewards", userRewardRoutes);
app.use("/api/messages", messageLogRoutes);

async function startApp() {
  try {
    console.log("[STARTUP] Connecting to database...");
    await connectToDatabase();
    console.log("[STARTUP] ✓ Database connection successful");

    console.log("[STARTUP] Starting Express server on port", PORT);
    const server = app.listen(PORT, () => {
      console.log("[STARTUP] ✓ Server running on port", PORT);
      console.log("[STARTUP] ✓ All systems operational");
      console.log("[STARTUP] Health check endpoint: http://localhost:" + PORT + "/health");
    });

    // Handle server errors
    server.on("error", (err) => {
      console.error("[SERVER ERROR]", err);
      process.exit(1);
    });
  } catch (error) {
    console.error("[FATAL] Failed to start app:", error.message);
    console.error("[FATAL] Stack trace:", error.stack);
    process.exit(1);
  }
}

console.log("[STARTUP] Calling startApp()...");
startApp().catch((err) => {
  console.error("[FATAL] startApp threw error:", err);
  process.exit(1);
});
