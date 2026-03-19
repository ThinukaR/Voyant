const express = require("express");
const controller = require("../controllers/messageLogController");

const router = express.Router();

// Create new message (triggered by NPC or organization prompt)
router.post("/", controller.createMessage);

// Get user messages (for logs)
router.get("/user/:userId", controller.getUserMessages);

// Get unread messages count
router.get("/user/:userId/unread-count", controller.getUnreadCount);

// Mark messages as read
router.put("/user/:userId/mark-read", controller.markAsRead);

// Mark all messages as read
router.put("/user/:userId/mark-all-read", controller.markAllAsRead);

// Delete specific message
router.delete("/user/:userId/message/:messageId", controller.deleteMessage);

// Get message statistics
router.get("/user/:userId/stats", controller.getMessageStats);

module.exports = router; 