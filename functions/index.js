//Importing firebase functions and admin SDK, starting the admin app 
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();


//Global variables that will be used for the code generation logic 
const CODE_LENGTH = 6; //Sets the code length to 6 
const CODE_EXPIRY_TIME = 5; //Minutes until the code expires
const MAX_REDEMPTIONS = 10; //Users per code regenrated
const MAX_REFRESHES_HOURLY = 10; //Limit on refreshes to prevent spam 
const RECENT_REDEMPTIONS = 20; //Amount of recent redemptions shown 


function createBusinessCode() {
  let code = ""; 
  for (let i = 0; i < CODE_LENGTH; i++) {
    code += Math.floor(Math.random() * 10).toString(); //Math.floor will make sure the generated number will be integer 
  }
  return code;
}

function formatDate(timestamp) {
  const dateConvert = timestamp.toDate(); //converted to a date object 
  const y = dateConvert.getUTCFullYear();
  //pad start makes sure it is 2 digits instead of sometimes 1
  const m = String(dateConvert.getUTCMonth() + 1).padStart(2, "0");
  const d = String(dateConvert.getUTCDate()).padStart(2,"0");
  return `${y}-${m}-${d}`;
}

//Auth checks 
exports.initBusinessPartnerDashboard = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "user must be signed in."); //to execute if user is not authenticated
  }

  const now = admin.firestore.Timestamp.now();

  const uid = context.auth.uid; //retrieve user ID 
  const userRef = db.collection("users").doc(uid); //creates a reference to the user(based on UID) document ( basically a pointer)
  //creates a ref to the business partner data of the app
  const partnerRef = db.collection("business_partner_info").doc(uid); 

  const [userSnap, partnerSnap] = await Promise.all([userRef.get(), partnerRef.get()]);

  const isBusinessPartner = userSnap.exists && userSnap.data().isBusinessPartner === true;
    if (!isBusinessPartner) {
      throw new functions.https.HttpsError("permission-denied", "is not a business partner.");
    }

    if (partnerSnap.exists) {
      return { 
        success: true, 
        alreadyExists: true };
    }

  //calculation for expiry 
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + CODE_EXPIRY_TIME * 60 * 1000
    );

    await partnerRef.set({
      currentCode:  createBusinessCode(),
      codeExpiresAt: expiresAt,
      redemptions: 0,
      maxRedemptionsPerCode: MAX_REDEMPTIONS,
      refreshCount: 1,
      lastRefresh: now,
      refreshLimitPerHour: MAX_REFRESHES_HOURLY,
      dailyRedemptions: 0,
      totalRedemptions: 0,
      lastResetDate: formatDate(now),
      recentRedemptionTimestamps: [],
    });

    return {success: true , alreadyExists: true};
  }
);



 
