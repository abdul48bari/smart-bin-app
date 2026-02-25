## Smart Bin Mobile Application

This repository contains the mobile application and backend services for a Smart Garbage Bin System. The system is designed to monitor, manage, and analyze waste collection in real time.

The smart bin supports waste segregation into the following categories:
- Organic
<<<<<<< HEAD
- Paper
=======
- Paper (changed from glass to paper after further discussion on real life scenario's in targeted environment)
>>>>>>> e15444e (Change waste segregation category from Glass to Paper)
- Plastic
- Cans
- Mixed / General

---

## Live Demo

The application is deployed as a web build and can be accessed here:

https://smart-bin-app-eta.vercel.app

This web version is used for testing and demonstration.

---

## Tech Stack

Frontend:
- Flutter (mobile-first, web supported)

Backend and Cloud:
- Firebase Firestore for real-time data storage
- Firebase Cloud Functions for API endpoints
- Firebase Cloud Messaging for notifications (planned)

---

## Current Features

Home Page:
- System-wide overview of all bins
- Live status indicators
- Alerts preview
- Summary and insight widgets
- Clean and modern dashboard design

Bins Page:
- List of all registered bins
- Online and offline status per bin
- Expandable bin cards
- Live sub-bin fill levels
- Per-bin alerts preview
- Navigation to detailed alerts page

Analytics Page:
- Event-based analytics
- Bar charts based on historical bin data
- Time-based filtering support

Alerts System:
- Alerts for full bins and hardware errors
- Automatic resolution when bins are emptied
- Expandable alert details
- Alert history per bin

Account Page:
- User profile overview
- App system settings (Dark Mode, Demo Mode)
- Security and privacy controls
- Quick access to bin management

Login & Authentication:
- Secure email/password login flow
- Smooth entry animations
- Admin access control

Backend API:
- Central ingestion endpoint for bin events
- Supports level updates, bin full, bin emptied, and hardware errors
- Maintains live bin state, alerts, and analytics data

---

## Hardware Integration

The following components are planned for future integration:
- Raspberry Pi controller
- Fill-level sensors
- Camera-based waste classification
- Wi-Fi based API communication

---

## Project Status

Prototype in active development.

Core application structure, UI, and backend logic are complete. Hardware integration is pending.

---

## Contributors

- Designed and reviewed system architecture - @amer
- Developed mobile application UI and logic - @Umar
- Implemented backend API and database structure - @Asim