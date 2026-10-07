# Google OAuth 2.0 Setup Guide

## ปัญหาที่พบ

```
Assertion failed: file:///C:/Users/ctarv/AppData/Local/Pub/Cache/hosted/pub.dev/google_sign_in_web-0.12.4+4/lib/google_sign_in_web.dart:144:9
appClientId != null
'ClientID not set. Either set it on a <meta name=\'google-signin-client_id\' content=\'CLIENT_ID\' /> tag, or pass clientId when initializing GoogleSignIn'
```

**สาเหตุ:** Google Sign-In บน Web platform ต้องการ OAuth Client ID แบบ **Web Application** และต้องกำหนดใน `web/index.html`

---

## ขั้นตอนการแก้ไข

### 1. สร้าง OAuth 2.0 Client ID สำหรับ Web

1. เปิด [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)
2. เลือก Project ของคุณ (หรือสร้างใหม่)
3. ไปที่ **APIs & Services** → **Credentials**
4. คลิก **+ CREATE CREDENTIALS** → **OAuth client ID**
5. ตั้งค่าดังนี้:

   - **Application type:** `Web application`
   - **Name:** `Yharbid Web Client`
   - **Authorized JavaScript origins:**
     ```
     http://localhost
     http://localhost:8080
     ```
   - **Authorized redirect URIs:**
     ```
     http://localhost:8080
     http://localhost:8080/
     ```

6. คลิก **CREATE**
7. **คัดลอก Client ID** (รูปแบบ: `123456789-abcdefg.apps.googleusercontent.com`)

---

### 2. อัพเดท `web/index.html`

เปิดไฟล์ `web/index.html` และแทนที่:

```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

ด้วย Client ID ที่คัดลอกมา:

```html
<meta name="google-signin-client_id" content="123456789-abcdefg.apps.googleusercontent.com">
```

---

### 3. (Optional) Enable Google Sign-In API

1. ไปที่ [Google Cloud Console - APIs & Services - Library](https://console.cloud.google.com/apis/library)
2. ค้นหา **"Google Sign-In"** หรือ **"Google+ API"**
3. คลิก **ENABLE**

---

### 4. ทดสอบ

```bash
flutter run -d chrome
```

หรือ

```bash
flutter run -d edge
```

---

## ความแตกต่างระหว่าง Desktop และ Web OAuth

| Platform | Application Type | ใช้ใน Code | ตั้งค่าที่ |
|----------|------------------|-----------|-----------|
| **Desktop** (Windows/macOS/Linux) | Desktop Application | `.env` → `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` | ไม่ต้องใส่ใน HTML |
| **Web** (Chrome/Edge/Firefox) | Web Application | `web/index.html` meta tag | **ต้องใส่ใน HTML** |
| **Mobile** (Android/iOS) | Android/iOS App | `google-services.json` / `GoogleService-Info.plist` | Firebase Config |

**สำคัญ:** Desktop Client ID และ Web Client ID **ต้องแยกกัน** และไม่สามารถใช้ร่วมกันได้!

---

## Configuration Files Summary

```
d:/project/
├── .env                          # Desktop OAuth (GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET)
├── web/
│   └── index.html               # Web OAuth (meta tag)
├── android/
│   └── app/google-services.json # Android Firebase + OAuth
└── ios/
    └── Runner/GoogleService-Info.plist # iOS Firebase + OAuth
```

---

## Troubleshooting

### Error: `appClientId != null`
**สาเหตุ:** ไม่ได้ใส่ Client ID ใน `web/index.html`
**วิธีแก้:** ตรวจสอบขั้นตอนที่ 2 ด้านบน

### Error: `unauthorized_client`
**สาเหตุ:** URL ใน Authorized JavaScript origins ไม่ตรงกับที่ run
**วิธีแก้:** เพิ่ม `http://localhost:port` ใน Google Cloud Console

### Error: `redirect_uri_mismatch`
**สาเหตุ:** Redirect URI ไม่ตรงกับที่ตั้งค่าไว้
**วิธีแก้:** เพิ่ม redirect URI ที่แสดงใน error message ลงใน Google Cloud Console

---

## หมายเหตุสำคัญ

⚠️ **อย่า commit Web Client ID ลงใน `.env`** เพราะ Web Client ID สามารถเปิดเผยได้ (เป็น public)
✅ **Desktop Client Secret ต้องเก็บเป็นความลับ** (อยู่ใน `.env` และ `.gitignore`)
