const connectToDatabase = require('./db');

async function startApp() {
  const db = await connectToDatabase();
  
  // Let's try to create a collection and insert one document
  const casesCollection = db.collection('test_collection');
}

startApp();