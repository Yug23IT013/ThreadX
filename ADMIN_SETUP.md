# Admin Module Setup Guide

## Overview
The admin module has been successfully implemented in your ThreadX app. Admins can:
- View all users
- Delete any user account (with all their threads and comments)
- Delete any thread (not just their own)
- Make other users admin or remove admin privileges
- View platform statistics

## Features Implemented

### 1. Admin Service (`lib/services/admin_service.dart`)
- Check if current user is admin
- Get all users with statistics
- Delete user accounts
- Delete any thread
- Toggle admin status for users
- Get app-wide statistics

### 2. User Model (`lib/models/user_model.dart`)
- Stores user information in Firestore
- Tracks admin status, thread count, comment count

### 3. Admin Dashboard (`lib/screens/admin/admin_dashboard.dart`)
- Statistics overview (users, threads, comments)
- Navigation to user management
- Navigation to thread management

### 4. All Users Screen (`lib/screens/admin/all_users_screen.dart`)
- View all registered users
- See user statistics (threads, comments)
- Delete user accounts
- Toggle admin privileges

### 5. All Threads Screen (`lib/screens/admin/all_threads_screen.dart`)
- View all threads in the platform
- Delete any thread (admin privilege)
- Includes all comments deletion

### 6. Navigation Drawer Update
- Shows "Admin Dashboard" menu item ONLY for admin users
- Admin badge in the drawer header
- Red color scheme for admin identification

## How to Make Your First Admin

Since new users are created as regular users by default, you need to manually promote one user to admin.

### Method 1: Using Firebase Console (Recommended)

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Go to **Firestore Database**
4. Navigate to the `users` collection
5. Find your user document (by email)
6. Edit the document
7. Set `isAdmin` field to `true`
8. Save changes
9. Restart the app - you should now see the Admin Dashboard in the drawer

### Method 2: Using Flutter Code (Temporary)

Add this temporary code to manually set admin status:

```dart
// In lib/screens/profile/settings_screen.dart or any screen
import '../../services/admin_service.dart';

// Add a temporary button
ElevatedButton(
  onPressed: () async {
    final adminService = AdminService();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await adminService.makeUserAdmin(currentUser.uid, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are now an admin!')),
      );
    }
  },
  child: Text('Make Me Admin (Remove This Button Later)'),
)
```

**Important:** Remove this button after creating the first admin!

## Admin Workflow

### Managing Users
1. Open drawer → Admin Dashboard
2. Tap "Manage Users"
3. Long press on any user to:
   - Make them admin / Remove admin
   - Delete their account

### Managing Threads
1. Open drawer → Admin Dashboard
2. Tap "Manage Threads"
3. Long press on any thread
4. Select "Delete Thread (Admin)"

## Security Considerations

⚠️ **Important Security Notes:**

1. **Admin Status is Client-Side Checked**: Currently, admin checks are done in the Flutter app. For production, implement server-side security rules.

2. **Firebase Security Rules** (Add to Firestore Rules):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is admin
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Users collection - only admins can delete
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == userId || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Threads - admins can delete any thread
    match /threads/{threadId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.authorId || isAdmin();
      allow delete: if request.auth.uid == resource.data.authorId || isAdmin();
    }
    
    // Comments - admins can delete any comment
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.authorId || isAdmin();
      allow delete: if request.auth.uid == resource.data.authorId || isAdmin();
    }
  }
}
```

3. **Super Admin**: The first admin should be carefully protected. Consider creating a separate "superAdmin" field that cannot be changed.

## Testing the Admin Module

1. **Create accounts**: Register 2-3 test accounts
2. **Make one admin**: Use Method 1 or 2 above
3. **Test admin dashboard**: View statistics
4. **Test user management**: Try toggling admin status
5. **Test thread deletion**: Delete a test thread
6. **Test user deletion**: Delete a test account

## UI Screenshots to Capture

For your Lab 8 submission, capture:
1. Admin Dashboard with statistics
2. All Users Screen showing user list
3. User deletion confirmation dialog
4. All Threads Screen
5. Thread deletion by admin
6. Navigation Drawer showing Admin Dashboard (red highlight)
7. Admin badge in drawer header

## Code Locations

- **Admin Service**: `lib/services/admin_service.dart`
- **User Model**: `lib/models/user_model.dart`
- **Admin Dashboard**: `lib/screens/admin/admin_dashboard.dart`
- **All Users**: `lib/screens/admin/all_users_screen.dart`
- **All Threads**: `lib/screens/admin/all_threads_screen.dart`
- **Updated Auth**: `lib/services/auth_service.dart`
- **Updated Drawer**: `lib/widgets/app_drawer.dart`

## Troubleshooting

**Admin Dashboard not showing in drawer?**
- Check if `isAdmin` field is set to `true` in Firestore
- Restart the app after changing admin status
- Check Firebase connection

**Can't delete users?**
- Ensure Firebase security rules allow admin deletion
- Check console for error messages

**Statistics not loading?**
- Check Firebase connection
- Ensure collections exist (users, threads, comments)

---

Your admin module is now fully functional! 🎉
