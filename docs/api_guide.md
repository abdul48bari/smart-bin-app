# Smart Bin API Guide

## Overview

The Smart Bin API is a Firebase Cloud Functions HTTP endpoint that ingests hardware events from Smart Bin devices (Raspberry Pi). All hardware sensors send POST requests to this endpoint when events occur.

---

## Endpoint

```
POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app
```

| Property       | Value                                      |
|----------------|--------------------------------------------|
| Method         | `POST`                                     |
| Content-Type   | `application/json`                         |
| Authentication | None (public endpoint)                     |
| Response       | JSON `{ "status": "..." }`                 |

---

## Sub-Bin Types

| Key       | Label   | Color     |
|-----------|---------|-----------|
| `plastic` | Plastic | `#3B82F6` (Blue)   |
| `paper`   | Paper   | `#10B981` (Green)  |
| `organic` | Organic | `#92400E` (Brown)  |
| `cans`    | Cans    | `#F59E0B` (Amber)  |
| `mixed`   | Mixed   | `#8B5CF6` (Purple) |

---

## Fill Level Color Thresholds

| Range      | Color  |
|------------|--------|
| 0–30%      | Green  |
| 31–89%     | Yellow |
| 90–100%    | Red    |

---

## Event Types — All 8 Types

| #  | Event Type           | Category   | Auto-Resolves? | Alert Created? |
|----|----------------------|------------|----------------|----------------|
| 1  | `LEVEL_UPDATE`       | Status     | N/A            | No             |
| 2  | `BIN_FULL`           | Status     | Yes (BIN_EMPTIED) | Yes (warning) |
| 3  | `BIN_EMPTIED`        | Status     | N/A            | No (resolves BIN_FULL) |
| 4  | `PIECE_COLLECTED`    | Analytics  | N/A            | No             |
| 5  | `HARDWARE_ERROR`     | Error      | No             | Yes (error)    |
| 6  | `BATTERY_DETECTED`   | 🔴 Safety  | **No — manual** | Yes (error)  |
| 7  | `HARMFUL_GAS`        | 🔴 Safety  | **No — manual** | Yes (warning/error) |
| 8  | `MOISTURE_DETECTED`  | 🔴 Safety  | **No — manual** | Yes (warning/error) |

---

## Required Fields (by event type)

| Event Type         | `binId` | `eventType` | `subBin` | `fillLevel` | `errorCode` | `gasType` | `gasLevel` | `moistureLevel` |
|--------------------|:-------:|:-----------:|:--------:|:-----------:|:-----------:|:---------:|:----------:|:---------------:|
| LEVEL_UPDATE       | ✓       | ✓           | ✓        | ✓           |             |           |            |                 |
| BIN_FULL           | ✓       | ✓           | ✓        | optional    |             |           |            |                 |
| BIN_EMPTIED        | ✓       | ✓           | ✓        |             |             |           |            |                 |
| PIECE_COLLECTED    | ✓       | ✓           | ✓        |             |             |           |            |                 |
| HARDWARE_ERROR     | ✓       | ✓           | optional | optional    | optional    |           |            |                 |
| BATTERY_DETECTED   | ✓       | ✓           | ✓        |             |             |           |            |                 |
| HARMFUL_GAS        | ✓       | ✓           | optional |             |             | optional  | ✓          |                 |
| MOISTURE_DETECTED  | ✓       | ✓           | ✓        |             |             |           |            | ✓               |

---

## Event Type Details

---

### 1. LEVEL_UPDATE

Updates the fill level of a specific sub-bin. Used for regular sensor readings.

**Payload:**
```json
{
  "binId": "BIN_001",
  "eventType": "LEVEL_UPDATE",
  "subBin": "plastic",
  "fillLevel": 45
}
```

**What it does:**
- Updates `bins/{binId}/subBins/{subBin}` → `currentFillPercent`, `isFull`, `updatedAt`
- Logs event to `bins/{binId}/events/`
- No alert created

**curl example:**
```bash
curl -X POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "binId": "BIN_001",
    "eventType": "LEVEL_UPDATE",
    "subBin": "plastic",
    "fillLevel": 45
  }'
```

**Python example:**
```python
import requests

requests.post(
    "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app",
    json={
        "binId": "BIN_001",
        "eventType": "LEVEL_UPDATE",
        "subBin": "plastic",
        "fillLevel": 45,
    }
)
```

---

### 2. BIN_FULL

Marks a sub-bin as full and creates a `BIN_FULL` alert. Triggered when the bin reaches 100%.

**Payload:**
```json
{
  "binId": "BIN_001",
  "eventType": "BIN_FULL",
  "subBin": "paper",
  "fillLevel": 100
}
```

**What it does:**
- Sets `isFull: true` in sub-bin document
- Creates a `severity: "warning"` alert
- Auto-resolves when `BIN_EMPTIED` is sent for the same sub-bin

**curl example:**
```bash
curl -X POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "binId": "BIN_001",
    "eventType": "BIN_FULL",
    "subBin": "paper",
    "fillLevel": 100
  }'
```

