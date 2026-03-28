// routes/userAccountDetailsRoutes.js
const express = require("express");
const controller = require("../controllers/userAccountDetailsController");

const router = express.Router();

router.post("/", controller.createUserAccountDetails);
router.get("/", controller.getUserAccountDetailsList);
router.get("/:id", controller.getUserAccountDetails);
router.put("/:id", controller.updateUserAccountDetails);
router.delete("/:id", controller.deleteUserAccountDetails);


// ============ NEW ACCOUNT SETTINGS ROUTES ============

// Profile Management
router.put("/:uid/profile", controller.updateProfile);
router.put("/:uid/profile-image", controller.updateProfileImage);

// Preferences
router.put("/:uid/preferences/location-sharing", controller.updateLocationSharing);

// Security Settings
router.put("/:uid/security/2fa", controller.updateTwoFA);
router.put("/:uid/security/biometric", controller.updateBiometric);

// Session Management
router.get("/:uid/sessions", controller.getLoginSessions);
router.post("/:uid/sessions", controller.addLoginSession);

// Social Accounts
router.post("/:uid/social-accounts/link", controller.linkSocialAccount);
router.post("/:uid/social-accounts/unlink", controller.unlinkSocialAccount);

// GDPR - Personal Data
router.get("/:uid/personal-data", controller.downloadPersonalData);

// Activity Tracking
router.put("/:uid/last-login", controller.updateLastLogin);

module.exports = router;