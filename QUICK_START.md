# Quick Start Guide

## 🚀 Get Push Notifications Working in 5 Minutes

### Step 1: Firebase Setup (2 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project or select existing
3. Click Android icon
4. Enter package name: `com.astrolearn.astro_learn`
5. Download `google-services.json`
6. Place in `android/app/` folder

### Step 2: Gradle Configuration (1 minute)

Add to `android/build.gradle.kts`:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

Add to `android/app/build.gradle.kts` (at the bottom):
```kotlin
apply(plugin = "com.google.gms.google-services")
```

### Step 3: Run the App (2 minutes)

```bash
flutter clean
flutter pub get
flutter run
```

### Step 4: Test Notifications

1. Open app drawer (hamburger menu)
2. Tap "Notification Settings"
3. Click "Send Test Notification"
4. ✅ You should see a notification!

## 🎯 That's It!

Your app now has:
- ✅ Push notifications from Firebase
- ✅ Local scheduled notifications
- ✅ In-app notification center
- ✅ Streak system (fixed)
- ✅ Notification settings screen

## 📱 Send Your First Push Notification

### From Firebase Console

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter title: "Hello from AstroLearn!"
4. Enter message: "Your cosmic journey begins now ✨"
5. Click "Send test message"
6. Copy FCM token from app settings
7. Paste token and click "Test"
8. ✅ Notification received!

### To All Users

1. Click "New campaign" > "Notifications"
2. Enter title and message
3. Click "Next"
4. Select "Topic" and enter `all_users`
5. Click "Review" and "Publish"
6. ✅ All users receive notification!

## 🔥 Streak System

The streak system is now fixed! It works like this:

- **Day 1**: Complete any learning activity → Streak = 1
- **Same Day**: Complete more activities → Streak stays 1 (timestamp updates)
- **Day 2**: Complete activity → Streak = 2
- **Skip Day**: Miss a day → Streak resets to 1

## 📊 Scheduled Notifications

Your app automatically sends:

- **8:00 AM**: Morning tasks reminder
- **6:00 PM**: Evening learning nudge
- **8:00 PM**: Streak protection alert (if streak > 0)

## 🎨 Modern Landing Page

The HTML landing page now has:
- Glassmorphism effects
- Smooth animations
- Ripple button effects
- Enhanced shadows
- Better visual depth

Open `landing-page/index.html` in a browser to see it!

## 🐛 Troubleshooting

### Notifications Not Showing?

1. Check device Settings > Apps > AstroLearn > Notifications
2. Ensure notifications are enabled
3. Verify `google-services.json` is in `android/app/`
4. Check FCM token in app settings (should not be null)

### Streak Not Updating?

1. Complete any learning activity (lesson, quiz, etc.)
2. Check home screen streak widget
3. Should update immediately
4. If not, restart app

### Firebase Errors?

1. Verify package name matches in Firebase Console
2. Check `google-services.json` is correct file
3. Run `flutter clean && flutter pub get`
4. Rebuild app

## 📚 Need More Help?

- **Full Setup Guide**: See `PUSH_NOTIFICATIONS_SETUP.md`
- **Changelog**: See `CHANGELOG_NOTIFICATIONS_STREAK.md`
- **Implementation Details**: See `IMPLEMENTATION_SUMMARY.md`

## ✅ Success Checklist

- [ ] Firebase project created
- [ ] `google-services.json` added
- [ ] Gradle files configured
- [ ] App runs without errors
- [ ] Test notification works
- [ ] FCM token visible in settings
- [ ] Streak updates correctly
- [ ] Scheduled notifications working

## 🎉 You're Done!

Your AstroLearn app now has professional-grade push notifications and a fixed streak system. Users will love the engagement features!

---

**Time to Complete**: ~5 minutes  
**Difficulty**: Easy  
**Status**: Production Ready
