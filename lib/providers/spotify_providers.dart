import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spotify_auth.dart';
import '../models/playlist.dart';
import '../services/spotify_service.dart';

final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  return SpotifyService();
});

class AuthNotifier extends StateNotifier<AsyncValue<SpotifyAuth?>> {
  AuthNotifier(this._spotifyService) : super(const AsyncValue.loading()) {
    _loadStoredAuth();
  }

  final SpotifyService _spotifyService;

  Future<void> _loadStoredAuth() async {
    try {
      // Clear any leftover OAuth state from previous sessions
      await _spotifyService.clearOAuthState();
      
      final auth = await _spotifyService.getStoredAuth();
      if (auth != null && !auth.isExpired) {
        state = AsyncValue.data(auth);
      } else if (auth != null && auth.isExpired) {
        await refreshAuth(auth.refreshToken);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> login() async {
    try {
      state = const AsyncValue.loading();
      await _spotifyService.startAuthFlow();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> handleAuthCallback(String code, String state) async {
    try {
      final auth = await _spotifyService.exchangeCodeForTokens(code, state);
      this.state = AsyncValue.data(auth);
    } catch (e) {
      print('Auth callback error: $e');
      // Don't set error state if user is already authenticated
      final currentAuth = this.state.value;
      if (currentAuth == null || currentAuth.isExpired) {
        this.state = AsyncValue.error(e, StackTrace.current);
      } else {
        print('Ignoring auth error - user already authenticated');
      }
    }
  }

  Future<void> refreshAuth(String refreshToken) async {
    try {
      final auth = await _spotifyService.refreshToken(refreshToken);
      state = AsyncValue.data(auth);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    try {
      await _spotifyService.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<SpotifyAuth?>>((ref) {
  final spotifyService = ref.watch(spotifyServiceProvider);
  return AuthNotifier(spotifyService);
});

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final authState = ref.watch(authProvider);
  
  return authState.when(
    data: (auth) async {
      if (auth == null) {
        throw Exception('Not authenticated');
      }
      
      final spotifyService = ref.read(spotifyServiceProvider);
      
      if (auth.isExpired) {
        final refreshedAuth = await spotifyService.refreshToken(auth.refreshToken);
        ref.read(authProvider.notifier).refreshAuth(refreshedAuth.refreshToken);
        return spotifyService.getUserPlaylists(refreshedAuth.accessToken);
      }
      
      return spotifyService.getUserPlaylists(auth.accessToken);
    },
    loading: () => throw Exception('Authentication loading'),
    error: (error, stack) => throw error,
  );
});

final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (auth) => auth != null && !auth.isExpired,
    orElse: () => false,
  );
});