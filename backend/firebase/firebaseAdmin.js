const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");

let firebaseInitialized = false;

console.log("[FIREBASE] Attempting to initialize Firebase Admin...");

// Try to initialize Firebase
if (!admin.apps.length) {
  // First, try Render's Secret Files location (production priority)
  const renderSecretPath = "/etc/secrets/serviceAccountKey.json";
  console.log("[FIREBASE] Checking Render secret file at:", renderSecretPath);

  if (fs.existsSync(renderSecretPath)) {
    try {
      console.log("[FIREBASE] ✓ Found Render secret file, reading...");
      const serviceAccount = JSON.parse(
        fs.readFileSync(renderSecretPath, "utf8")
      );
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      firebaseInitialized = true;
      console.log("[FIREBASE] ✓ Successfully initialized with Render secret file");
    } catch (err) {
      console.error("[FIREBASE] ✗ Error reading Render secret file:", err.message);
    }
  } else {
    console.log("[FIREBASE] ✗ Render secret file not found at", renderSecretPath);
  }

  // If not initialized yet, try local serviceAccountKey.json (development)
  if (!firebaseInitialized) {
    const localKeyPath = path.join(__dirname, "serviceAccountKey.json");
    console.log("[FIREBASE] Checking local file at:", localKeyPath);

    if (fs.existsSync(localKeyPath)) {
      try {
        console.log("[FIREBASE] ✓ Found local serviceAccountKey.json, reading...");
        const serviceAccount = require(localKeyPath);
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
        firebaseInitialized = true;
        console.log("[FIREBASE] ✓ Successfully initialized with local serviceAccountKey.json");
      } catch (err) {
        console.error("[FIREBASE] ✗ Error reading local file:", err.message);
      }
    } else {
      console.log("[FIREBASE] ✗ Local serviceAccountKey.json not found at", localKeyPath);
    }
  }

  // If not initialized yet, try FIREBASE_CONFIG environment variable
  if (!firebaseInitialized && process.env.FIREBASE_CONFIG) {
    console.log("[FIREBASE] Trying FIREBASE_CONFIG environment variable...");
    try {
      const serviceAccount = JSON.parse(process.env.FIREBASE_CONFIG);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      firebaseInitialized = true;
      console.log("[FIREBASE] ✓ Successfully initialized with FIREBASE_CONFIG");
    } catch (err) {
      console.error("[FIREBASE] ✗ Error parsing FIREBASE_CONFIG:", err.message);
    }
  }

  // If not initialized yet, try Application Default Credentials
  if (!firebaseInitialized && process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    console.log("[FIREBASE] Trying Application Default Credentials...");
    try {
      admin.initializeApp();
      firebaseInitialized = true;
      console.log("[FIREBASE] ✓ Successfully initialized with Application Default Credentials");
    } catch (err) {
      console.error("[FIREBASE] ✗ Error using Application Default Credentials:", err.message);
    }
  }

  // If STILL not initialized, show what we need
  if (!firebaseInitialized) {
    console.warn("[FIREBASE] ⚠⚠⚠ Firebase credentials NOT FOUND ⚠⚠⚠");
    console.warn("[FIREBASE] Firebase features will be DISABLED");
    console.warn("[FIREBASE] To enable Firebase, do ONE of the following:");
    console.warn("[FIREBASE]   1. Add serviceAccountKey.json file to Render Secret Files");
    console.warn("[FIREBASE]   2. Set FIREBASE_CONFIG environment variable with minified JSON");
    console.warn("[FIREBASE]   3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable");
  }
}

module.exports = admin;
module.exports.isInitialized = () => firebaseInitialized;
module.exports.isInitialized = () => firebaseInitialized;
