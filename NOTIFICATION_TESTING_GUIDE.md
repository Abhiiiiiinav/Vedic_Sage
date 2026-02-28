# Notification Testing Guide

## 🧪 How to Test All Notifications

### Method 1: Using the Test Screen (Recommended)

1. **Open the App**
   - Launch AstroLearn on your device

2. **Navigate to Test Screen**
   - Open app drawer (hamburger menu)
   - Tap "Notification Settings"
   - Tap "Test All Types" button

3. **Test Individual Notifications**
   - Tap any notification type to test it individually:
     - 🔥 Streak Alert
     - 📚 Learning Reminder
     - ☀️ Cosmic Update
     - 👥 Social Notification
     - 🏆 Achievement Alert
     - ✨ Daily Tasks

4. **Test All at Once**
   - Tap "Test All Notifications" button at the bottom
   - All 6 notification types will be sent
   - Check your notification center to see them all

### Method 2: Quick Test

1. **Open Notification Settings**
   - App drawer → Notification Settings
   - Tap "Quick Test" button
   - One test notification will be sent

### Method 3: Wait for Scheduled Notifications

These notifications fire automatically at scheduled times:

| Time | Notification | Type |
|------|--------------|------|
| 8:00 AM | Morning Tasks | Daily reminder |
| 6:00 PM | Evening Learning | Learning nudge |
| 8:00 PM | Streak Protection | Streak alert (if streak > 0) |

## 📱 Where to See Notifications

### In-App Notification Center
1. Tap the bell icon (🔔) in the app
2. See all notifications in chronological order
3. Mark as read or dismiss

### Device Notifications
1. Pull down notification shade on Android
2. See system notifications with custom icons and colors
3. Tap to open app

## 🎯 What to Test

### Visual Elements
- ✅ Custom icon for each notification type
- ✅ Custom color for each notification type
- ✅ Notification title and message
- ✅ Timestamp

### Functionality
- ✅ Notifications appear in notification center
- ✅ Device notifications show up (Android)
- ✅ Tap notification to open app
- ✅ Mark as read functionality
- ✅ Dismiss functionality

### Notification Types

#### 1. Streak Alert (🔥 Orange)
- **Purpose**: Protect user's learning streak
- **When**: 8:00 PM daily (if streak > 0)
- **Test**: Tap "Streak Alert" in test screen

#### 2. Learning Reminder (📚 Green)
- **Purpose**: Encourage continued learning
- **When**: 6:00 PM daily
- **Test**: Tap "Learning Reminder" in test screen

#### 3. Cosmic Update (☀️ Cyan)
- **Purpose**: Daily horoscope and planetary transits
- **When**: Morning (can be customized)
- **Test**: Tap "Cosmic Update" in test screen

#### 4. Social Notification (👥 Purple)
- **Purpose**: Friend requests and interactions
- **When**: Real-time when events occur
- **Test**: Tap "Social Notification" in test screen

#### 5. Achievement Alert (🏆 Gold)
- **Purpose**: Badge unlocks and milestones
- **When**: Real-time when achievements are earned
- **Test**: Tap "Achievement Alert" in test screen

#### 6. Daily Tasks (✨ Purple)
- **Purpose**: Morning task reminder
- **When**: 8:00 AM daily
- **Test**: Tap "Daily Tasks" in test screen

## 🔍 Testing Checklist

### Basic Tests
- [ ] Open test screen successfully
- [ ] Test each notification type individually
- [ ] Test all notifications at once
- [ ] Notifications appear in notification center
- [ ] Notifications show correct icon and color
- [ ] Notifications show correct title and message
- [ ] Timestamp is accurate

### Device Notifications (Android)
- [ ] Device notifications appear in notification shade
- [ ] Custom icon displays correctly
- [ ] Custom color displays correctly
- [ ] Sound plays (if enabled)
- [ ] Vibration works (if enabled)
- [ ] Tap notification opens app

### In-App Notification Center
- [ ] Bell icon shows unread count
- [ ] Notifications listed in chronological order
- [ ] Mark as read works
- [ ] Dismiss works
- [ ] Notification details display correctly

### Scheduled Notifications
- [ ] Morning tasks notification fires at 8:00 AM
- [ ] Evening learning notification fires at 6:00 PM
- [ ] Streak protection notification fires at 8:00 PM
- [ ] Notifications repeat daily

## 🐛 Troubleshooting

### Notifications Not Showing in App
1. Check if notification service is initialized
2. Look for console logs: "🔔 LocalNotificationService initialized"
3. Restart app if needed

### Device Notifications Not Showing
1. **Check Permissions**
   - Settings → Apps → AstroLearn → Notifications
   - Ensure notifications are enabled

2. **Check Do Not Disturb**
   - Disable Do Not Disturb mode
   - Or add AstroLearn to exceptions

3. **Check Battery Optimization**
   - Settings → Battery → Battery Optimization
   - Set AstroLearn to "Not optimized"

### Scheduled Notifications Not Firing
1. **Check Time**
   - Ensure device time is correct
   - Notifications fire at scheduled times

2. **Check App State**
   - App must be installed (not uninstalled)
   - Notifications persist even if app is closed

3. **Check Logs**
   - Look for: "📅 Daily notifications scheduled"

## 💡 Tips

1. **Test in Different States**
   - App in foreground
   - App in background
   - App terminated

2. **Test Different Times**
   - Morning (8 AM)
   - Evening (6 PM)
   - Night (8 PM)

3. **Test Multiple Notifications**
   - Send several at once
   - Check notification grouping
   - Check notification order

4. **Test Notification Actions**
   - Tap to open app
   - Swipe to dismiss
   - Mark as read

## 📊 Expected Results

### Successful Test
```
✅ Notification appears in app notification center
✅ Device notification shows in notification shade
✅ Custom icon and color display correctly
✅ Title and message are accurate
✅ Timestamp is correct
✅ Tap opens app
✅ Mark as read works
```

### Test Output
When you tap "Test All Notifications", you should see:
1. 6 notifications in notification center
2. 6 device notifications (Android)
3. Success message: "All 6 notifications sent!"
4. Green checkmark confirmation

## 🎉 Success Criteria

Your notification system is working correctly if:
- ✅ All 6 notification types can be tested
- ✅ Notifications appear in both app and device
- ✅ Custom icons and colors display correctly
- ✅ Scheduled notifications fire at correct times
- ✅ Notification center shows all notifications
- ✅ Mark as read and dismiss work properly

## 📚 Additional Resources

- **Setup Guide**: `PUSH_NOTIFICATIONS_SETUP.md`
- **Implementation Details**: `IMPLEMENTATION_SUMMARY.md`
- **Quick Start**: `QUICK_START.md`

---

**Happy Testing!** 🚀

If you encounter any issues, check the troubleshooting section or review the setup guide.
