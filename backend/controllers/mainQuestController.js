const MainQuest = require("../models/MainQuest");
const SubQuest = require("../models/SubQuest");
// const UserMainQuestProgress = require("../models/UserMainQuestProgress");

exports.getAvailableMainQuests = async (req, res) => {
  try {
    const userId = req.params.userId;

    //getting users current progress
    const userProgress = await UserMainQuestProgress.find({ userId }).populate(
      "mainQuestId",
    );

    const completedQuestIds = userProgress
      .filter((progress) => progress.status === "completed")
      .map((progress) => progress.mainQuestId._id);

    //getting available main quests
    //a quest can be available if thee are no prerequisites or the required quests/tasks have been compelted
    const availableQuests = await MainQuest.find({
      $or: [
        { isAvailable: true, prerequisites: { $size: 0 } },
        {
          isAvailable: true,
          prerequisites: {
            $in: completedQuestIds,
          },
        },
      ],
    }).sort({ questOrder: 1 });

    res.json({
      availableQuests,
      userProgress: userProgress.reduce((acc, progress) => {
        acc[progress.mainQuestId._id] = progress;
        return acc;
      }, {}),
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

//Starting a main quest
exports.startMainQuest = async (req, res) => {
  try {
    const { userId, mainQuestId } = req.body;

    //validating the quest
    const mainQuest = await MainQuest.findById(mainQuestId);
    if (!mainQuest || !mainQuest.isAvailable) {
      return res.status(404).json({ message: "Quest not available" });
    }

    //check for user progress
    const existingProgress = await UserMainQuestProgress.findOne({
      userId,
      mainQuestId,
    });

    if (existingProgress) {
      return res.status(409).json({ message: "Quest already started" });
    }

    //creating new progress object
    const userProgress = new UserMainQuestProgress({
      userId,
      mainQuestId,
      status: "in_progress",
      startedAt: new Date(),
    });

    const subQuests = await SubQuest.find({ mainQuestId }).sort({
      questOrder: 1,
    });

    //intiializing progress for sub quest
    userProgress.subQuestProgress = subQuests.map((subQuest, index) => ({
      subQuestId: subQuest._id,
      //the first accessed quest wil be available , others will be locked
      status: index === 0 ? "available" : "locked",
      currentDialogueNodeId: subQuest.startDialogueId,
      completedDialogueNodes: [],
      userChoices: [],
      flags: [],
      xpEarned: 0,
    }));

    //saving progress
    await userProgress.save();

    res.status(201).json({
      message: "Main quest started",
      progress: await UserMainQuestProgress.findById(userProgress._id)
        .populate("mainQuestId")
        .populate("subQuestProgress.subQuestId"),
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

//getting current sub quest for the user
exports.getCurrentSubQuest = async (req, res) => {
  try {
    const { userId, mainQuestId } = req.params;

    const userProgress = await UserMainQuestProgress.findOne({
      userId,
      mainQuestId,
    }).populate({
      path: "subQuestProgress.subQuestId",
      populate: {
        path: "dialogueNodes",
      },
    });

    if (!userProgress) {
      return res.status(404).json({ message: "Quest progress was not found" });
    }

    //finding the current available sub-quest
    const currentSubQuestProgress = userProgress.subQuestProgress.find(
      (subQuest) =>
        subQuest.status === "available" || subQuest.status === "in_progress",
    );

    if (!currentSubQuestProgress) {
      return res
        .status(404)
        .json({ message: "No current sub-quest available" });
    }

    //finding the current dialogue node
    const currentNodeId = currentSubQuestProgress.currentDialogueNodeId;
    const currentNode = currentSubQuestProgress.subQuestId.dialogueNodes.find(
      (node) => node.id === currentNodeId,
    );

    if (!currentNode) {
      return res.status(404).json({ message: "Dialogue node not found" });
    }

    res.json({
      subQuest: currentSubQuestProgress.subQuestId,
      progress: currentSubQuestProgress,
      currentNode,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

//processing dialogue choices
exports.processDialogueChoice = async (req, res) => {
  try {
    const { userId, mainQuestId, dialogueNodeId, optionId, userInput } =
      req.body;

    const userProgress = await UserMainQuestProgress.findOne({
      userId,
      mainQuestId,
    }).populate("subQuestProgress.subQuestId");

    if (!userProgress) {
      return res.status(404).json({ message: "Quest progress not found" });
    }

    //finding current sub quests
    const currentSubQuestProgress = userProgress.subQuestProgress.find(
      (subQuest) =>
        subQuest.status === "available" || subQuest.status === "in_progress",
    );

    if (!currentSubQuestProgress) {
      return res.status(404).json({ message: "No active sub-quest" });
    }

    //finding the current dialogue node
    const currentNode = currentSubQuestProgress.subQuestId.dialogueNodes.find(
      (node) => node.id === dialogueNodeId,
    );

    if (!currentNode) {
      return res.status(404).json({ message: "Dialogue node not found" });
    }

    //selection option
    const selectedOption = currentNode.options.find(
      (option) => option.id === optionId,
    );

    if (!selectedOption) {
      return res.status(404).json({ message: "Option not found" });
    }

    //checking conditions like reference code
    if (selectedOption.conditions.requiresReference) {
      if (!userInput || userInput.trim() === "") {
        return res.status(400).json({
          message: "Reference code is required",
          requiresInput: true,
        });
      }

      //todo - validate reference code
    }

    //saving user choices
    currentSubQuestProgress.userChoices.push({
      dialogueNodeId,
      optionId,
      choice: userInput || selectedOption.text,
      timestamp: new Date(),
    });

    //if the story is changed due to user options
    if (selectedOption.consequences) {
      if (selectedOption.consequences.addFlag) {
        currentSubQuestProgress.flags.push(selectedOption.consequences.addFlag);
      }
    }

    //marking the current node as complete
    if (
      !currentSubQuestProgress.completedDialogueNodes.includes(dialogueNodeId)
    ) {
      currentSubQuestProgress.completedDialogueNodes.push(dialogueNodeId);
    }

    let nextNode;
    if (selectedOption.nextDialogueId) {
      nextNode = currentSubQuestProgress.subQuestId.dialogueNodes.find(
        (node) => node.id === selectedOption.nextDialogueId,
      );
      currentSubQuestProgress.currentDialogueNodeId =
        selectedOption.nextDialogueId;
    }

    //handling quest completion
    if (selectedOption.action === "complete_quest") {
      currentSubQuestProgress.status = "completed";
      currentSubQuestProgress.completedAt = new Date();
      currentSubQuestProgress.xpEarned =
        currentSubQuestProgress.subQuestId.rewards.xp || 0;

      //unlocking next sub-quest
      const currentIndex = userProgress.subQuestProgress.findIndex(
        (subQuest) =>
          subQuest.subQuestId._id.toString() ===
          currentSubQuestProgress.subQuestId._id.toString(),
      );

      if (currentIndex < userProgress.subQuestProgress.length - 1) {
        userProgress.subQuestProgress[currentIndex + 1].status = "available";
      }

      //check - in order to see if the main quest is completed
      const allCompleted = userProgress.subQuestProgress.every(
        (subQuest) => subQuest.status === "completed",
      );

      if (allCompleted) {
        userProgress.status = "completed";
        userProgress.completedAt = new Date();
      }
    }

    await userProgress.save();

    res.json({
      message: "Choice processed",
      nextNode,
      currentSubQuestProgress,
      isQuestCompleted: currentSubQuestProgress.status === "completed",
    });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

//getting overall quest progress
exports.getUserQuestProgress = async (req, res) => {
  try {
    const userId = req.params.userId;

    const userProgress = await UserMainQuestProgress.find({ userId })
      .populate("mainQuestId")
      .populate("subQuestProgress.subQuestId");

    res.json(userProgress);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
