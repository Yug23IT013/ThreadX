# ThreadX

A modern discussion forum and community platform built with Flutter and Firebase.

## About

ThreadX is a full-featured discussion forum application that allows users to create threads, comment, vote, and engage in conversations. The app includes role-based access control with separate admin and user interfaces.

## Features

### User Features
- 🔐 **Authentication**
  - Email/Password sign-in and registration
  - Google Sign-In integration
  - Password reset functionality
  - Secure session management

- 💬 **Thread Management**
  - Create, edit, and delete threads
  - Rich text content support
  - Real-time updates
  - Thread search functionality

- 💭 **Comments & Engagement**
  - Add comments to threads
  - Upvote/downvote system
  - Real-time comment updates
  - Edit and delete your own comments

- 👤 **User Profile**
  - View and edit profile
  - Track your threads and comments
  - User statistics

### Admin Features
- 📊 **Admin Dashboard**
  - View app statistics (users, threads, comments)
  - Recent activity monitoring
  - Quick access to management tools

- 👥 **User Management**
  - View all users
  - Grant/revoke admin privileges
  - Delete user accounts
  - Search users

- 📝 **Content Moderation**
  - View all threads
  - Delete inappropriate content
  - Monitor user activity

## Tech Stack

- **Frontend:** Flutter 3.10.4+
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Core
- **State Management:** Provider
- **Security:** Flutter Secure Storage
- **UI:** Material Design with custom dark theme

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.5
  http: ^1.6.0
  shared_preferences: ^2.5.4
  firebase_core: ^3.10.0
  firebase_auth: ^5.4.1
  cloud_firestore: ^5.5.0
  flutter_secure_storage: ^9.2.4
  intl: ^0.19.0
  google_sign_in: ^6.2.1
```

## Setup & Installation

### Prerequisites
- Flutter SDK (3.10.4 or higher)
- Android Studio / VS Code
- Firebase account

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd threadx_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password and Google Sign-In)
   - Enable Cloud Firestore
   - Add your Android/iOS apps to Firebase
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`

4. **Enable Google Sign-In**
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable "Google" provider
   - Add support email

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── config/              # App configuration
│   ├── constants.dart
│   └── theme.dart
├── models/              # Data models
│   ├── comment_model.dart
│   ├── thread_model.dart
│   └── user_model.dart
├── screens/             # UI screens
│   ├── admin/          # Admin-specific screens
│   ├── dashboard/      # User dashboard screens
│   ├── login/          # Authentication screens
│   └── profile/        # User profile screens
├── services/            # Business logic
│   ├── admin_service.dart
│   ├── auth_service.dart
│   ├── comment_service.dart
│   ├── session_manager.dart
│   ├── thread_service.dart
│   └── vote_service.dart
├── utils/              # Utility functions
├── widgets/            # Reusable widgets
└── main.dart           # App entry point
```

## Firestore Database Structure

```
users/
  {userId}/
    - email: String
    - displayName: String
    - isAdmin: Boolean
    - threadCount: Number
    - commentCount: Number
    - createdAt: Timestamp

threads/
  {threadId}/
    - title: String
    - content: String
    - authorId: String
    - authorName: String
    - upvotes: Number
    - downvotes: Number
    - commentCount: Number
    - createdAt: Timestamp
    - updatedAt: Timestamp

comments/
  {commentId}/
    - threadId: String
    - authorId: String
    - authorName: String
    - content: String
    - upvotes: Number
    - downvotes: Number
    - createdAt: Timestamp
    - updatedAt: Timestamp
```

## Usage

### For Users
1. Register with email/password or sign in with Google
2. Browse threads on the home screen
3. Create new threads using the floating action button
4. Comment on threads and vote on content
5. Manage your profile and view your activity

### For Admins
1. Admin accounts are granted through Firestore (set `isAdmin: true` in user document)
2. Admins automatically see the Admin Dashboard on login
3. Access user management and content moderation tools
4. Monitor app statistics and recent activity

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is created for educational purposes.

## Support

For support, please open an issue in the repository.
