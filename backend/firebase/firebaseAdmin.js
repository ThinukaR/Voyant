const admin = require("firebase-admin");

let firebaseInitialized = false;

// Try to initialize Firebase, but don't crash if it fails
if (!admin.apps.length) {
  try {
    // Try loading from serviceAccountKey.json if it exists locally
    const serviceAccount = require("./serviceAccountKey.json");
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    firebaseInitialized = true;
    console.log("[FIREBASE] ✓ Initialized with serviceAccountKey.json");
  } catch (err) {
    // If serviceAccountKey.json doesn't exist, try FIREBASE_CONFIG env var
    if (process.env.FIREBASE_CONFIG) {
      try {
        const serviceAccount = JSON.parse(process.env.FIREBASE_CONFIG);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        firebaseInitialized = true;
        console.log("[FIREBASE] ✓ Initialized with FIREBASE_CONFIG environment variable");
      } catch (parseErr) {
        console.warn("[FIREBASE] ⚠ FIREBASE_CONFIG is set but invalid JSON");
        console.warn("[FIREBASE] Error:", parseErr.message);
      }
    } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      try {
        admin.initializeApp();
        firebaseInitialized = true;
        console.log("[FIREBASE] ✓ Initialized with Application Default Credentials");
      } catch (appErr) {
        console.warn("[FIREBASE] ⚠ Failed to use Application Default Credentials");
        console.warn("[FIREBASE] Error:", appErr.message);
      }
    } else {
      console.warn("[FIREBASE] ⚠ Firebase credentials not found - Firebase features will be disabled");
      console.warn("[FIREBASE] Set FIREBASE_CONFIG environment variable to enable Firebase authentication");
    }
  }
}

module.exports = admin;
module.exports.isInitialized = () => firebaseInitialized;
