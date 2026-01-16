const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * POST /ingestBinEvent
 * Body example:
 * {
 *   "binId": "BIN_001",
 *   "subBin": "plastic",
 *   "eventType": "BIN_FULL",
 *   "fillLevel": 92,
 *   "errorCode": null
 * }
 */
exports.ingestBinEvent = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Use POST method" });
    }

    const { binId, subBin, eventType, fillLevel, errorCode } = req.body;

    if (!binId || !eventType) {
      return res.status(400).json({
        error: "Missing required fields: binId or eventType",
      });
    }

    const binRef = db.collection("bins").doc(binId);

    // 1️⃣ Save event
    await binRef.collection("events").add({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      subBin: subBin || null,
      eventType,
      fillLevel: typeof fillLevel === "number" ? fillLevel : null,
      errorCode: errorCode || null,
    });

  // 2️⃣ Update sub-bin fill level (if provided)
  if (subBin && typeof fillLevel === "number") {
    const isFull = fillLevel >= 90;

    await binRef
      .collection("subBins")
      .doc(subBin)
      .set(
        {
          currentFillPercent: fillLevel,
          isFull: isFull,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      { merge: true }
    );

  // 3️⃣ Create alert when bin becomes full
  if (eventType === "BIN_FULL" && isFull) {
    await binRef.collection("alerts").add({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      subBin: subBin,
      alertType: "BIN_FULL",
      message: `${subBin} bin is full (${fillLevel}%)`,
      resolved: false,
      resolvedAt: null,
    });
  }
}

// 4️⃣ Create alert for hardware errors
if (eventType === "HARDWARE_ERROR") {
  await binRef.collection("alerts").add({
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    subBin: subBin || null,
    alertType: "HARDWARE_ERROR",
    message: `Hardware error: ${errorCode || "UNKNOWN"}`,
    resolved: false,
    resolvedAt: null,
  });
}

  // 5️⃣ Resolve alerts when bin is emptied
if (eventType === "BIN_EMPTIED" && subBin) {
  const activeAlerts = await binRef
    .collection("alerts")
    .where("subBin", "==", subBin)
    .where("resolved", "==", false)
    .get();

  const batch = db.batch();

  activeAlerts.docs.forEach((doc) => {
    batch.update(doc.ref, {
      resolved: true,
      resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
}


    return res.status(200).json({ status: "event stored successfully" });
  } catch (err) {
    console.error("ingestBinEvent error:", err);
    return res.status(500).json({ error: "Internal server error" });
  }
});
