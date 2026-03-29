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
│   │   ├── services/      ← firestore_service, simulation_service, voice_assistant_service*
│   │   ├── utils/         ← app_colors.dart
│   │   └── widgets/       ← voice_assistant_modal.dart
│   └── build/web/         ← compiled output, deploy this folder to Vercel
└── [website folder]       ← Reclevo marketing website (separate)
```

## Tech Stack
- **Flutter** web app (Dart)
- **Firebase Firestore** — real-time bin data, alerts, events
- **Firebase Auth** — email/password login
- **Vercel** — hosting (deploy from `mobile/build/web/`)
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
  │     alertType (BATTERY_DETECTED | HARMFUL_GAS | MOISTURE_DETECTED | HARDWARE_ERROR)
  │     message, severity (warning | error), subBin, createdAt, isResolved, resolvedAt
  │     gasType?, gasLevel?, moistureLevel?
  └── events/{eventId}
        eventType (BIN_FULL | PIECE_COLLECTED), subBin, timestamp
```

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

## Deployment
```bash
# From mobile/ directory:
flutter build web --no-tree-shake-icons

# From mobile/build/web/ directory:
vercel --prod
```
Live URL: https://smart-bin-app-eta.vercel.app

## Common Gotchas
- Do NOT commit `mobile/build/` directory (it's large and regenerated)
- Wasm warnings from flutter_tts package are expected — they don't block the build
- `FirestoreService` uses a singleton pattern — `isDemoMode` is static so it affects all instances
- The `_pieceCountController` timer in FirestoreService must be guarded with `if (isDemoMode) return;` or it keeps polling Firestore after demo entry
- `resolveAlert()` writes both `resolved: true` AND `isResolved: true` (schema has both fields)

## Git Conventions
- Short, lowercase commit messages (`feat:`, `fix:`, `refactor:`)
- No co-author lines
- Main branch is `main`
