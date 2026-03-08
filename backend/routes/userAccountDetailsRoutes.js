// routes/userAccountDetailsRoutes.js
const express = require("express");
const controller = require("../controllers/userAccountDetailsController");

const router = express.Router();

router.post("/", controller.createUserAccountDetails);
router.get("/", controller.getUserAccountDetailsList);
router.get("/:id", controller.getUserAccountDetails);
router.put("/:id", controller.updateUserAccountDetails);
router.delete("/:id", controller.deleteUserAccountDetails);

module.exports = router;