**Python example:**
```python
requests.post(
    "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app",
    json={
        "binId": "BIN_001",
        "eventType": "BIN_FULL",
        "subBin": "paper",
        "fillLevel": 100,
    }
)
```

---

### 3. BIN_EMPTIED

Resets a sub-bin fill level to 0% and automatically resolves all active `BIN_FULL` alerts for that sub-bin.

> **Note:** Safety alerts (BATTERY_DETECTED, HARMFUL_GAS, MOISTURE_DETECTED) are NOT auto-resolved by BIN_EMPTIED. They require manual resolution.

**Payload:**
```json
{
  "binId": "BIN_001",
  "eventType": "BIN_EMPTIED",
  "subBin": "plastic"
}
```

**curl example:**
```bash
curl -X POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "binId": "BIN_001",
    "eventType": "BIN_EMPTIED",
    "subBin": "plastic"
  }'
```

**Python example:**
```python
requests.post(
    "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app",
    json={
        "binId": "BIN_001",
        "eventType": "BIN_EMPTIED",
        "subBin": "plastic",
    }
)
```

---

### 4. PIECE_COLLECTED

Logs when a piece of waste is classified and sorted into a sub-bin. Used for analytics (pieces count charts).

**Payload:**
```json
{
  "binId": "BIN_001",
  "eventType": "PIECE_COLLECTED",
  "subBin": "organic"
}
```

**curl example:**
```bash
curl -X POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "binId": "BIN_001",
    "eventType": "PIECE_COLLECTED",
    "subBin": "organic"
  }'
```

**Python example:**
```python
requests.post(
    "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app",
    json={
        "binId": "BIN_001",
        "eventType": "PIECE_COLLECTED",
        "subBin": "organic",
    }
)
```

---

### 5. HARDWARE_ERROR

Logs a hardware malfunction or sensor failure. Creates a `severity: "error"` alert. Requires **manual resolution** by admin.

**Payload:**
```json
{
  "binId": "BIN_001",
  "eventType": "HARDWARE_ERROR",
  "subBin": "cans",
  "errorCode": "SENSOR_MALFUNCTION"
}
```

**curl example:**
```bash
curl -X POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "binId": "BIN_001",
    "eventType": "HARDWARE_ERROR",
    "subBin": "cans",
    "errorCode": "SENSOR_MALFUNCTION"
  }'
```

**Python example:**
```python
requests.post(
    "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app",
    json={
        "binId": "BIN_001",
        "eventType": "HARDWARE_ERROR",
        "subBin": "cans",
        "errorCode": "SENSOR_MALFUNCTION",
    }
)
```

---

### 6. BATTERY_DETECTED ⚠️ Safety Alert

A battery (AA, AAA, lithium, etc.) has been thrown into the bin. Batteries are hazardous and must NOT be mixed with regular trash. Always creates a `severity: "error"` alert.

The admin must physically remove the battery, then manually resolve the alert from the app.

**Payload:**
```json
{
  "binId": "BIN_001",
  "eventType": "BATTERY_DETECTED",
  "subBin": "mixed"
}
```

**Alert created:**
- `alertType`: `"BATTERY_DETECTED"`
- `severity`: `"error"` (always)
- `message`: `"Battery detected in {subBin} bin — remove immediately"`
- Auto-resolves: **No** — requires admin to manually resolve

**curl example:**
```bash
curl -X POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "binId": "BIN_001",
    "eventType": "BATTERY_DETECTED",
    "subBin": "mixed"
  }'
```

**Python example:**
```python
requests.post(
    "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app",
    json={
        "binId": "BIN_001",
        "eventType": "BATTERY_DETECTED",
        "subBin": "mixed",
    }
)
```

---

### 7. HARMFUL_GAS ⚠️ Safety Alert

The MQ-series gas sensor has detected dangerous gas levels (methane, ammonia, hydrogen sulfide, etc.). Alert is created when `gasLevel >= 500 PPM`.

| gasLevel       | severity  |
|----------------|-----------|
| 500–999 PPM    | `warning` |
| ≥ 1000 PPM     | `error`   |

The admin must investigate, ventilate the area, then manually resolve the alert.

**Payload:**
```json
{
  "binId": "BIN_001",
  "eventType": "HARMFUL_GAS",
  "gasType": "methane",
  "gasLevel": 750
}
```

**Fields:**
| Field      | Type   | Values                                                         |
|------------|--------|----------------------------------------------------------------|
| `gasType`  | string | `"methane"`, `"ammonia"`, `"hydrogen_sulfide"`, `"co2"`, `"voc"`, `"unknown"` |
| `gasLevel` | number | PPM (parts per million). Alert threshold: ≥ 500               |

**curl example:**
```bash
curl -X POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "binId": "BIN_001",
    "eventType": "HARMFUL_GAS",
    "gasType": "methane",
    "gasLevel": 750
  }'
```

