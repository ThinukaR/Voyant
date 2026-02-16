const Destination = require('../models/Destination.js');

exports.createDestination = async (req, res) => {
  try {
    // .create() is a Mongoose method that:
    // 1. Validates the data against your Schema
    // 2. Turns it into BSON
    // 3. Sends it to MongoDB Atlas
    const newDestination = await Destination.create(req.body);

    res.status(201).json({
      status: 'success',
      data: { destination: newDestination }
    });
  } catch (err) {
    res.status(400).json({
      status: 'fail',
      message: err.message // Tells you if validation failed
    });
  }
};