# BookSwap App

A Flutter-based mobile application for students to exchange textbooks. Built with Firebase for backend services, featuring real-time chat, book listings, and swap management.

## Features

### Core Features
-  **User Authentication**
  - Email/Password sign up and login
  - Google Sign-In integration
  - Email verification
  - Secure authentication with Firebase

-  **Book Listings (CRUD)**
  - Create book listings with images
  - Browse all available books
  - Edit your own listings
  - Delete your listings
  - Real-time updates

-  **Swap Management**
  - Request swaps for books
  - Accept/Reject swap requests
  - Track swap status (Pending/Accepted/Rejected)
  - Real-time swap state synchronization

- **Chat System**
  - Real-time messaging
  - Auto-created chats for each swap
  - Message history
  - Online presence indicators

-  **Settings & Profile**
  - View profile information
  - Notification preferences
  - Email verification status
  - Dark mode toggle

## Architecture

### Tech Stack
- **Frontend**: Flutter 3.9.2
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
- **State Management**: Provider
- **Navigation**: Flutter Navigation with Bottom Nav Bar

### Project Structure
```
lib/
├── models/              # Data models (Book, User, Swap, Chat)
├── services/            # Firebase services & business logic
├── providers/           # State management providers
├── screens/             # UI screens
│   ├── auth/           # Authentication screens
│   └── home/           # Main app screens
├── widgets/            # Reusable widgets
├── firebase_options.dart
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Firebase account
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/kayigmb/Bookswap-app.git
   cd Bookswap-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   Quick setup:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Setup
1. Create a Firebase project
2. Enable Authentication (Email/Password & Google)
3. Create Firestore Database
4. Enable Firebase Storage
5. Run `flutterfire configure`
6. Update security rules (see FIREBASE_SETUP.md)

### Authentication
- Splash Screen with Sign In/Sign Up options
- Login screen with Google Sign-In
- Registration with email verification

### Main Features
- Browse Books - Grid view of all available books
- My Listings - Manage your book listings
- Chats - Real-time messaging
- Settings - Profile and preferences

## Database Schema

### Collections
1. **users** - User profiles
2. **books** - Book listings
3. **swaps** - Swap requests and status
4. **chats** - Chat sessions
5. **messages** - Chat messages

## Security

- Firebase Security Rules implemented
- Authentication required for all operations
- Ownership validation for CRUD operations
- Server-side validation with Firestore rules

## Testing
Check for errors:
```bash
flutter analyze
```
