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

console.log('Environment variables loaded:');
console.log('MONGO_URI:', process.env.MONGO_URI ? 'SET' : 'NOT SET');

if (!process.env.MONGO_URI) {
  throw new Error("MONGO_URI missing. Set it in environment variables");
}

// Set defaults if not provided
const MONGO_URI = process.env.MONGO_URI;
const PORT = process.env.PORT || 3000;

// Imports
require("./firebase/firebaseAdmin");

const express = require("express");
console.log("[STARTUP] ✓ Express loaded");

const connectToDatabase = require("./db");
console.log("[STARTUP] ✓ Database module loaded");

// Load all routes with error handling
console.log("[STARTUP] Loading routes...");
let avatarRoutes, cosmeticsRoutes, destinationRoutes, questRoutes, skillRoutes,
    userAccountDetailsRoutes, userGroupRoutes, userSkillRoutes,
    userTripRoutes, userRewardRoutes, messageLogRoutes;

try {
  avatarRoutes = require("./routes/avatarRoutes");
  cosmeticsRoutes = require("./routes/cosmeticsRoutes");
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

// Parse JSON requests FIRST
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// Database connection state
let dbConnected = false;

// Middleware to ensure database is connected (applied to API routes only)
app.use('/api', async (req, res, next) => {
  if (!dbConnected) {
    try {
      console.log('Connecting to database...');
      await connectToDatabase();
      dbConnected = true;
      console.log('Database connected successfully');
    } catch (error) {
      console.error('Database connection error:', error);
      return res.status(500).json({ error: 'Database connection failed', details: error.message });
    }
  }
  next();
});

// Routes
app.use("/api/user-account-details", userAccountDetailsRoutes);
app.use("/api/avatars", avatarRoutes);
app.use("/api/cosmetics", cosmeticsRoutes);
app.use("/api/destinations", destinationRoutes);
app.use("/api/quests", questRoutes);
app.use("/api/skills", skillRoutes);
app.use("/api/user-groups", userGroupRoutes);
app.use("/api/user-skills", userSkillRoutes);
app.use("/api/user-trips", userTripRoutes);
app.use("/api/rewards", userRewardRoutes);
app.use("/api/messages", messageLogRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found', path: req.path });
});

async function startApp() {
  try {
    console.log("[STARTUP] Connecting to database...");
    await connectToDatabase();
    console.log("[STARTUP] ✓ Database connection successful");

    console.log("[STARTUP] Starting Express server on port", PORT);
    const server = app.listen(PORT, () => {
      console.log(`[STARTUP] ✓ Server running on port ${PORT}`);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      console.log('[SHUTDOWN] SIGTERM received, shutting down gracefully...');
      server.close(() => {
        console.log('[SHUTDOWN] Server closed');
        process.exit(0);
      });
    });

  } catch (err) {
    console.error("[ERROR] Failed to start server:", err.message);
    console.error("[ERROR] Stack trace:", err.stack);
    process.exit(1);
  }
}

startApp();

// Export for Vercel serverless functions
module.exports = app;
