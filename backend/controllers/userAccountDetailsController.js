const UserAccountDetails = require("../models/UserAccountDetails");

exports.createUserAccountDetails = async (req, res) => {
  try {
    const doc = await UserAccountDetails.create(req.body);
    return res.status(201).json(doc);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.getUserAccountDetails = async (req, res) => {
  try {
    const doc = await UserAccountDetails.findById(req.params.id);
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.json(doc);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.getUserAccountDetailsList = async (_req, res) => {
  try {
    const docs = await UserAccountDetails.find();
    return res.json(docs);
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.updateUserAccountDetails = async (req, res) => {
  try {
    const doc = await UserAccountDetails.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true },
    );
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.json(doc);
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

exports.deleteUserAccountDetails = async (req, res) => {
  try {
    const doc = await UserAccountDetails.findByIdAndDelete(req.params.id);
    if (!doc) return res.status(404).json({ message: "Not found" });
    return res.status(204).send();
  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

plugins {

    id("com.google.gms.google-services") version "4.4.4" apply false

}
