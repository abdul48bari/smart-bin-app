<div align="center">

# Reclevo — Smart Bin Management System

**An IoT-powered smart waste bin monitoring and management platform**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Next.js](https://img.shields.io/badge/Next.js-14-000000?logo=next.js&logoColor=white)](https://nextjs.org)
[![Vercel](https://img.shields.io/badge/Deployed%20on-Vercel-000000?logo=vercel&logoColor=white)](https://vercel.com)

<br/>

### [Live Web App](https://smart-bin-app-eta.vercel.app) &nbsp;·&nbsp; [Marketing Website](https://reclevo-website-azure.vercel.app) &nbsp;·&nbsp; [Download APK](./Reclevo.apk)

</div>

---

## Table of Contents

- [Overview](#overview)
- [Live Links](#live-links)
- [App Features](#app-features)
- [Tech Stack](#tech-stack)
- [Hardware Stack](#hardware-stack)
- [System Architecture](#system-architecture)
- [Marketing Website](#marketing-website)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Deployment](#deployment)
- [Team](#team)

---

## Overview

Reclevo is a full-stack IoT smart waste bin monitoring system designed for university and campus environments. Physical smart bins equipped with sensors transmit real-time data to a Firebase backend, which is visualised through a Flutter admin dashboard accessible on both web and Android.

The system monitors fill levels across **five waste categories** (Plastic, Paper, Organic, Cans, Mixed), detects safety hazards such as harmful gas, moisture, and hardware errors, and provides UAE-specific recycling guidance aligned with the **UAE Circular Economy Policy 2021–2031** and the **UN Sustainable Development Goals**.

The project is composed of three components:

| Component | Description |
|---|---|
| **Flutter Admin Dashboard** | Web app + Android APK for real-time bin monitoring and management |
| **Marketing Website** | Next.js 14 landing page presenting the product and technology |
| **Firebase Cloud Functions** | Node.js backend receiving and processing hardware events from the Raspberry Pi |

---

## Live Links

| | URL |
|---|---|
| **Admin Dashboard (Web)** | https://smart-bin-app-eta.vercel.app |
| **Marketing Website** | https://reclevo-website-azure.vercel.app |
| **Android APK** | [`Reclevo.apk`](./Reclevo.apk) — download and install directly |

> **Try it instantly:** Click "Try Demo Mode" on the login screen — no account needed. The demo simulates 7 live bins with real-time data, charts, alerts, voice assistant, and all features fully enabled.
>
> **Browser note:** The voice assistant requires **Chrome or Edge** (Web Speech API).

---

## App Features

### Home Tab — Dashboard Overview
- Real-time system-wide overview of all registered bins
- Cross-bin **safety alert banner** with live unresolved alert count — tappable to drill into details
- Bin status summary cards (online / offline counts, fill levels)
- Shimmer skeleton loading for smooth data-fetching experience
- Fully theme-aware (dark and light mode)

### Bins Tab — Live Bin Monitoring
- Complete list of all registered smart bins, **naturally sorted** by name (bin-001 → bin-002 → bin-010)
- System health score card (online / offline / maintenance counts)
- Per-bin cards showing live status badge and unresolved alert count
- Tap any bin card to open its full **alert history screen**
- Long-press a bin to change its status (online / offline / maintenance)

### Analytics Tab — Waste Data Insights
- **Time filter toggle**: Day / Week / Month
- **Piece count chart** — horizontal bar chart showing waste items collected per category across all bins
- **Full-count chart** — vertical bar chart showing how many times each sub-bin was completely filled
- Per-bin breakdown section with individual bin analytics
- Sub-bin colour coding consistent across all charts:

  | Category | Colour |
  |---|---|
  | Plastic | Blue |
  | Paper | Green |
  | Organic | Brown |
  | Cans | Amber |
  | Mixed | Purple |

### Tips Tab — Recycling Guidance
- Live recycling tips **driven by real fill-level data** — only bins above 20% fill appear
- One tip card per waste type (up to 5 cards: Plastic, Paper, Organic, Cans, Mixed)
- Each card shows bin name, location, current fill level, and 3 actionable recycling tips
- Tips are **UAE-specific** and referenced against:
  - UAE Circular Economy Policy 2021–2031
  - COP28 UAE climate commitments
  - UN SDGs 2, 11, 12, 13, and 15
- Pull-to-refresh rotates to a new tip set (3 sets per waste type, cycling on each refresh)
- **Save and dismiss** individual tip cards — preferences persisted across sessions via SharedPreferences

### Account Tab — Settings & Bin Management
**Bin Management** (fully live):
- **Add New Bin** — register a new bin with a validated ID, name, location, and status. Duplicate IDs are detected and rejected immediately
- **Remove Bin** — select from a live sorted list, confirm deletion, and the bin along with all its sub-bin data is batch-removed from Firestore
- **Edit Bin Details** — select any bin, update its name, location, or status through a pre-filled form

**App Settings:**
- Dark / Light Mode toggle with persistent preference
- Demo Mode toggle — switch between simulated and live Firestore data at any time
- Notifications, Language, Export Data settings (roadmap)

**Security (roadmap):** Change Password, Change Email, 2FA, Trusted Devices, Activity Log, API Keys

### Voice Assistant
- Activated by the **microphone FAB** (floating button, bottom-right of every screen)
- Understands natural language queries in English
- Supported commands:

  | Category | Example |
  |---|---|
  | Sub-bin fill level | *"How full is the plastic bin in the dining hall?"* |
  | All bins status | *"How full are all the bins?"* |
  | Bins needing collection | *"Which bins need emptying?"* |
  | System health | *"What is the system health score?"* |
  | Safety alerts | *"Are there any harmful gas alerts?"* |
  | Analytics | *"How many items were collected this week?"* |
  | Help | *"What can you do?"* |

- Built on the **Web Speech API** — requires Chrome or Edge
- Includes speech-to-text normalisation to handle common misrecognitions

### Safety Alert System
Alerts are automatically created by Cloud Functions when sensors report:

| Alert Type | Trigger |
|---|---|
| **Harmful Gas** | MQ-series sensor reading >= 500 PPM |
| **Moisture / Liquid** | Moisture level >= 70% |
| **Battery Leak** | Battery detection event received |
| **Hardware Error** | Sensor or device malfunction |
| **Bin Full** | Sub-bin fill level reaches 100% |

- Alerts pushed to Android via **Firebase Cloud Messaging (FCM)**
- Unresolved safety alerts shown prominently on the Home tab
- Alerts can be manually resolved from the bin's alert history screen
- BIN_FULL alerts auto-resolve when a BIN_EMPTIED event is received

### Authentication & Access
- Email / password login via Firebase Auth
- **Demo Mode** for unauthenticated exploration — full functionality without credentials
- Animated splash screen on launch
- Secure routing — unauthenticated users redirected to login automatically

---

## Tech Stack

### Mobile & Web App

| Technology | Purpose |
|---|---|
| **Flutter** (Dart) | Cross-platform framework — compiled to web (Vercel) and Android APK |
| **Firebase Firestore** | Real-time NoSQL database for bins, sub-bins, alerts, and events |
| **Firebase Auth** | Secure email/password authentication |
| **Firebase Cloud Messaging** | Push notifications to Android devices |
| **Web Speech API** | Browser-native voice recognition for the voice assistant |
| **Provider** | Lightweight state management (ThemeProvider, AppStateProvider) |
| **SharedPreferences** | Local persistence for theme preference and tip card save/dismiss state |

### Backend

| Technology | Purpose |
|---|---|
| **Firebase Cloud Functions** (Node.js) | HTTP endpoints for Raspberry Pi event ingestion and alert resolution |
| **Firestore Security Rules** | Data access control and validation |

### Marketing Website

| Technology | Purpose |
|---|---|
| **Next.js 14** | React framework — SSR, routing, optimised builds |
| **TypeScript** | Type-safe component development |
| **Tailwind CSS** | Utility-first styling |
| **Framer Motion** | Page entrance and scroll animations |
| **OGL / WebGL** | Aurora and particle background effects |
| **Simple Icons** | Official SVG brand icons (Firebase, Flutter, TensorFlow, Next.js, etc.) |
| **Spline** | Interactive 3D smart bin model in the hero section |

### AI / Machine Learning

| Technology | Purpose |
|---|---|
| **TensorFlow** | On-device waste image classification |
| **MobileNetV2** | Lightweight CNN architecture running on Raspberry Pi camera feed |

---

## Hardware Stack

| Component | Role |
|---|---|
| **Raspberry Pi 5** | Main controller — runs Python, communicates with all sensors, sends HTTP events to Cloud Functions via Wi-Fi |
| **Ultrasonic Sensor (HC-SR04)** | Measures bin fill level by calculating distance to waste surface |
| **Gas Sensor (MQ-series)** | Detects harmful gases — triggers alert when reading >= 500 PPM |
| **Moisture Detector (LM393)** | Detects liquid or moisture inside the bin — triggers alert at >= 70% |
| **Camera Module** | Captures waste images for AI-based waste category classification |
| **PWM DC Motor** | Controls bin lid opening and compaction mechanism |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Physical Smart Bin                      │
│                                                             │
│  Ultrasonic  Gas Sensor  Moisture  Camera      PWM Motor   │
│  Sensor (HC-SR04) (MQ)  Detector  (TF/MobileNetV2)        │
│        └──────────┴──────────┴──────────┘                  │
│                        │                                    │
│                   Raspberry Pi 5                            │
│              (Python controller script)                     │
└───────────────────────┬─────────────────────────────────────┘
                        │  HTTP POST (Wi-Fi)
                        ▼
          ┌─────────────────────────┐
          │  Firebase Cloud         │
          │  Functions (Node.js)    │
          │  /ingestBinEvent        │
          │  /resolveAlert          │
          │  Rate limit: 60 req/min │
          └────────────┬────────────┘
                       │
          ┌────────────▼────────────┐
          │  Firebase Firestore     │
          │  bins/{binId}           │
          │    subBins/             │
          │    alerts/              │
          │    events/              │
          └────────────┬────────────┘
                       │
          ┌────────────┴──────────────────────┐
          │                                   │
          ▼                                   ▼
 Flutter Web Dashboard               FCM Push Notification
 (real-time Firestore streams)       → Android App
```

---

## Marketing Website

The marketing website is a separate **Next.js 14** application, deployed independently on Vercel.

**Visit:** https://reclevo-website-azure.vercel.app

The website presents Reclevo as a product with the following sections:

- **Hero** — animated headline with a letter-scramble effect and an interactive 3D smart bin model
- **About** — product story with a word-by-word blur animation
- **How It Works** — step-by-step overview of the bin-to-dashboard flow
- **Features** — interactive cards with a mouse-tracking spotlight effect
- **Tech Stack** — visual overview of all technologies used
- **System Architecture** — interactive hardware/software stack diagram with animated connection indicators and custom schematic SVG drawings for each hardware component
- **App Preview** — screenshots of the Flutter dashboard with a WebGL particle background
- **Team** — team member cards

---

## Project Structure

```
smart-bin-app/
├── mobile/                        ← Flutter app (web + Android)
│   ├── lib/
│   │   ├── main.dart              ← Entry point, Firebase init, providers
│   │   ├── models/                ← BinSub, AlertModel, TimeFilter
│   │   ├── pages/                 ← home, bins, analytics, suggestions, account, login
│   │   ├── providers/             ← AppStateProvider, ThemeProvider
│   │   ├── screens/               ← SplashScreen, AuthWrapper, MainAppScreen, AlertsScreen
│   │   ├── services/              ← FirestoreService, SimulationService, VoiceAssistant,
│   │   │                              AuthService, NotificationService
│   │   ├── utils/                 ← AppColors (theme-aware), AppShadows
│   │   └── widgets/               ← GlassContainer, CleanContainer, charts,
│   │                                  ShimmerLoading, VoiceAssistantModal
│   └── build/web/                 ← Compiled web output (deployed to Vercel, not committed)
│
├── functions/
│   └── index.js                   ← Cloud Functions: /ingestBinEvent, /resolveAlert
│
├── website/                       ← Next.js marketing website
│   └── src/
│       ├── app/page.tsx           ← Page composition
│       └── components/            ← All 20 website components
│
├── Reclevo.apk                    ← Latest Android build
├── CLAUDE.md                      ← Full developer reference guide
└── README.md                      ← This file
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Node.js 18+
- Firebase CLI (`npm install -g firebase-tools`)
- A Firebase project with Firestore, Authentication, and Cloud Functions enabled

### Run the Flutter App
```bash
cd mobile
flutter pub get
flutter run -d chrome          # Web (voice assistant works here)
flutter run                    # Android device or emulator
```

### Run the Marketing Website
```bash
cd website
npm install
npm run dev
# Open http://localhost:3000
```

### Run Cloud Functions locally
```bash
cd functions
npm install
firebase emulators:start
```

---

## Deployment

### Flutter Web App
```bash
cd mobile
flutter build web --no-tree-shake-icons
cd build/web
vercel --prod
```

### Marketing Website
```bash
cd website
vercel --prod
```

### Cloud Functions
```bash
cd functions
firebase deploy --only functions --project smart-bin-app-uowd
```

---

## Team

| Name | Contribution |
|---|---|
| **Umar** | Mobile application UI design and logic |
| **Asim** | Backend API, Firestore architecture, and Cloud Functions |
| **Amer** | System architecture design and review |

---

## Acknowledgements

- [UAE Circular Economy Policy 2021–2031](https://u.ae/en/about-the-uae/strategies-initiatives-and-awards/strategies-plans-and-visions/environment-and-energy/circular-economy-policy) — sustainability targets referenced in the Tips tab
- [COP28 UAE](https://www.cop28.com) — climate commitments referenced in recycling guidance
- [UN Sustainable Development Goals](https://sdgs.un.org/goals) — SDGs 2, 11, 12, 13, 15 referenced in tip content
- [Emirates Environmental Group (EEG)](https://www.eeg.ae) — UAE-specific collection drive information

---

<div align="center">

**Reclevo** — Built for a cleaner, smarter campus.

</div>
