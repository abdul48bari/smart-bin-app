const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Test function (no logic yet)
exports.testApi = functions.https.onRequest((req, res) => {
  res.status(200).json({
    message: "API is working",
    timestamp: new Date().toISOString(),
  });
});
