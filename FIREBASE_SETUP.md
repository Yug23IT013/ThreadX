# Firebase Authentication Setup Guide

## Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `threadx` (or your preferred name)
4. Follow the wizard to create the project

## Step 3: Configure Firebase for Your App

Run the following command in your project directory:

```bash
flutterfire configure --project=threadx-dae3d
```

**Note:** Replace `threadx-dae3d` with your actual Firebase project ID

This will:
- Generate `firebase_options.dart` with your actual Firebase configuration
- Configure Firebase for all platforms (Android, iOS, Web, etc.)

## Step 4: Enable Email/Password Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Email/Password**
3. Enable it and click **Save**

## Step 5: Install Dependencies

```bash
flutter pub get
```

## Step 6: Run the App

```bash
flutter run
```

## Features Implemented

✅ **Login Screen**
- Email validation
- Password validation
- Forgot password functionality
- Error handling

✅ **Registration Screen**
- Username validation
- Email validation
- Password validation (minimum 6 characters)
- Confirm password matching
- User-friendly error messages

✅ **Authentication Service**
- Firebase Authentication integration
- User registration with email/password
- User login with email/password
- Password reset functionality
- Comprehensive error handling
- Loading states

✅ **Session Management**
- Save user session using SharedPreferences
- Auto-login on app restart
- Secure logout

✅ **Profile Screen**
- Display user information
- Logout functionality with confirmation
- Clear session on logout

## Project Structure

```
lib/
├── main.dart                          # App entry point with Firebase initialization
├── firebase_options.dart              # Firebase configuration (auto-generated)
├── config/
│   ├── constants.dart
│   └── theme.dart
├── models/
├── screens/
│   ├── auth_wrapper.dart             # Handles auth state routing
│   ├── login/
│   │   ├── login_screen.dart         # Login UI with validation
│   │   └── register_screen.dart      # Registration UI with validation
│   ├── dashboard/
│   │   └── home_screen.dart          # Main dashboard
│   └── profile/
│       └── profile_screen.dart       # Profile with logout
├── services/
│   ├── auth_service.dart             # Firebase Auth service
│   └── session_manager.dart          # Session management
├── utils/
│   └── validators.dart               # Input validation utilities
└── widgets/
    ├── custom_button.dart            # Reusable button
    └── custom_textfield.dart         # Reusable text field with validation
```

## Testing the Authentication

### Test Registration:
1. Open the app
2. Click "Create Account"
3. Fill in:
   - Username (min 3 characters)
   - Email (valid format)
   - Password (min 6 characters)
   - Confirm Password (must match)
4. Click "Sign Up"

### Test Login:
1. Enter registered email
2. Enter password
3. Click "Log In"

### Test Forgot Password:
1. Click "Forgot password?"
2. Enter your email
3. Check your email for reset link

### Test Logout:
1. After logging in, navigate to Profile
2. Scroll to bottom and click "Logout"
3. Confirm logout

## Error Handling

The app handles various Firebase Auth errors:
- **weak-password**: Password too weak
- **email-already-in-use**: Email already registered
- **invalid-email**: Invalid email format
- **user-not-found**: User doesn't exist
- **wrong-password**: Incorrect password
- **invalid-credential**: Invalid login credentials
- **network-request-failed**: Network connection issue

## Notes

- The app uses **Provider** for state management
- **SharedPreferences** for session persistence
- **Firebase Authentication** for secure user management
- Form validation on all input fields
- Loading indicators during async operations
- User-friendly error messages

## Troubleshooting

### Firebase not initialized error:
Make sure you've run `flutterfire configure` and the `firebase_options.dart` file has valid credentials.

### Gradle build errors:
Update your `android/build.gradle` and `android/app/build.gradle` with proper Firebase dependencies.

### iOS build errors:
Run `cd ios && pod install` to install Firebase pods.

## Next Steps

After completing this lab, you can:
1. Add social authentication (Google, Facebook)
2. Implement email verification
3. Add user profile images
4. Implement phone authentication
5. Add biometric authentication
