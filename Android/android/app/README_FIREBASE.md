# ⚠️ Firebase Configuration Required

## Missing File: `google-services.json`

This file is required for Firebase integration on Android.

---

## 📥 How to Get `google-services.json`

### Step 1: Go to Firebase Console
Visit: https://console.firebase.google.com/

### Step 2: Select Your Project
Select the **Yharbid** project

### Step 3: Add Android App (if not exists)
1. Click **⚙️ Project Settings**
2. Scroll to **Your apps** section
3. Click **Add app** → Select **Android** icon
4. Enter package name: `com.yharbid.app`
5. Click **Register app**

### Step 4: Download Configuration File
1. Download `google-services.json`
2. Place it in this directory: `android/app/google-services.json`

### Step 5: Configure Firebase Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Google** provider
3. Add your **SHA-1** certificate fingerprint:
   ```bash
   cd android
   .\gradlew signingReport
   ```
   Copy the **SHA-1** from the output and paste it in Firebase Console

---

## 📂 Correct File Location

```
D:\project\Android\
└── android\
    └── app\
        └── google-services.json  ← Place file here
```

---

## ✅ Verification

After adding the file, run:
```bash
flutter pub get
flutter build apk --debug
```

---

## 🔒 Security Note

**NEVER commit `google-services.json` to public repositories!**

It's already added to `.gitignore` for safety.

---

## 📞 Need Help?

If you cannot access Firebase Console, contact:
- Project Admin
- Firebase Project Owner
- Development Team Lead
