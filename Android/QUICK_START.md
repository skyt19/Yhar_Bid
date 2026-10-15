# 🚀 Yharbid Android - Quick Start Guide

## ⚠️ CRITICAL: Android SDK Required

**Before proceeding**, you MUST have Android SDK installed.

### Check if Android SDK is installed:
```bash
flutter doctor -v
```

**If you see** ❌ **Android toolchain** or **"Android SDK at C:\"**:
👉 **READ `ANDROID_SDK_SETUP.md` FIRST** - Complete Android SDK installation

---

## ⚡ Fast Track (4 Steps)

### 0️⃣ Install Android SDK ⚠️ REQUIRED
**If not installed yet**:
- **Option 1 (Recommended)**: Install Android Studio
- **Option 2**: Install Command Line Tools only

**Full instructions**: See `ANDROID_SDK_SETUP.md`

### 1️⃣ Add Firebase Configuration
```bash
# Download google-services.json from Firebase Console
# Place it at: android/app/google-services.json
```
See detailed instructions: `android/app/README_FIREBASE.md`

### 2️⃣ Set Java Environment
```powershell
$env:JAVA_HOME='C:\Program Files\Java\jdk-23'
```

### 3️⃣ Build & Run
```bash
# Option A: Use build script (Recommended)
.\build.ps1 debug

# Option B: Manual build
flutter pub get
flutter build apk --debug
flutter install
```

---

## 📋 What Was Migrated from Web?

✅ **All Features & Code**
- Complete `lib/` directory (Controllers, Views, Services, Models)
- All `assets/` (Images, Mockups, Icons, Fonts)
- Environment configuration (`.env`)
- All dependencies from `pubspec.yaml`

✅ **Platform Adaptations**
- Removed web-only `dart:js_util` imports
- Fixed `auth_service.dart` for mobile platform
- Updated Android permissions & manifest
- Added Firebase Gradle plugins

✅ **Code Quality**
- 0 errors in static analysis
- 122 warnings (safe to ignore - mostly lints)

---

## 🎯 6 Must-Have Features (All Implemented)

1. **FR-1: Role Selection & AI Personality** ✅
   - Login → Role (Student/Employee/Educator) → AI Tone

2. **FR-2: Google Calendar Sync** ✅
   - OAuth flow + TableCalendar widget

3. **FR-3: Proactive Task Preparation** ✅
   - AI generates role-based outlines 3 days ahead

4. **FR-4: Habit Tracking** ✅
   - Add/Complete/Delete tasks & habits

5. **FR-5: Customized Notifications** ✅
   - AI personality slider (Polite/Friendly/Aggressive)

6. **FR-6: Analytics Dashboard** ✅
   - Habit Success Rate + Calendar Compliance Rate

---

## 🔧 System Requirements

- **Flutter**: 3.47.6 (installed ✅)
- **Dart SDK**: >=3.10.0 (installed ✅)
- **Java**: JDK 17+ (JDK 23 installed ✅)
- **Android SDK**: Required for device deployment
- **Firebase**: `google-services.json` needed ⚠️

---

## 📂 Key Files & Locations

```
D:\project\Android\
├── build.ps1                   # Build script (use this!)
├── MIGRATION_GUIDE.md          # Full migration documentation
├── QUICK_START.md              # This file
├── android/
│   └── app/
│       ├── google-services.json    ⚠️ REQUIRED (add this)
│       └── README_FIREBASE.md      # Firebase setup guide
├── lib/                        # All app code
├── assets/                     # All images & fonts
└── .env                        # Environment variables
```

---

## 🐛 Troubleshooting

### Problem: "Gradle requires JVM 17 or later"
**Solution:**
```powershell
$env:JAVA_HOME='C:\Program Files\Java\jdk-23'
.\build.ps1 debug
```

### Problem: "google-services.json is missing"
**Solution:** See `android/app/README_FIREBASE.md`

### Problem: Google Sign-In fails
**Solution:** Add SHA-1 fingerprint to Firebase Console:
```bash
cd android
.\gradlew signingReport
```

---

## 📱 Test on Device

### List connected devices:
```bash
flutter devices
```

### Install APK:
```bash
flutter install
# OR
adb install build\app\outputs\flutter-apk\app-debug.apk
```

### View logs:
```bash
flutter logs
```

---

## ✅ Pre-Demo Checklist

- [ ] `google-services.json` added
- [ ] APK builds successfully
- [ ] App installs on test device
- [ ] Google Sign-In works
- [ ] Calendar sync works
- [ ] All 6 Must-Have FRs tested

---

## 📞 Need Help?

**Full Documentation:** `MIGRATION_GUIDE.md`  
**Firebase Setup:** `android/app/README_FIREBASE.md`  
**SRS Specification:** `D:\project\WebApp\SRS.md`

---

**Migration Date:** 2026-10-12  
**Status:** ✅ Ready for Testing  
**Platform:** Android Native (Flutter)
