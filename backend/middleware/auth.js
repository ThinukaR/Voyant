const admin = require("../firebase/firebaseAdmin");

const protect = async (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith("Bearer ")) {
      return res.status(401).json({ message: "No token provided" });
    }

    const token = header.split(" ")[1];

    // Check if Firebase is initialized
    if (!admin.apps.length) {
      console.warn("[AUTH] Firebase not initialized - cannot verify token");
      return res.status(503).json({ message: "Authentication service unavailable" });
    }

    const decoded = await admin.auth().verifyIdToken(token);
    req.userId = decoded.uid;
    next();
  } catch (err) {
    console.error("[AUTH] Token verification error:", err.message);
    return res.status(401).json({ message: "Invalid or expired token" });
  }
};

module.exports = protect;
