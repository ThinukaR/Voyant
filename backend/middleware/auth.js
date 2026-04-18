const admin = require("../firebase/firebaseAdmin");

const protect = async (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith("Bearer ")) {
      console.log("[AUTH] No authorization header provided");
      return res.status(401).json({ message: "No token provided" });
    }

    const token = header.split(" ")[1];

    // Check if Firebase is initialized
    if (!admin.apps.length) {
      console.error("[AUTH] ✗ Firebase NOT initialized - apps.length:", admin.apps.length);
      console.error("[AUTH] Cannot verify token without Firebase");
      return res.status(503).json({
        message: "Authentication service unavailable - Firebase not initialized"
      });
    }

    console.log("[AUTH] ✓ Firebase initialized, verifying token...");
    const decoded = await admin.auth().verifyIdToken(token);
    console.log("[AUTH] ✓ Token verified for user:", decoded.uid);
    req.userId = decoded.uid;
    next();
  } catch (err) {
    console.error("[AUTH] ✗ Token verification failed:", err.message);
    if (err.code === "auth/id-token-expired") {
      return res.status(401).json({ message: "Token expired" });
    }
    return res.status(401).json({ message: "Invalid or expired token" });
  }
};

module.exports = protect;

};

module.exports = protect;
