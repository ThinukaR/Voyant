// routes/userAccountDetailsRoutes.js
const express = require("express");
const controller = require("../controllers/userAccountDetailsController");

const createRouter = express.Router;
const router = createRouter();

router.post("/", controller.createUserAccountDetails);
router.get("/", controller.getUserAccountDetailsList);
router.get("/:id", controller.getUserAccountDetails);
router.put("/:id", controller.updateUserAccountDetails);
router.delete("/:id", controller.deleteUserAccountDetails);

module.exports = router;
