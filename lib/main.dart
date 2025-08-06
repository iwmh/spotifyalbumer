import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'providers/spotify_providers.dart';
import 'screens/auth_screen.dart';
import 'screens/playlists_screen.dart';

void main() {
  runApp(const ProviderScope(child: SpotifyAlbumerApp()));
}

class SpotifyAlbumerApp extends StatelessWidget {
  const SpotifyAlbumerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Albumer',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1DB954),
          secondary: Color(0xFF1DB954),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle app opened via deep link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      print('Failed to get initial link: $e');
    }

    // Handle deep links when app is already open
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (err) => print('Deep link error: $err'),
    );
  }

  void _handleIncomingLink(Uri uri) {
    if (uri.scheme == 'spotifyalbumer.iwmh.com' && 
        uri.host == 'iwmh.app' && 
        uri.path == '/callback/') {
      
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        print('OAuth error: $error');
        return;
      }

      // Only handle callback if we have both code and state, and user is not already logged in
      if (code != null && state != null) {
        final isLoggedIn = ref.read(isLoggedInProvider);
        if (!isLoggedIn) {
          ref.read(authProvider.notifier).handleAuthCallback(code, state);
        } else {
          print('Ignoring OAuth callback - user already logged in');
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: authState.when(
        data: (auth) {
          if (auth != null && !auth.isExpired) {
            return const PlaylistsScreen();
          } else {
            return const AuthScreen();
          }
        },
        loading: () => const Scaffold(
          backgroundColor: Color(0xFF191414),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_note,
                  size: 80,
                  color: Color(0xFF1DB954),
                ),
                SizedBox(height: 32),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (error, stack) => const AuthScreen(),
      ),
    );
  }
}
