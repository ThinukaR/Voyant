// WARNING: deletes all existing cosmetic items first
// SEED SCRIPT

require("dotenv").config();
const connectToDatabase = require("./db");
const CosmeticItem = require("./models/CosmeticItem");

async function seed() {
  await connectToDatabase();
  await CosmeticItem.deleteMany({});

  await CosmeticItem.insertMany([
    // HATS
    { name: "No Hat", category: "hat", color: "transparent", xpCost: 0 },
    { name: "Red Cap", category: "hat", color: "#E74C3C", xpCost: 0 },
    { name: "Blue Beanie", category: "hat", color: "#2980B9", xpCost: 100 },
    { name: "Gold Crown", category: "hat", color: "#F1C40F", xpCost: 500 },

    // HAIR
    { name: "Black Hair", category: "hair", color: "#1A1A1A", xpCost: 0 },
    { name: "Brown Hair", category: "hair", color: "#7D3C98", xpCost: 0 },
    { name: "Blonde Hair", category: "hair", color: "#F9E79F", xpCost: 100 },
    { name: "Purple Hair", category: "hair", color: "#B020DD", xpCost: 300 },

    // SHIRTS
    { name: "White Shirt", category: "shirt", color: "#ECF0F1", xpCost: 0 },
    { name: "Black Shirt", category: "shirt", color: "#2C3E50", xpCost: 0 },
    { name: "Purple Shirt", category: "shirt", color: "#B020DD", xpCost: 100 },
    { name: "Red Shirt", category: "shirt", color: "#E74C3C", xpCost: 200 },

    // PANTS
    { name: "Blue Jeans", category: "pants", color: "#2471A3", xpCost: 0 },
    { name: "Black Pants", category: "pants", color: "#1C2833", xpCost: 0 },
    { name: "Green Pants", category: "pants", color: "#1E8449", xpCost: 100 },
    { name: "White Pants", category: "pants", color: "#F2F3F4", xpCost: 200 },

    // SHOES
    { name: "White Shoes", category: "shoes", color: "#F2F3F4", xpCost: 0 },
    { name: "Black Shoes", category: "shoes", color: "#1C2833", xpCost: 0 },
    { name: "Red Shoes", category: "shoes", color: "#E74C3C", xpCost: 100 },
    { name: "Gold Shoes", category: "shoes", color: "#F1C40F", xpCost: 500 },
  ]);

  console.log("Cosmetics seeded!");
  process.exit(0);
}

seed().catch(console.error);
