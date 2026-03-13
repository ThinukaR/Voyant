//Importing firebase functions and admin SDK, starting the admin app 
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();


//Global variables that will be used for the code generation logic 
const CODE_LENGTH = 6; //Sets the code length to 6 
const CODE_EXPIRY_TIME = 5; //Minutes until the code expires
const MAX_REDEMPTIONS = 10; //Users per code regenrated
const MAX_REFRESHES_HOURLY = 12; //Limit on refreshes to prevent spam 
const RECENT_REDEMPTIONS = 20; //Amount of recent redemptions shown 


function createBusinessCode() {
  let code = ""; 
  for (let i = 0; i < CODE_LENGTH; i++) {
    code += Math.floor(Math.random() * 10).toString(); //Math.floor will make sure the generated number will be integer 
  }
  return code;
}


