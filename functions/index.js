const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * POST /ingestBinEvent
 * Handles all hardware events from the Smart Bin Raspberry Pi
 */
exports.ingestBinEvent = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Use POST method" });
    }

    const { binId, subBin, eventType, fillLevel, errorCode, gasType, gasLevel, moistureLevel } = req.body;

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
    const eventData = {
      timestamp: now,
      eventType,
      subBin: subBin || null,
      fillLevel: typeof fillLevel === "number" ? fillLevel : null,
      errorCode: errorCode || null,
    };

    // Add extra fields for new event types
    if (eventType === "HARMFUL_GAS") {
      eventData.gasType = gasType || "unknown";
      eventData.gasLevel = typeof gasLevel === "number" ? gasLevel : null;
    }
    if (eventType === "MOISTURE_DETECTED") {
      eventData.moistureLevel = typeof moistureLevel === "number" ? moistureLevel : null;
    }

    await binRef.collection("events").add(eventData);

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
    // ✅ 2️⃣ LEVEL UPDATE
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
    // 3️⃣ BIN FULL
    // ===============================
    if (eventType === "BIN_FULL" && subBin) {
      const fillToUse = normalizedFill ?? 100;

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

      if (fillToUse >= 100) {
        await binRef.collection("alerts").add({
          createdAt: now,
          subBin: subBin,
          alertType: "BIN_FULL",
          message: `${subBin.toUpperCase()} bin is full (${fillToUse}%)`,
          severity: "warning",
          resolved: false,
          isResolved: false,
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
        severity: "error",
        resolved: false,
        isResolved: false,
        resolvedAt: null,
      });

      return res.status(200).json({ status: "HARDWARE_ERROR logged" });
    }

    // ===============================
    // 5️⃣ BIN EMPTIED
    // ===============================
    if (eventType === "BIN_EMPTIED" && subBin) {
      const activeAlerts = await binRef
        .collection("alerts")
        .where("subBin", "==", subBin)
        .where("resolved", "==", false)
        .get();

      const batch = db.batch();

      activeAlerts.docs.forEach((doc) => {
        // Only auto-resolve BIN_FULL alerts — safety alerts require manual resolution
        const alertType = doc.data().alertType;
        if (alertType === "BIN_FULL") {
          batch.update(doc.ref, {
            resolved: true,
            isResolved: true,
            resolvedAt: now,
          });
        }
      });

      await batch.commit();

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

    // ===============================
    // 6️⃣ PIECE COLLECTED
    // ===============================
    if (eventType === "PIECE_COLLECTED" && subBin) {
      return res.status(200).json({
        status: "PIECE_COLLECTED logged",
        subBin: subBin,
      });
    }

    // ===============================
    // 7️⃣ BATTERY DETECTED (NEW SAFETY ALERT)
    // ===============================
    if (eventType === "BATTERY_DETECTED" && subBin) {
      await binRef.collection("alerts").add({
        createdAt: now,
        subBin: subBin,
        alertType: "BATTERY_DETECTED",
        message: `Battery detected in ${subBin} bin — remove immediately`,
        severity: "error",
        resolved: false,
        isResolved: false,
        resolvedAt: null,
      });

      return res.status(200).json({ status: "BATTERY_DETECTED alert created" });
    }

    // ===============================
    // 8️⃣ HARMFUL GAS (NEW SAFETY ALERT)
    // ===============================
    if (eventType === "HARMFUL_GAS") {
      const normalizedGasLevel = typeof gasLevel === "number" ? gasLevel : 0;
      const normalizedGasType = gasType || "unknown";

      // Only create alert if gas level is >= 500 PPM
      if (normalizedGasLevel < 500) {
        return res.status(200).json({
          status: "HARMFUL_GAS logged (below threshold)",
          gasLevel: normalizedGasLevel,
        });
      }

      const severity = normalizedGasLevel >= 1000 ? "error" : "warning";

      await binRef.collection("alerts").add({
        createdAt: now,
        subBin: subBin || null,
        alertType: "HARMFUL_GAS",
        message: `Harmful gas (${normalizedGasType}) detected: ${normalizedGasLevel} PPM — investigate immediately`,
        severity: severity,
        gasType: normalizedGasType,
        gasLevel: normalizedGasLevel,
        resolved: false,
        isResolved: false,
        resolvedAt: null,
      });

      return res.status(200).json({
        status: "HARMFUL_GAS alert created",
        severity: severity,
        gasLevel: normalizedGasLevel,
      });
    }

    // ===============================
    // 9️⃣ MOISTURE DETECTED (NEW SAFETY ALERT)
    // ===============================
    if (eventType === "MOISTURE_DETECTED" && subBin) {
      const normalizedMoisture = typeof moistureLevel === "number" ? moistureLevel : 0;

      // Only create alert if moisture level is >= 70
      if (normalizedMoisture < 70) {
        return res.status(200).json({
          status: "MOISTURE_DETECTED logged (below threshold)",
          moistureLevel: normalizedMoisture,
        });
      }

      const severity = normalizedMoisture >= 90 ? "error" : "warning";

      await binRef.collection("alerts").add({
        createdAt: now,
        subBin: subBin,
        alertType: "MOISTURE_DETECTED",
        message: `High moisture in ${subBin} bin: ${normalizedMoisture}% — check for liquid spillage`,
        severity: severity,
        moistureLevel: normalizedMoisture,
        resolved: false,
        isResolved: false,
        resolvedAt: null,
      });

      return res.status(200).json({
        status: "MOISTURE_DETECTED alert created",
        severity: severity,
        moistureLevel: normalizedMoisture,
      });
    }

    return res.status(200).json({ status: "event logged only" });
  } catch (error) {
    console.error("Error ingesting bin event:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});

/**
 * POST /resolveAlert
 * Manually resolve a safety alert (BATTERY_DETECTED, HARMFUL_GAS, MOISTURE_DETECTED, HARDWARE_ERROR)
 * Payload: { "binId": "BIN_001", "alertId": "abc123" }
 */
exports.resolveAlert = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Use POST method" });
    }

    const { binId, alertId } = req.body;

    if (!binId || !alertId) {
      return res.status(400).json({
        error: "Missing required fields: binId and alertId",
      });
    }

    const alertRef = db
      .collection("bins")
      .doc(binId)
      .collection("alerts")
      .doc(alertId);

    const alertDoc = await alertRef.get();

    if (!alertDoc.exists) {
      return res.status(404).json({ error: "Alert not found" });
    }

    const alertData = alertDoc.data();

    if (alertData.isResolved || alertData.resolved) {
      return res.status(400).json({ error: "Alert is already resolved" });
    }

    const manuallyResolvableTypes = [
      "BATTERY_DETECTED",
      "HARMFUL_GAS",
      "MOISTURE_DETECTED",
      "HARDWARE_ERROR",
    ];

    if (!manuallyResolvableTypes.includes(alertData.alertType)) {
      return res.status(400).json({
        error: `Alert type '${alertData.alertType}' cannot be manually resolved`,
      });
    }

    const now = admin.firestore.FieldValue.serverTimestamp();

    await alertRef.update({
      resolved: true,
      isResolved: true,
      resolvedAt: now,
    });

    return res.status(200).json({
      status: "Alert resolved",
      alertId: alertId,
      binId: binId,
    });
  } catch (error) {
    console.error("Error resolving alert:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
});
