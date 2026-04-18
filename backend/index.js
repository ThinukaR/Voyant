const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, ".env") });

console.log('Looking for .env at:', path.resolve(__dirname, ".env"));
console.log('Environment variables loaded:');
console.log('MONGO_URI:', process.env.MONGO_URI ? 'SET' : 'NOT SET');
console.log('PORT:', process.env.PORT ? 'SET' : 'NOT SET');

// Set defaults if not provided (for Render and production)
const MONGO_URI = process.env.MONGO_URI;
const PORT = process.env.PORT || 3000;

if (!MONGO_URI) {
  console.error("ERROR: MONGO_URI environment variable is not set");
  console.error("Please set MONGO_URI in Render dashboard environment variables");
  process.exit(1);
}
// Imports
require("./firebase/firebaseAdmin");

const express = require("express");
const connectToDatabase = require("./db");
const avatarRoutes = require("./routes/avatarRoutes");
const destinationRoutes = require("./routes/destinationRoutes");
const questRoutes = require("./routes/questRoutes"); 
const skillRoutes = require("./routes/skillRoutes");
const userAccountDetailsRoutes = require("./routes/userAccountDetailsRoutes");
const userGroupRoutes = require("./routes/userGroupRoutes");
const userSkillRoutes = require("./routes/userSkillsRoutes");
const userTripRoutes = require("./routes/userTripRoutes");
const userRewardRoutes = require("./routes/userRewardRoutes");
const messageLogRoutes = require("./routes/messageLogRoutes");

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
    await connectToDatabase();

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Failed to start app:", error);
    process.exit(1);
  }
}

startApp();