**Python example:**
```python
requests.post(
    "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app",
    json={
        "binId": "BIN_001",
        "eventType": "HARMFUL_GAS",
        "gasType": "methane",
        "gasLevel": 750,
    }
)
```

---

### 8. MOISTURE_DETECTED ⚠️ Safety Alert

The moisture sensor has detected dangerous liquid levels inside a sub-bin compartment. Alert created when `moistureLevel >= 70`.

| moistureLevel | severity  |
|---------------|-----------|
| 70–89%        | `warning` |
| ≥ 90%         | `error`   |

The admin must check and dry/clean the compartment, then manually resolve the alert.

**Payload:**
```json
{
  "binId": "BIN_001",
  "eventType": "MOISTURE_DETECTED",
  "subBin": "paper",
  "moistureLevel": 85
}
```

**curl example:**
```bash
curl -X POST https://ingestbinevent-t4vkrtxd5q-uc.a.run.app \
  -H "Content-Type: application/json" \
  -d '{
    "binId": "BIN_001",
    "eventType": "MOISTURE_DETECTED",
    "subBin": "paper",
    "moistureLevel": 85
  }'
```

**Python example:**
```python
requests.post(
    "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app",
    json={
        "binId": "BIN_001",
        "eventType": "MOISTURE_DETECTED",
        "subBin": "paper",
        "moistureLevel": 85,
    }
)
```

---

## Manual Alert Resolution

Safety alerts (BATTERY_DETECTED, HARMFUL_GAS, MOISTURE_DETECTED) and HARDWARE_ERROR alerts do **not** auto-resolve. The admin resolves them manually from the app after handling the situation.

### Via Flutter App
The Alerts screen shows a green **Resolve** button for each unresolved safety alert. Tapping shows a confirmation dialog.

### Via Cloud Function (optional)

```
POST https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/resolveAlert
```

**Payload:**
```json
{
  "binId": "BIN_001",
  "alertId": "abc123xyz"
}
```

**Responses:**
| Status | Description                        |
|--------|------------------------------------|
| 200    | Alert resolved successfully        |
| 400    | Already resolved or invalid type   |
| 404    | Alert not found                    |
| 500    | Internal server error              |

---

## Firestore Database Changes

### New `alertType` values in `bins/{binId}/alerts/{alertId}`

The `alertType` field now supports 3 new values in addition to the existing `BIN_FULL` and `HARDWARE_ERROR`:

| alertType          | When created                          | Auto-resolves? |
|--------------------|---------------------------------------|----------------|
| `BATTERY_DETECTED` | Battery thrown into bin               | No             |
| `HARMFUL_GAS`      | Gas level ≥ 500 PPM                   | No             |
| `MOISTURE_DETECTED`| Moisture level ≥ 70%                  | No             |

### New event document fields in `bins/{binId}/events/{eventId}`

**BATTERY_DETECTED event document:**
```json
{
  "timestamp": "<Timestamp>",
  "eventType": "BATTERY_DETECTED",
  "subBin": "mixed",
  "fillLevel": null,
  "errorCode": null
}
```

**HARMFUL_GAS event document:**
```json
{
  "timestamp": "<Timestamp>",
  "eventType": "HARMFUL_GAS",
  "subBin": null,
  "fillLevel": null,
  "errorCode": null,
  "gasType": "methane",
  "gasLevel": 750
}
```

**MOISTURE_DETECTED event document:**
```json
{
  "timestamp": "<Timestamp>",
  "eventType": "MOISTURE_DETECTED",
  "subBin": "paper",
  "fillLevel": null,
  "errorCode": null,
  "moistureLevel": 85
}
```

---

## Example: Raspberry Pi Python Script

```python
import requests
import time

API_URL = "https://ingestbinevent-t4vkrtxd5q-uc.a.run.app"
BIN_ID = "BIN_001"

def send_event(payload: dict):
    try:
        r = requests.post(API_URL, json=payload, timeout=10)
        print(f"[{payload['eventType']}] → {r.status_code}: {r.json()}")
    except Exception as e:
        print(f"Error: {e}")

# Send fill level update
send_event({
    "binId": BIN_ID,
    "eventType": "LEVEL_UPDATE",
    "subBin": "plastic",
    "fillLevel": 67,
})

# Send piece collected
send_event({
    "binId": BIN_ID,
    "eventType": "PIECE_COLLECTED",
    "subBin": "paper",
})

# Send battery detection (safety alert)
send_event({
    "binId": BIN_ID,
    "eventType": "BATTERY_DETECTED",
    "subBin": "mixed",
})

# Send gas reading (safety alert if >= 500 PPM)
send_event({
    "binId": BIN_ID,
    "eventType": "HARMFUL_GAS",
    "gasType": "methane",
    "gasLevel": 820,
})

# Send moisture reading (safety alert if >= 70%)
send_event({
    "binId": BIN_ID,
    "eventType": "MOISTURE_DETECTED",
    "subBin": "organic",
    "moistureLevel": 75,
})
```
