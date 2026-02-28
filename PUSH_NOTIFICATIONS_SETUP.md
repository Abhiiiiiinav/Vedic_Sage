# Push Notifications Setup Guide

This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications in AstroLearn.

## 🔥 Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Enter project name: `AstroLearn`
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Add Android App

1. In Firebase Console, click the Android icon
2. Enter package name: `com.astrolearn.astro_learn` (check `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Click "Next" and follow the setup instructions

### 3. Add iOS App (Optional)

1. In Firebase Console, click the iOS icon
2. Enter bundle ID from `ios/Runner.xcodeproj`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory
5. Click "Next" and follow the setup instructions

## 📱 Android Configuration

### 1. Update `android/build.gradle.kts`

Add Google services plugin:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### 2. Update `android/app/build.gradle.kts`

Add at the bottom:

```kotlin
apply(plugin = "com.google.gms.google-services")
```

### 3. Verify Permissions

The following permissions are already added in `AndroidManifest.xml`:
- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `POST_NOTIFICATIONS`
- `RECEIVE_BOOT_COMPLETED`
- `VIBRATE`

## 🍎 iOS Configuration (Optional)

### 1. Enable Push Notifications

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" and enable "Remote notifications"

### 2. Upload APNs Key

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Create APNs Authentication Key
3. Download the `.p8` file
4. In Firebase Console, go to Project Settings > Cloud Messaging
5. Upload the APNs key

## 🔔 Testing Push Notifications

### 1. Test from App

1. Run the app
2. Go to Settings > Notifications
3. Click "Send Test Notification"
4. You should see a notification in the notification center

### 2. Test from Firebase Console

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Click "Send test message"
5. Enter your FCM token (visible in app settings)
6. Click "Test"

### 3. Test with Topics

The app automatically subscribes to these topics:
- `all_users` - All app users
- `daily_updates` - Daily cosmic updates

To send to a topic:
1. Go to Firebase Console > Cloud Messaging
2. Click "New campaign" > "Notifications"
3. Enter title and message
4. Click "Next"
5. Select "Topic" and enter `all_users`
6. Click "Review" and "Publish"

## 📊 Notification Types

The app supports these notification types:

| Type | Description | Icon | Color |
|------|-------------|------|-------|
| `streak` | Streak protection alerts | 🔥 | Orange |
| `learning` | Learning reminders | 📚 | Green |
| `cosmic` | Daily horoscope updates | ☀️ | Cyan |
| `social` | Friend interactions | 👥 | Purple |
| `achievement` | Badges and milestones | 🏆 | Gold |
| `general` | General notifications | 🔔 | Purple |

## 🎯 Scheduled Notifications

The app schedules these daily notifications:

1. **Morning Tasks** - 8:00 AM
   - Reminds users about daily tasks
   
2. **Evening Learning** - 6:00 PM
   - Nudges users to continue learning
   
3. **Streak Protection** - 8:00 PM
   - Alerts users if streak is at risk

## 🔧 Customization

### Modify Notification Times

Edit `lib/core/services/local_notification_service.dart`:

```dart
// Change morning reminder time
await _scheduleDaily(
  id: _morningTasksId,
  hour: 9, // Change to 9 AM
  minute: 30, // Change to 9:30 AM
  // ...
);
```

### Add New Notification Topics

Edit `lib/main.dart`:

```dart
await PushNotificationService().subscribeToTopic('premium_users');
await PushNotificationService().subscribeToTopic('beta_testers');
```

### Custom Notification Channels

Edit `lib/core/services/push_notification_service.dart`:

```dart
const androidDetails = AndroidNotificationDetails(
  'custom_channel_id',
  'Custom Channel Name',
  channelDescription: 'Description',
  importance: Importance.high,
  // ... other settings
);
```

## 🐛 Troubleshooting

### Notifications Not Showing

1. **Check Permissions**
   - Go to device Settings > Apps > AstroLearn > Notifications
   - Ensure notifications are enabled

2. **Verify Firebase Setup**
   - Ensure `google-services.json` is in `android/app/`
   - Check package name matches in Firebase Console

3. **Check FCM Token**
   - Open app and go to Settings > Notifications
   - Verify FCM token is displayed
   - If null, check Firebase initialization

4. **Test with Firebase Console**
   - Send test message using FCM token
   - Check device logs for errors

### Background Notifications Not Working

1. **Check Battery Optimization**
   - Disable battery optimization for AstroLearn
   - Settings > Battery > Battery Optimization

2. **Verify Background Handler**
   - Ensure `@pragma('vm:entry-point')` is present
   - Check `FirebaseMessaging.onBackgroundMessage` is set

### iOS Notifications Not Working

1. **Check Capabilities**
   - Verify Push Notifications capability is enabled
   - Verify Background Modes > Remote notifications is enabled

2. **Check APNs Key**
   - Ensure APNs key is uploaded to Firebase
   - Verify key ID and team ID are correct

## 📚 Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications Plugin](https://pub.dev/packages/flutter_local_notifications)
- [Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)

## ✅ Checklist

- [ ] Firebase project created
- [ ] `google-services.json` added to `android/app/`
- [ ] Google services plugin added to gradle files
- [ ] App runs without errors
- [ ] FCM token is generated and visible in app
- [ ] Test notification works from app
- [ ] Test notification works from Firebase Console
- [ ] Subscribed to topics successfully
- [ ] Daily scheduled notifications are working
- [ ] Background notifications are working

## 🎉 Success!

Once all steps are complete, your app will have:
- ✅ Push notifications from Firebase
- ✅ Local scheduled notifications
- ✅ In-app notification center
- ✅ Streak protection alerts
- ✅ Daily learning reminders
- ✅ Topic-based messaging
