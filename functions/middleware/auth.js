const admin = require("../firebase/firebaseAdmin");

const protect = async (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith("Bearer ")) {
      return res.status(401).json({message: "No token provided"});
    }

    const token = header.split(" ")[1];
    const decoded = await admin.auth().verifyIdToken(token);
    req.userId = decoded.uid;
    next();
  } catch (err) {
    return res.status(401).json({message: "Invalid or expired token"});
  }
};

module.exports = protect;
