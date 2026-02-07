const connectToDatabase = require('./db');

async function startApp() {
  const db = await connectToDatabase();
  
  // Creating a collection
  const casesCollection = db.collection('test_collection');
}

startApp();