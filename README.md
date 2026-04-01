# ThreadX

ThreadX is a Flutter + Firebase community discussion platform with role-based access (user/admin), real-time thread and comment streams, voting/karma, basic content moderation, image uploads, and local/push notifications.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Data Model](#data-model)
- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [Cloudinary Setup (Image Uploads)](#cloudinary-setup-image-uploads)
- [Notifications Setup](#notifications-setup)
- [Useful Commands](#useful-commands)
- [Build and Release](#build-and-release)
- [Security Notes](#security-notes)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Overview

ThreadX provides a forum-like experience where authenticated users can:

- Register/login with email-password or Google Sign-In
- Create and manage discussion threads
- Comment on threads in real time
- Upvote/downvote threads (with karma updates)
- Manage personal profile activity (posts/comments)

Admin users can:

- Access a dedicated admin dashboard
- Manage users and grant/revoke admin role
- Remove content and user-generated data
- Review flagged threads created by moderation checks

The app routes users automatically based on authentication and admin status through `AuthWrapper`.

## Key Features

### Authentication and Session

- Firebase Authentication (email/password)
- Google Sign-In integration
- Password reset flow
- Auth state listener with role check (`isAdmin` in Firestore)

### Threads and Comments

- Real-time thread feed using Firestore streams
- Create, edit, delete thread flows
- Thread detail with live comments
- Search by thread title prefix
- User-specific post/comment history screens

### Voting and Karma

- Per-user vote tracking in a dedicated `votes` collection
- Vote toggle and vote switching logic
- Author karma updated based on vote deltas
- Self-vote protection

### Moderation and Admin Control

- Keyword-based moderation at thread creation
- Flagged threads marked `pending`
- Admin approval/rejection flow for pending content
- Admin tools for users, threads, and app stats

### Notifications

- Firebase Cloud Messaging setup
- Foreground notification handling
- Background message handler
- Local notification channel (Android)
- Notification tap routing hooks
- Web push service worker support

### Media Upload

- Camera/gallery image picker
- Cloudinary upload via signed API requests
- Delete support by `public_id`

## Tech Stack

- Flutter (SDK constraint: `^3.10.4`)
- Dart
- State Management: Provider
- Backend: Firebase
  - Firebase Core
  - Firebase Auth
  - Cloud Firestore
  - Firebase Cloud Messaging
- Local notifications: `flutter_local_notifications`
- Image upload: Cloudinary + Dio
- Local persistence: Shared Preferences + Flutter Secure Storage
- Formatting/localization support: Intl

## Project Structure

```text
threadx_app/
  lib/
    main.dart
    firebase_options.dart
    config/
      constants.dart
      cloudinary_config.dart
      theme.dart
    models/
      thread_model.dart
      comment_model.dart
      user_model.dart
    screens/
      auth_wrapper.dart
      login/
      dashboard/
      profile/
      admin/
      demo/
    services/
      auth_service.dart
      thread_service.dart
      comment_service.dart
      vote_service.dart
      admin_service.dart
      content_moderation_service.dart
      notification_service.dart
      image_upload_service.dart
      session_manager.dart
    widgets/
      app_drawer.dart
      custom_button.dart
      custom_textfield.dart
      thread_card.dart
  android/
  ios/
  web/
    firebase-messaging-sw.js
  firestore.rules
  firebase.json
  pubspec.yaml
```

## How It Works

### App Bootstrap

`main.dart` performs the following startup sequence:

1. Initializes Flutter bindings
2. Initializes Firebase with generated options
3. Registers FCM background handler
4. Initializes local + push notification service
5. Starts app with `AuthService` via `Provider`

### Role-Based Navigation

`AuthWrapper` determines landing screen:

- Unauthenticated -> Login screen
- Authenticated non-admin -> Home dashboard
- Authenticated admin -> Admin dashboard

### Firestore-Backed Flows

- `users`: profile and role metadata
- `threads`: post content + status (`approved`/`pending`)
- `comments`: comments attached to threads
- `votes`: composite document id (`threadId_userId`) for vote state

## Data Model

Core collections used by the app:

### users

- `email: string`
- `displayName: string`
- `isAdmin: bool`
- `threadCount: number`
- `commentCount: number`
- `karma: number`
- `createdAt: timestamp`

### threads

- `title: string`
- `content: string`
- `authorId: string`
- `authorName: string`
- `votes: number`
- `commentCount: number`
- `status: approved | pending`
- `flagReason: string?`
- `flaggedKeywords: string[]?`
- `createdAt: timestamp`
- `updatedAt: timestamp`

### comments

- `threadId: string`
- `authorId: string`
- `authorName: string`
- `content: string`
- `createdAt: timestamp`
- `updatedAt: timestamp`

### votes

- `threadId: string`
- `userId: string`
- `voteType: upvote | downvote`
- `createdAt: timestamp`

## Getting Started

### Prerequisites

- Flutter SDK (matching Dart SDK constraints in `pubspec.yaml`)
- Android Studio or VS Code with Flutter/Dart plugins
- JDK 17 (Android build settings target Java 17)
- Firebase project access
- (Optional) Cloudinary account for image uploads

### 1) Clone and install

```bash
git clone <your-repo-url>
cd threadx_app
flutter pub get
```

### 2) Verify Flutter environment

```bash
flutter doctor
```

### 3) Run the app

```bash
flutter run
```

You can target specific platforms as needed, for example:

```bash
flutter run -d chrome
flutter run -d android
```

## Firebase Setup

This project already contains FlutterFire outputs (`firebase_options.dart`, `firebase.json`) and Android config (`android/app/google-services.json`).

If you connect to a different Firebase project, reconfigure safely:

1. Install FlutterFire CLI
2. Run `flutterfire configure`
3. Ensure platform app registrations are complete (Android/iOS/Web/etc.)
4. Verify generated `lib/firebase_options.dart`
5. Update platform native config files when prompted

### Enable Firebase services

- Authentication
  - Email/Password
  - Google provider
- Cloud Firestore
- Cloud Messaging (if notifications are required)

### Firestore rules

Rules are defined in `firestore.rules`.

To deploy rules:

```bash
firebase deploy --only firestore:rules
```

## Cloudinary Setup (Image Uploads)

Image uploads are implemented in `image_upload_service.dart` and configured in `lib/config/cloudinary_config.dart`.

Required values:

- `cloudName`
- `apiKey`
- `apiSecret`

Recommended:

- Do not keep Cloudinary secret keys in source code for production apps
- Move secrets to secure runtime config or backend-signed upload flow

## Notifications Setup

### Android

The app includes notification permissions and FCM-related metadata in `android/app/src/main/AndroidManifest.xml`, including:

- `POST_NOTIFICATIONS`
- `SCHEDULE_EXACT_ALARM`
- default FCM channel metadata

### Web

Web push is configured with service worker:

- `web/firebase-messaging-sw.js`

Ensure your Firebase web config and messaging settings match your active Firebase project.

### In-App Service

`notification_service.dart` handles:

- Permission requests
- Foreground notification display
- Token retrieval and refresh listener
- Notification tap handlers

## Useful Commands

### Quality and tests

```bash
flutter analyze
flutter test
```

### Clean/rebuild

```bash
flutter clean
flutter pub get
flutter run
```

### Generate launcher icons

```bash
dart run flutter_launcher_icons
```

### Generate splash screens

```bash
dart run flutter_native_splash:create
```

## Build and Release

### Android release build

```bash
flutter build apk --release
```

or

```bash
flutter build appbundle --release
```

### Signing config

Android release signing reads `android/key.properties` from Gradle config.

Expected keys:

- `storeFile`
- `storePassword`
- `keyAlias`
- `keyPassword`

Keep keystore files and passwords out of version control.

## Security Notes

Important hardening items before production:

- Rotate and secure any exposed API keys/secrets
- Move Cloudinary signing server-side
- Audit Firestore rules for least privilege
- Replace debug-style logging with structured/filtered logging
- Validate all user-generated content server-side as well

## Troubleshooting

### App starts but Firebase calls fail

- Confirm active Firebase project configuration in `firebase_options.dart`
- Confirm native platform config files are present and correct
- Check Firebase Authentication and Firestore are enabled

### Google Sign-In not working

- Ensure Google provider is enabled in Firebase Authentication
- Verify SHA certificates (Android) and bundle IDs (iOS)

### Notifications not received

- Confirm permissions granted on device/browser
- Validate FCM token generation
- Verify service worker registration for web
- Confirm message payload format for route/thread data

### Build errors on Android

- Ensure local JDK compatibility with Gradle/Android config
- Run `flutter clean` and `flutter pub get`
- Rebuild with verbose logs if needed: `flutter run -v`

## Contributing

Contributions are welcome.

Suggested flow:

1. Create a feature branch
2. Keep commits scoped and descriptive
3. Run `flutter analyze` and `flutter test`
4. Open a pull request with a clear summary

## License

This repository is currently intended for educational/project use.
Add a formal license file if you plan to distribute publicly.
