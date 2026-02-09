const mongoose = require("mongoose");

const skillSchema = new mongoose.schema({
    skillId : {
        type: Number,
        required: true,
        unique: true
    },
    name : {
        type: String,
        trim: true
    },
    status : {
        type: String,
        enum: ["Locked", "Unlocked"],
        default: "Locked",
    },
    skillPoint : {
        type: Number,
        required: [true, "Each skill need to have his its own number of skill points to unlock"]
    }
});

const Skill = mongoose.model("Skill", skillSchema);

module.exports = Skill;
