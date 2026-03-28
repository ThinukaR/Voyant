const MessageLog = require("../models/MessageLog");

// Create new message from NPC interaction or quest events.
exports.createMessage = async (req, res) => {
  try {
    const {
      userId,
      characterName,
      characterAvatar,
      message,
      messageType,
      location,
    } = req.body;

    const newMessage = new MessageLog({
      userId,
      characterName,
      characterAvatar,
      message,
      messageType: messageType || "info",
      location,
    });

    await newMessage.save();

    res.status(201).json({
      message: "Message created successfully",
      data: newMessage,
    });
  } catch (err) {
    res.status(400).json({message: err.message});
  }
};

// get user messages (for the purpose of logging)
exports.getUserMessages = async (req, res) => {
  try {
    const userId = req.params.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const query = {userId};

    // filter by read status
    if (req.query.isRead !== undefined) {
      query.isRead = req.query.isRead === "true";
    }

    // filter by message type
    if (req.query.messageType) {
      query.messageType = req.query.messageType;
    }

    const messages = await MessageLog.find(query)
        .sort({timestamp: -1})
        .skip(skip)
        .limit(limit);

    const total = await MessageLog.countDocuments(query);

    res.json({
      messages,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(total / limit),
        totalMessages: total,
        hasNext: page * limit < total,
      },
    });
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};

// getting unread messages count
exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.params.userId;

    const unreadCount = await MessageLog.countDocuments({
      userId,
      isRead: false,
    });

    res.json({unreadCount});
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};

exports.markAsRead = async (req, res) => {
  try {
    const {messageIds} = req.body;
    const userId = req.params.userId;

    const result = await MessageLog.updateMany(
        {
          _id: {$in: messageIds},
          userId, // userId has to match ( they mark their messages)
        },
        {isRead: true},
    );

    res.json({
      message: "Messages marked as read",
      modifiedCount: result.modifiedCount,
    });
  } catch (err) {
    res.status(400).json({message: err.message});
  }
};

// mark all as read
exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.params.userId;

    const result = await MessageLog.updateMany(
        {userId, isRead: false},
        {isRead: true},
    );

    res.json({
      message: "All messages marked as read",
      modifiedCount: result.modifiedCount,
    });
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};


exports.deleteMessage = async (req, res) => {
  try {
    const userId = req.params.userId;
    const messageId = req.params.messageId;

    const result = await MessageLog.deleteOne({
      _id: messageId,
      userId, // Ensure user can only delete their own messages
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({message: "Message not found"});
    }

    res.json({message: "Message deleted successfully"});
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};

// message stats
exports.getMessageStats = async (req, res) => {
  try {
    const userId = req.params.userId;

    const stats = await MessageLog.aggregate([
      {$match: {userId}},
      {
        $group: {
          _id: null,
          totalMessages: {$sum: 1},
          unreadMessages: {
            $sum: {$cond: {if: {$eq: ["$isRead", false]}, then: 1, else: 0}},
          },
          messagesByType: {
            $push: {
              type: "$messageType",
              count: 1,
            },
          },
          recentMessages: {
            $push: {
              $each: {$sort: {timestamp: -1}},
              $slice: 5,
            },
          },
        },
      },
      {
        $project: {
          _id: 0,
          totalMessages: 1,
          unreadMessages: 1,
          messageTypes: {
            $arrayToObject: {
              $map: {
                input: {$arrayToObject: "$messagesByType"},
                as: "type",
                in: {k: "$$type.k", v: "$$type.v"},
              },
            },
          },
          recentMessages: {
            $map: {
              input: "$recentMessages",
              as: "msg",
              in: {
                characterName: "$$msg.characterName",
                message: "$$msg.message",
                timestamp: "$$msg.timestamp",
                messageType: "$$msg.messageType",
              },
            },
          },
        },
      },
    ]);

    res.json(stats[0] || {
      totalMessages: 0,
      unreadMessages: 0,
      messageTypes: {},
      recentMessages: [],
    });
  } catch (err) {
    res.status(500).json({message: err.message});
  }
};
