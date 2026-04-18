const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, ".env") });

console.log('Looking for .env at:', path.resolve(__dirname, ".env"));
console.log('Environment variables loaded:');
console.log('MONGO_URI:', process.env.MONGO_URI ? 'SET' : 'NOT SET');
console.log('PORT:', process.env.PORT ? 'SET' : 'NOT SET');

if (!process.env.MONGO_URI) {
  throw new Error("MONGO_URI missing. Set it in backend/.env file");
}

if (!process.env.PORT) {
  throw new Error("PORT missing. Set it in backend/.env file or use default 3000");
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
const PORT = process.env.PORT || 3000;

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
  await connectToDatabase();

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

startApp();
