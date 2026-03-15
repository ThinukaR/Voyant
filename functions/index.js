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
  const partnerRef = db.collection("business_partner_data").doc(uid); 

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

exports.refreshBusinessPartnerCode = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "you should be signed in to refresh the code."
    );
  }

  const uid = context.auth.uid;
  const userRef = db.collection("users").doc(uid);
  const partnerRef = db.collection("business_partner_data").doc(uid);

  const [userSnap, partnerSnap] = await Promise.all([userRef.get(), partnerRef.get()]);

  const isBusinessPartner = userSnap.exists && userSnap.data().isBusinessPartner === true;
  if (!isBusinessPartner) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only partnered businesses can refresh the code."
    );
  }

  const now = admin.firestore.Timestamp.now();
  //calculating timestamp for hour 
  const oneHourAgo = admin.firestore.Timestamp.fromMillis(now.toMillis() - 60 * 60 * 1000);

  const partner = partnerSnap.exists ? partnerSnap.data() : null;
  //if last refresh is missing or refreshcount is missing it will be set to 0 
  const lastRefreshAtMs = partner?.lastRefreshAt?.toMillis?.() ?? 0;
  const refreshCount = partner?.refreshCount ?? 0;

  const windowReset = lastRefreshAt < oneHourAgo.toMillis();
  const windowRefreshCount = windowReset ? 0 : refreshCount;

  if (windowRefreshCount >= MAX_REFRESHES_HOURLY) {
    throw new functions.https.HttpsError(
      "limit-reached",
      "Refresh limit has been reached. Please try again later."
    );
  }

  const expiresAt = admin.firestore.Timestamp.fromMillis(
    now.toMillis() + CODE_EXPIRY_TIME * 60 * 1000
  );

  await partnerRef.set(
    {
      currentCode: createBusinessCode(),
      codeExpiresAt: expiresAt,
      redemptions : 0,
      maxRedemptionsPerCode: MAX_REDEMPTIONS,
      refreshCount: windowReset ? 1 : refreshCount + 1,
      lastRefresh: now,
      refreshLimitPerHour: MAX_REFRESHES_HOURLY,
      dailyRedemptions: partner?.dailyRedemptions ?? 0,
      totalRedemptions: partner?.totalRedemptions ?? 0,
      lastResetDate: partner?.lastResetDate ?? formatDate(now),
      recentRedemptionTimestamps: partner?.recentRedemptionTimestamps ?? [],
    },
    { merge: true }
  );

  return {success: true}
});

exports.redeemQuestCode = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated", "you should be signed in.");
  }

  //Code extraction logic - accesing the code and if it does not exist using empty sring
  const code = (data?.code ?? "").toString().trim();
  //code length check and regex check to ensure that the code will only contain numbers
  if (code.length !== CODE_LENGTH || !/^\d+$/.test(code)) {
    throw new functions.https.HttpsError(
      "invalid-argument", 
      "Invalid Code.");
  }

  const now = admin.firestore.Timestamp.now();

//Making one code ( which will be active ) map to one business partner
  const querySnap = await db
    .collection("business_partner_data")
    .where("currentCode", "==", code)
    .limit(1)
    .get();

  if (querySnap.empty) {
    throw new functions.https.HttpsError(
      "not-found", 
      "The code was not connected to a business partner or has expired.");
  }

  const doc = querySnap.docs[0];
  const partner = doc.data();

  //executes if it is expiration time is missing or it is expired 
  const expiresAt = partner.codeExpiresAt;
  if (!expiresAt || expiresAt.toMillis() < now.toMillis()) {
    throw new functions.https.HttpsError(
      "code-no-longer-valid", 
      "Code has expired.");
  }

  const redemptionsThisCode = partner.redemptions ?? 0;
  const maxPerCode = partner.maxRedemptionsPerCode ?? MAX_REDEMPTIONS;

  if (redemptionsThisCode >= maxPerCode) {
    throw new functions.https.HttpsError(
      "redemptions-have-exceeded",
      "This code has reached its redemption limit."
    );
  }

  const today = formatDate(now);
  const lastResetDate = partner.lastResetDate ?? today;
  //reset the counter if it's a new day of redemption
  const todayRedemptions = lastResetDate === today ? (partner.dailyRedemptions ?? 0) : 0;
  const totalRedemptions = (partner.totalRedemptions ?? 0) + 1;

  const recent = Array.isArray(partner.recentRedemptionTimestamps)
    ? partner.recentRedemptionTimestamps
    : [];
  const newRecent = [now, ...recent].slice(0, RECENT_REDEMPTIONS); //removing any old entries 

  const newRedemptionsThisCode = redemptionsThisCode + 1;
  const shouldChange = newRedemptionsThisCode >= maxPerCode;

  const update = {
    redemptionsThisCode: newRedemptionsThisCode,
    dailyredemptions: todayRedemptions + 1,
    totalRedemptions,
    lastResetDate: today,
    recentRedemptionTimestamps: newRecent,
  };

  if (shouldChange) {
    const expiresAtNew = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + CODE_EXPIRY_TIME * 60 * 1000
    );
    update.currentCode = createBusinessCode();
    update.codeExpiresAt = expiresAtNew;
    update.redemptions = 0;
  }

  await doc.ref.update(update);

  return {
    success: true,
    //TODO - reward information 
  };

});



 
