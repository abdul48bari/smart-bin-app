# Smart Bin App — Project Guide

## What This Is
IoT smart waste bin monitoring system. Flutter web app deployed on Vercel + Firebase backend.
The app is an **admin dashboard** that monitors physical smart bins, tracks fill levels, safety alerts, and waste analytics.

## Repo Structure
```
smart-bin-app/
├── mobile/          ← Flutter app (despite the name, this is the web dashboard)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/        ← bin_sub.dart, alert.dart, time_filter.dart
│   │   ├── pages/         ← home_page, bins_page, analytics_page, account_page, login_page
│   │   ├── providers/     ← app_state_provider.dart (central state hub)
│   │   ├── screens/       ← auth_wrapper.dart
│   │   ├── services/      ← firestore_service, simulation_service, notification_service, voice_assistant_service*
│   │   ├── utils/         ← app_colors.dart
│   │   └── widgets/       ← voice_assistant_modal.dart
│   └── build/web/         ← compiled output, deploy this folder to Vercel
├── functions/       ← Firebase Cloud Functions (Node.js) — IoT event ingestion
│   └── index.js
└── website/         ← Reclevo marketing website (Next.js 14, separate Vercel deployment)
```

## Tech Stack
- **Flutter** web/Android app (Dart)
- **Firebase Firestore** — real-time bin data, alerts, events
- **Firebase Auth** — email/password login
- **Firebase Cloud Messaging (FCM)** — push notifications to Android
- **Firebase Cloud Functions** — IoT event ingestion from Raspberry Pi
- **Vercel** — hosting for both the Flutter web app and marketing website
- **Web Speech API** — voice assistant (Chrome/Edge only)

## Key Architecture Decisions

### Demo Mode
- Entered via "Try Demo Mode" on login screen — no auth required
- `AppStateProvider.isDemoMode` / `isDemoEntry` flags control behavior
- `FirestoreService.isDemoMode` static flag — intercepted in all Firestore methods
- `SimulationService` drives bin data in demo (7 simulated bins, updates every 3s)
- Safety alerts simulated in-memory via `SimulationService._simulatedSafetyAlerts`
- **CRITICAL**: `isDemoEntry = true` means unauthenticated — never allow Firestore access while true
- Exiting demo mode (toggle off or logout) calls `exitDemoMode()` which routes back to login

### State / Streams
- All bin streams route through `AppStateProvider.binsStream` and `binStatusStream(binId)`
- This transparently switches between SimulationService (demo) and Firestore (real) streams
- `StreamController.broadcast()` does NOT replay last value — use `async* { yield _lastEmitted!; yield* _controller.stream; }` pattern
- `Stream.periodic` doesn't emit at t=0 — use `async* { yield 0; yield* Stream.periodic(...) }`

### Demo Data (static, in code)
- **Bins**: DIN_HALL_01 (62%), LIB_L1_02 (45%), DORM_A_03 (78%), PARK_N_04 (33%), LAB_SCI_05 (88%), CAFE_B_06 (54%), GYM_FL_07 (21%)
- **Sub-bins per bin**: Each bin has plastic/paper/organic/cans/mixed at varied fill levels (see `_demoSubBins` in voice_assistant_service_web.dart and `_demoPieceCounts`/`_demoFullCounts` in firestore_service.dart)
- **Analytics**: Piece counts and full-counts per day/week/month in FirestoreService static maps

## Firestore Schema
```
bins/{binId}
  ├── name, location, status (online/offline/maintenance), fillLevel
  ├── subBins/{subBinId}       ← plastic, paper, organic, cans, mixed
  │     currentFillPercent, isFull
  ├── alerts/{alertId}
  │     alertType (BATTERY_DETECTED | HARMFUL_GAS | MOISTURE_DETECTED | HARDWARE_ERROR | BIN_FULL)
  │     message, severity (warning | error), subBin, createdAt, isResolved, resolvedAt
  │     gasType?, gasLevel?, moistureLevel?
  └── events/{eventId}
        eventType (BIN_FULL | PIECE_COLLECTED | LEVEL_UPDATE | BIN_EMPTIED | HARDWARE_ERROR |
                   BATTERY_DETECTED | HARMFUL_GAS | MOISTURE_DETECTED), subBin, timestamp

_rateLimits/{binId}            ← Cloud Function rate limiting (auto-created, max 60 req/min per bin)
  └── count, windowStartMs
```

## Push Notifications (Android)
- `services/notification_service.dart` — initializes FCM + local notifications
- Called via `NotificationService.initialize()` in `main.dart` (skipped on web via `kIsWeb`)
- All devices subscribe to `bin_alerts` FCM topic on startup
- Two Android notification channels: `safety_alerts` (max importance) and `bin_alerts` (high importance)
- Cloud Functions send FCM to the topic on every alert creation
- **Safety alerts** (BATTERY_DETECTED, HARMFUL_GAS, MOISTURE_DETECTED, HARDWARE_ERROR) → `safety_alerts` channel with vibration
- **BIN_FULL** → `bin_alerts` channel
- Requires `firebase_messaging: ^16.1.0` (v15.x incompatible with cloud_firestore ^6.x)
- Requires `flutter_local_notifications: ^18.0.1` + `isCoreLibraryDesugaringEnabled = true` in build.gradle.kts

## Cloud Functions (`functions/index.js`)
Two HTTP endpoints called by the Raspberry Pi:

### POST `/ingestBinEvent`
Handles all hardware events. Validates input, rate-limits per binId (60 req/min), creates alerts and sends FCM.

