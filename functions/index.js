const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * POST /ingestBinEvent
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
    const now = admin.firestore.FieldValue.serverTimestamp();

    // ===============================
    // 1️⃣ STORE EVENT (ANALYTICS)
    // ===============================
    await binRef.collection("events").add({
      timestamp: now,
      eventType,
      subBin: subBin || null,
      fillLevel: typeof fillLevel === "number" ? fillLevel : null,
      errorCode: errorCode || null,
    });

    // ===============================
    // 🔧 NORMALIZE FILL LEVEL (REUSED)
    // ===============================
    let normalizedFill = null;
    if (typeof fillLevel === "number") {
      const parsed = Number(fillLevel);
      if (!isNaN(parsed) && parsed >= 0 && parsed <= 100) {
        normalizedFill = parsed;
      }
    }

    // ===============================
    // ✅ 2️⃣ LEVEL UPDATE (FIXED)
    // ===============================
    if (eventType === "LEVEL_UPDATE" && subBin && normalizedFill !== null) {
      await binRef
        .collection("subBins")
        .doc(subBin)
        .set(
          {
            currentFillPercent: normalizedFill,
            isFull: normalizedFill >= 100,
            updatedAt: now,
          },
          { merge: true }
        );

      return res.status(200).json({
        status: "LEVEL_UPDATE applied",
        fillLevel: normalizedFill,
      });
    }

    // ===============================
    // 3️⃣ BIN FULL (AUTHORITATIVE)
    // ===============================
    if (eventType === "BIN_FULL" && subBin) {
      const fillToUse = normalizedFill ?? 100;

      // Update live status
      await binRef
        .collection("subBins")
        .doc(subBin)
        .set(
          {
            currentFillPercent: fillToUse,
            isFull: true,
            updatedAt: now,
          },
          { merge: true }
        );

      // Create alert ONLY when actually full
      if (fillToUse >= 100) {
        await binRef.collection("alerts").add({
          createdAt: now,
          subBin: subBin,
          alertType: "BIN_FULL",
          message: `${subBin.toUpperCase()} bin is full (${fillToUse}%)`,
          resolved: false,
          resolvedAt: null,
        });
      }

      return res.status(200).json({
        status: "BIN_FULL applied",
        fillLevel: fillToUse,
      });
    }

    // ===============================
    // 4️⃣ HARDWARE ERROR
    // ===============================
    if (eventType === "HARDWARE_ERROR") {
      await binRef.collection("alerts").add({
        createdAt: now,
        subBin: subBin || null,
        alertType: "HARDWARE_ERROR",
        message: `Hardware error: ${errorCode || "UNKNOWN"}`,
        resolved: false,
        resolvedAt: null,
      });

      return res.status(200).json({ status: "HARDWARE_ERROR logged" });
    }

    // ===============================
    // 5️⃣ BIN EMPTIED
    // ===============================
    if (eventType === "BIN_EMPTIED" && subBin) {
      // Resolve active alerts for this sub-bin
      const activeAlerts = await binRef
        .collection("alerts")
        .where("subBin", "==", subBin)
        .where("resolved", "==", false)
        .get();

      const batch = db.batch();

      activeAlerts.docs.forEach((doc) => {
        batch.update(doc.ref, {
          resolved: true,
          resolvedAt: now,
        });
      });

      await batch.commit();

      // Reset live status
      await binRef
        .collection("subBins")
        .doc(subBin)
        .set(
          {
            currentFillPercent: 0,
            isFull: false,
            updatedAt: now,
          },
          { merge: true }
        );

      return res.status(200).json({ status: "BIN_EMPTIED applied" });
    }

    return res.status(200).json({ status: "event logged only" });
  } catch (err) {
    console.error("ingestBinEvent error:", err);
    return res.status(500).json({ error: "Internal server error" });
  }
});
