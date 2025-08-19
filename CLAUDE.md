# Spotify Albumer - Flutter App

## Project Overview
Spotify Albumer is a Flutter application that integrates with the Spotify Web API to manage playlists. The app allows users to view, modify, and manage their Spotify playlists with a modern, user-friendly interface.

## App Purpose & Features
- **Authentication**: OAuth 2.0 PKCE flow with Spotify
- **Playlist Management**: View, add tracks, delete tracks from playlists
- **Modern UI**: Dark theme with Spotify branding colors
- **State Management**: Riverpod for reactive state management

## Architecture & Tech Stack

### Dependencies
- `flutter_riverpod: ^2.6.1` - State management
- `http: ^1.2.2` - HTTP requests to Spotify API
- `crypto: ^3.0.5` - PKCE code challenge generation
- `url_launcher: ^6.3.1` - Launch browser for OAuth
- `flutter_secure_storage: ^9.2.2` - Secure token storage
- `app_links: ^6.3.2` - Handle deep links for OAuth callback

### Project Structure (Feature-First Architecture)
```
lib/
├── main.dart                           # App entry point with deep link handling
├── features/
│   ├── auth/                           # Authentication feature
│   │   ├── models/
│   │   │   └── spotify_auth.dart       # Authentication model
│   │   ├── providers/
│   │   │   └── auth_providers.dart     # Auth state management
│   │   ├── screens/
│   │   │   └── auth_screen.dart        # Login screen
│   │   └── services/
│   │       └── auth_service.dart       # OAuth service layer
│   └── playlists/                      # Playlist management feature
│       ├── models/
│       │   └── playlist.dart           # Playlist model
│       ├── providers/
│       │   └── playlist_providers.dart # Playlist state management
│       ├── screens/
│       │   └── playlists_screen.dart   # Main playlists view
│       ├── services/
│       │   └── playlist_service.dart   # Playlist API service
│       └── widgets/
│           └── playlist_card.dart      # Playlist display widget
└── shared/                             # Shared components
    ├── constants/
    │   ├── app_colors.dart             # App color palette
    │   └── app_theme.dart              # App theme configuration
    └── widgets/                        # Shared UI components
```

## Spotify API Configuration

### OAuth Settings
- **Client ID**: `d22dd3dd32a34060876238f6aab7b758`
- **Redirect URI**: `spotifyalbumer.iwmh.com://iwmh.app/callback/`
- **Auth Flow**: OAuth 2.0 with PKCE (no client secret needed)

### Scopes (Full Playlist Management)
```dart
static const scopes = [
  // Read permissions
  'playlist-read-private',
  'playlist-read-collaborative', 
  'user-read-private',
  'user-read-email',
  // Write permissions for playlist manipulation
  'playlist-modify-public',
  'playlist-modify-private',
  // Additional useful scopes
  'user-library-read',
  'user-library-modify', 
  'user-follow-read',
  'user-top-read',
];
```

## Key Implementation Details

### Authentication Flow
1. User taps login button → launches browser with Spotify auth URL
2. User authorizes → Spotify redirects to custom URL scheme
3. App handles deep link → exchanges code for tokens using PKCE
4. Tokens stored securely → user automatically logged in on app restart

### State Management Pattern (Feature-First)
- **Auth Feature**: `AuthNotifier` manages authentication state and token refresh
- **Playlists Feature**: `playlistsProvider` fetches user playlists with auto-refresh
- **Cross-Feature**: `isLoggedInProvider` computed provider for UI navigation logic
- **Separation**: Each feature manages its own state independently

### Security Features
- PKCE flow (more secure than client secret for mobile)
- Secure token storage using FlutterSecureStorage
- Automatic token refresh when expired
- OAuth state validation to prevent CSRF attacks

## Platform Configuration

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />

<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="spotifyalbumer.iwmh.com" />
</intent-filter>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>spotifyalbumer.iwmh.com</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>spotifyalbumer.iwmh.com</string>
        </array>
    </dict>
</array>
```

## Development Commands

### Setup
```bash
flutter pub get          # Install dependencies
```

### Build & Test  
```bash
flutter analyze          # Static analysis
flutter build apk --debug # Android debug build
flutter run              # Run in development
```

### Common Issues Fixed
1. **URL launch failures**: Added proper Android permissions and browser intent queries
2. **Invalid state parameter**: Added OAuth state cleanup and smart callback handling  
3. **Auth screen flash**: Improved loading states to prevent UI flickering
4. **Deep link handling**: Only process callbacks for non-authenticated users

## UI Theme
- **Primary Color**: Spotify Green (`#1DB954`)
- **Background**: Spotify Dark (`#191414`) 
- **Cards**: Dark Gray (`#282828`)
- **Text**: White/White70 for hierarchy
- **Design**: Material 3 with custom Spotify-inspired styling

## Future Enhancements
- Track search and addition to playlists
- Playlist creation and deletion
- Track reordering within playlists
- Album/artist browsing
- User's saved music management

## Architecture Benefits
- **Feature-First Structure**: Easy to scale, each feature is self-contained
- **Clear Separation**: Auth and playlists are completely independent
- **Shared Resources**: Common colors, themes, and utilities in shared folder
- **Maintainable**: Easy to add new features without affecting existing ones

## Notes for Claude
- The app uses **Feature-First architecture** for better scalability
- Modern Flutter patterns (Riverpod, Material 3) throughout
- All OAuth security best practices are implemented
- Error handling is comprehensive with fallbacks
- UI follows Spotify's visual design language with shared constants
- Code is well-structured, feature-separated, and maintainable