**Valid eventTypes**: `LEVEL_UPDATE`, `BIN_FULL`, `BIN_EMPTIED`, `PIECE_COLLECTED`, `HARDWARE_ERROR`, `BATTERY_DETECTED`, `HARMFUL_GAS`, `MOISTURE_DETECTED`

**Valid subBins**: `plastic`, `paper`, `organic`, `cans`, `mixed`

**binId format**: `^[A-Za-z0-9_-]{1,64}$`

Alert thresholds: HARMFUL_GAS only alerts if gasLevel >= 500 PPM; MOISTURE_DETECTED only alerts if moistureLevel >= 70

### POST `/resolveAlert`
Manually resolves a safety alert. Payload: `{ binId, alertId }`. Only resolves safety types — BIN_FULL is auto-resolved by BIN_EMPTIED.

**Deploy**: `firebase deploy --only functions --project smart-bin-app-uowd`

## Voice Assistant

### Files
- `services/voice_assistant_service_web.dart` — web implementation (dart:html SpeechRecognition)
- `services/voice_assistant_service.dart` — mobile stub/implementation
- `services/voice_assistant_service_stub.dart` — conditional export (web vs mobile)
- `widgets/voice_assistant_modal.dart` — UI modal

### Capabilities
| Command Type | Examples |
|---|---|
| Sub-bin fill level | "fill level of plastic in bin 2", "how full is organic in dining hall" |
| All bins fill level | "fill levels of all bins", "how full are the bins" |
| Specific bin fill | "fill level of bin 3", "how full is the library bin" |
| Most full bin | "which bin is most full", "fullest bin" |
| Bins needing emptying | "which bins need emptying", "urgent bins", "collect" |
| System status | "system status", "how many bins are online" |
| System health | "system health", "health score" |
| Safety alerts | "any safety alerts", "battery alerts", "harmful gas", "moisture" |
| General alerts | "any alerts", "warnings", "issues" |
| Analytics | "items collected this week", "most common waste today", "stats this month" |
| Help | "help", "what can you do" |

### Browser Compatibility
- Works in Chrome and Edge only (Web Speech API)
- Brave Browser blocks mic by default — users must enable in Brave's shield settings
- `__MIC_BLOCKED__` token signals blocked mic (detected via elapsed < 800ms on end event)
- `__NO_SPEECH__` token signals silence timeout
- `__NOT_SUPPORTED__` token signals unsupported browser

### Word Normalization
`_normalizeText()` corrects common speech-to-text misrecognitions:
- bin/bins ← been, ben, pin, bun, bing, beans
- fill ← feel, fin, file, field, phil, fell, film
- status ← stadium, stattus
- safety ← saftey, safty
- cans ← chance, kanz, kans
- battery ← batter
- moisture ← moister
- gas ← gass
- organic ← orgenik
- plastic ← plastik, plastick
- paper ← papper
- mixed ← mix, mixes

## Marketing Website (`website/`)
Next.js 14 + TypeScript + Tailwind. Separate Vercel deployment.

**Key components:**
- `Hero.tsx` — Aurora WebGL background, DecryptedText animation, Spline 3D model
- `Features.tsx`, `TechStack.tsx` — SpotlightCard mouse-tracking effect
- `AppPreview.tsx` — Particles WebGL background
- `About.tsx` — BlurText word-by-word animation

**ReactBits components** (in `src/components/`): `Aurora.tsx`, `Particles.tsx` (both use OGL/WebGL), `DecryptedText.tsx`, `BlurText.tsx` (Framer Motion), `SpotlightCard.tsx`

**CSP in `next.config.js`**: Must include `https://*.spline.design` in `connect-src` and `img-src` — Spline fetches its scene file externally. Missing this causes "Application error: client-side exception".

**Deploy**: from `website/` run `vercel --prod`

**Live URL**: https://reclevo.vercel.app (or linked domain)

## Deployment

### Flutter Web App
```bash
# From mobile/ directory:
flutter build web --no-tree-shake-icons

# From mobile/build/web/ directory:
vercel --prod
```
Live URL: https://smart-bin-app-eta.vercel.app

### Marketing Website
```bash
# From website/ directory:
vercel --prod
```

### Cloud Functions
```bash
# From functions/ directory:
firebase deploy --only functions --project smart-bin-app-uowd
```

## Common Gotchas
- Do NOT commit `mobile/build/` directory (it's large and regenerated)
- Do NOT commit auto-generated Flutter plugin files (`linux/flutter/generated_*`, `windows/flutter/generated_*`, `android/build/`) — they change on every `flutter pub get`
- Wasm warnings from flutter_tts package are expected — they don't block the build
- `FirestoreService` uses a singleton pattern — `isDemoMode` is static so it affects all instances
- The `_pieceCountController` timer in FirestoreService must be guarded with `if (isDemoMode) return;` or it keeps polling Firestore after demo entry
- `resolveAlert()` writes both `resolved: true` AND `isResolved: true` (schema has both fields)
- `withOpacity()` is deprecated in Flutter — use `withValues(alpha: x)` instead
- CSP in `next.config.js`: always include `https://*.spline.design` in `connect-src` or the 3D model will fail to load and crash the page
- `firebase_messaging ^16.1.0` required — v15.x conflicts with cloud_firestore ^6.x on `firebase_core_platform_interface`

## Git Conventions
- Short, lowercase commit messages (`feat:`, `fix:`, `refactor:`)
- No co-author lines, no "Co-Authored-By" or any Claude contribution lines
- Never mention Claude in commit messages
- Main branch is `main`
