# WoodCarvers — Native Setup Guide

Run these once after `flutter create .` has generated the `android/` and
`ios/` folders inside this project (or after copying this `lib/` folder into
a freshly created Flutter project).

## 1. Android

### 1a. ProGuard rules (Razorpay)
Copy `android_proguard_rules.pro` (in this bundle) into:
```
android/app/proguard-rules.pro
```
Then in `android/app/build.gradle`, inside `buildTypes { release { ... } }`,
make sure minification points at it:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 1b. Permissions — `android/app/src/main/AndroidManifest.xml`
Add inside `<manifest>`, above `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.CAMERA"/>
```
`INTERNET` is required for the API + Razorpay + Cloudinary. The media/camera
ones are for `image_picker` (review photos, product media, hero uploads).

### 1c. Minimum SDK
Razorpay requires `minSdkVersion 19+`; in practice set it to 21+ in
`android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 21
    ...
}
```

## 2. iOS

### 2a. Permissions — `ios/Runner/Info.plist`
Add these keys (image_picker needs both, even if you only use gallery pick):
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>WOOD CARVERS needs access to your photos to upload review images and product pictures.</string>
<key>NSCameraUsageDescription</key>
<string>WOOD CARVERS needs camera access to take photos for reviews and products.</string>
```

### 2b. Razorpay
No extra iOS config needed beyond `pod install` picking up
`razorpay_flutter`'s pod — run:
```bash
cd ios && pod install && cd ..
```

## 3. Firebase / Push Notifications (FCM)

The backend already sends pushes on payment confirmation and order status
changes (`sendPushToTokens` in `backend/src/utils/fcm.js`, using the legacy
FCM HTTP API + `FCM_SERVER_KEY` env var). The Flutter app registers its
device token against `POST /auth/fcm-token` once notifications are enabled
in Account → Notifications.

### 3a. Create a Firebase project
1. Go to https://console.firebase.google.com → Add project (or reuse an
   existing one).
2. Add an Android app: package name must match
   `android/app/build.gradle` → `applicationId` (default
   `com.example.woodcarvers_app` — change this to your real package name
   first, in both `build.gradle` and here).
3. Download `google-services.json` → place it at `android/app/google-services.json`.
4. Add an iOS app with your bundle ID → download `GoogleService-Info.plist`
   → add it to `ios/Runner/` via Xcode (drag into the Runner target so it's
   bundled).

### 3b. Android Gradle wiring
`android/build.gradle` (project-level), inside `dependencies`:
```gradle
classpath 'com.google.gms:google-services:4.4.2'
```
`android/app/build.gradle`, at the very bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 3c. iOS
No extra Podfile changes needed — `firebase_core`/`firebase_messaging`
bring their own pods. Just run `pod install` after adding the plist (step
3a.4) and enable **Push Notifications** + **Background Modes → Remote
notifications** capabilities in Xcode → Runner target → Signing & Capabilities.

### 3d. Backend server key
Set `FCM_SERVER_KEY` in the backend's `.env` (Firebase Console → Project
Settings → Cloud Messaging → **Cloud Messaging API (Legacy)** — enable it
if disabled, then copy the Server key). Without this the backend just logs
a `[FCM stub]` line instead of sending — the app will still run fine,
notifications just won't arrive.

### 3e. What happens if you skip this
`main.dart` wraps `Firebase.initializeApp()` in a try/catch — if the native
config files above are missing, it fails gracefully, push notifications are
simply disabled (Account → Notifications shows "not configured for this
build"), and the rest of the app works normally.

## 4. First run checklist

1. `flutter pub get`
2. Set `kBackendUrl` in `lib/data/providers/api_provider.dart` to your real
   backend URL (use `http://10.0.2.2:5000` for Android emulator → localhost).
3. Apply the Android/iOS changes in sections 1 and 2 above.
4. (Optional but recommended) Complete section 3 for push notifications.
5. `flutter run`

## 5. Known gaps (not yet built)
- No compile pass has been run against this code yet — expect a handful of
  small fixes (typos, minor API mismatches) on first `flutter run`.
