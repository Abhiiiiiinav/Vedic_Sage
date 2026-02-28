# Android Build Fix

## Issue
```
Error: uses-sdk:minSdkVersion 21 cannot be smaller than version 23 declared in library [com.google.firebase:firebase-auth:23.2.1]
```

## Solution
Updated `android/app/build.gradle.kts` to set `minSdk = 23` (was 21).

Firebase requires minimum Android SDK version 23 (Android 6.0 Marshmallow).

## What Changed
```kotlin
// Before
minSdk = flutter.minSdkVersion  // Was 21

// After
minSdk = 23  // Required for Firebase
```

## Impact
- App now requires Android 6.0 (API 23) or higher
- This covers 99%+ of Android devices in use today
- Firebase and all its features will work correctly

## Device Compatibility
- ✅ Android 6.0+ (API 23+) - Supported
- ❌ Android 5.0-5.1 (API 21-22) - No longer supported

Most users are on Android 7.0+ anyway, so this change has minimal impact.

## Build Now
```bash
flutter clean
flutter pub get
flutter run
```

The app should now build successfully on Android!
