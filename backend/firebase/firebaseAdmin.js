const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

let firebaseInitialized = false;

// Try to initialize Firebase
if (!admin.apps.length) {
  try {
    // Try loading from local serviceAccountKey.json (development)
    const localKeyPath = path.join(__dirname, "serviceAccountKey.json");
    if (fs.existsSync(localKeyPath)) {
      const serviceAccount = require(localKeyPath);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      firebaseInitialized = true;
      console.log("[FIREBASE] ✓ Initialized with local serviceAccountKey.json");
    } else {
      throw new Error("Local key not found, trying Render secret files");
    }
  } catch (localErr) {
    try {
      // Try loading from Render's Secret Files location (production)
      const renderSecretPath = "/etc/secrets/serviceAccountKey.json";
      if (fs.existsSync(renderSecretPath)) {
        const serviceAccount = JSON.parse(
          fs.readFileSync(renderSecretPath, "utf8")
        );
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        firebaseInitialized = true;
        console.log("[FIREBASE] ✓ Initialized with Render secret file");
      } else {
        throw new Error("Render secret file not found");
      }
    } catch (renderErr) {
      // Try FIREBASE_CONFIG environment variable (fallback)
      if (process.env.FIREBASE_CONFIG) {
        try {
          const serviceAccount = JSON.parse(process.env.FIREBASE_CONFIG);
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
          });
          firebaseInitialized = true;
          console.log(
            "[FIREBASE] ✓ Initialized with FIREBASE_CONFIG environment variable"
          );
        } catch (parseErr) {
          console.warn("[FIREBASE] ⚠ FIREBASE_CONFIG is set but invalid JSON");
          console.warn("[FIREBASE] Error:", parseErr.message);
        }
      } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        try {
          admin.initializeApp();
          firebaseInitialized = true;
          console.log(
            "[FIREBASE] ✓ Initialized with Application Default Credentials"
          );
        } catch (appErr) {
          console.warn(
            "[FIREBASE] ⚠ Failed to use Application Default Credentials"
          );
          console.warn("[FIREBASE] Error:", appErr.message);
        }
      } else {
        console.warn(
          "[FIREBASE] ⚠ Firebase credentials not found - Firebase features will be disabled"
        );
        console.warn("[FIREBASE] Options:");
        console.warn("[FIREBASE]   1. Add serviceAccountKey.json to Render Secret Files");
        console.warn("[FIREBASE]   2. Set FIREBASE_CONFIG environment variable");
        console.warn("[FIREBASE]   3. Set GOOGLE_APPLICATION_CREDENTIALS");
      }
    }
  }
}

module.exports = admin;
module.exports.isInitialized = () => firebaseInitialized;
