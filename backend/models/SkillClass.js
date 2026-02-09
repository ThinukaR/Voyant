const mongoose = require("mongoose");

const skillClassSchema = new mongoose.schema({
    classId: {
        type: Number,
        required: true
    },
    name: {
        type: String,
        trim: true
    },
    skillsArray: {
        type: String,
        enum: ["skill1", "skill2", "skill3"],
    }
});

const Skill_Class = mongoose.model("Skill Class", skillClassSchema);

module.exports = Skill_Class;
