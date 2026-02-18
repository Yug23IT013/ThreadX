# Firestore User Document Fix Guide

## Issue: User documents not being created in Firestore

### Quick Fix Steps:

## 1. Deploy Firestore Security Rules

Your app now has proper security rules in `firestore.rules`. Deploy them:

### Option A: Using Firebase Console
1. Go to https://console.firebase.google.com
2. Select your project
3. Go to **Firestore Database** → **Rules** tab
4. Copy the rules from `firestore.rules` file
5. Paste into the editor
6. Click **Publish**

### Option B: Using Firebase CLI
```bash
firebase deploy --only firestore:rules
```

## 2. Test User Creation

### Check Console Logs
When you register or login, you should see:
- ✅ `User document created successfully for [userId]`
- OR ❌ `Error creating user document: [error]`

Check the debug console in VS Code or run:
```bash
flutter run
```

### Manual User Document Creation (If needed)

If users still aren't being created, add this test button temporarily:

**In `lib/screens/profile/settings_screen.dart`** (or any screen):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Add this button in your widget
ElevatedButton(
  onPressed: () async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': user.email!,
          'displayName': user.displayName ?? user.email!.split('@')[0],
          'createdAt': FieldValue.serverTimestamp(),
          'isAdmin': false,
          'threadCount': 0,
          'commentCount': 0,
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User document created!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  },
  child: Text('Create My User Document'),
)
```

## 3. Verify User Documents in Firebase Console

1. Go to Firebase Console → Firestore Database
2. Check if `users` collection exists
3. Look for documents with your user IDs
4. Each document should have:
   - email: string
   - displayName: string
   - createdAt: timestamp
   - isAdmin: boolean
   - threadCount: number
   - commentCount: number

## 4. Common Issues & Solutions

### Issue: "Insufficient permissions"
**Solution:** Deploy the firestore.rules file (see Step 1)

### Issue: "Collection 'users' doesn't exist"
**Solution:** Firestore creates collections automatically. Try registering a new user.

### Issue: "FieldValue.serverTimestamp() error"
**Solution:** This is normal - the timestamp is set by the server. The field will show up after a moment.

### Issue: User authenticated but no document
**Solution:** Check Firestore rules are deployed and allow user creation

## 5. Testing Checklist

✅ Register a new user  
✅ Check debug console for "User document created successfully"  
✅ Check Firebase Console → Firestore → users collection  
✅ Login with existing user (should create document if missing)  
✅ Check admin status works (after setting isAdmin = true)  

## 6. Temporary: Allow All Writes (Testing Only!)

If you need to test quickly, use these **TEMPORARY** rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **WARNING:** These rules are insecure! Only use for testing, then switch back to proper rules.

## 7. Verify Fix

After deploying rules and testing:

1. **Register a new test account**
   - Email: test@example.com
   - Password: test123
   - Username: Test User

2. **Check Firestore Console**
   - Users collection should exist
   - Document with the new user's UID should appear
   - Document should have all required fields

3. **Check Debug Console**
   - Should show: ✅ User document created successfully

4. **Test Admin Features**
   - Set isAdmin = true in Firebase Console
   - Restart app
   - Admin Dashboard should appear in drawer

## Need More Help?

If issues persist:
1. Check Firebase Console → Firestore → Rules tab (ensure rules are published)
2. Check Flutter console for error messages
3. Verify Firebase initialization in main.dart
4. Ensure cloud_firestore package is installed in pubspec.yaml

---

**Your user documents should now be created successfully!** ✅
