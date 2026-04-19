const path = require("path");

// Only load .env for local development
if (process.env.NODE_ENV !== 'production') {
  require("dotenv").config({ path: path.resolve(__dirname, "../.env") });
}

console.log('Environment variables check:');
console.log('MONGO_URI:', process.env.MONGO_URI ? 'SET' : 'NOT SET');

if (!process.env.MONGO_URI) {
  throw new Error("MONGO_URI missing. Set it in Vercel environment variables");
}

// Imports
try {
  require("../firebase/firebaseAdmin");
} catch (error) {
  console.warn('Firebase admin import error:', error.message);
}

const express = require("express");
const connectToDatabase = require("../db");
const avatarRoutes = require("../routes/avatarRoutes");
const destinationRoutes = require("../routes/destinationRoutes");
const questRoutes = require("../routes/questRoutes");
const skillRoutes = require("../routes/skillRoutes");
const userAccountDetailsRoutes = require("../routes/userAccountDetailsRoutes");
const userGroupRoutes = require("../routes/userGroupRoutes");
const userSkillRoutes = require("../routes/userSkillsRoutes");
const userTripRoutes = require("../routes/userTripRoutes");
const userRewardRoutes = require("../routes/userRewardRoutes");
const messageLogRoutes = require("../routes/messageLogRoutes");

const app = express();

// CORS middleware
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }

  next();
});

// Parse JSON requests FIRST
app.use(express.json());

// Request logging middleware for debugging
app.use('/api', (req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  console.log('Headers:', {
    authorization: req.headers.authorization ? 'Present' : 'Missing',
    contentType: req.headers['content-type']
  });
  next();
});

// Health check endpoint (doesn't require database)
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// Database connection state
let dbConnected = false;
let dbConnection = null;

// Middleware to ensure database is connected (only when needed)
app.use('/api', async (req, res, next) => {
  // Skip database connection for health check
  if (req.path === '/health') {
    return next();
  }

  if (!dbConnected) {
    try {
      console.log('[DB] Connecting to database...');
      dbConnection = await connectToDatabase();
      dbConnected = true;
      console.log('[DB] Database connected successfully');
    } catch (error) {
      console.error('[DB] Database connection error:', error.message);
      return res.status(500).json({ error: 'Database connection failed', details: error.message });
    }
  }
  next();
});

// Routes
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

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found', path: req.path });
});

// Export for Vercel serverless functions
module.exports = app;

