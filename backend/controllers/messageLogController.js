const MessageLog = require("../models/MessageLog");

// Create new message (this will be triggered by NPC interaction or a certain quest event)
exports.createMessage = async (req, res) => {
  try {
    const {
      userId,
      characterName,
      characterAvatar,
      message,
      messageType,
      location
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
    res.status(400).json({ message: err.message });
  }
};

// get user messages (for the purpose of logging)
exports.getUserMessages = async (req, res) => {
  try {
    const userId = req.params.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const query = { userId };
    
    // filter by read status 
    if (req.query.isRead !== undefined) {
      query.isRead = req.query.isRead === 'true';
    }

    // filter by message type 
    if (req.query.messageType) {
      query.messageType = req.query.messageType;
    }

    const messages = await MessageLog.find(query)
      .sort({ timestamp: -1 })
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
    res.status(500).json({ message: err.message });
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

    res.json({ unreadCount });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
}; 
