const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
    taskId: {
        type: Number,
        required: true,
        unique: true
    },
    name: {
        type: String,
        required: true,
        trim: true
    },
    quest: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Quest",
        required: [true, "A task must belong to a quest"],
    },
    achievements: {
        type: String,
        required: [true, 'A task must provide achievements or xp']
    } 
});


const Task = mongoose.model('Task', taskSchema);

module.exports = Task;