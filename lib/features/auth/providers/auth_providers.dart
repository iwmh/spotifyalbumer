import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spotify_auth.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends StateNotifier<AsyncValue<SpotifyAuth?>> {
  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadStoredAuth();
  }

  final AuthService _authService;

  Future<void> _loadStoredAuth() async {
    try {
      // Clear any leftover OAuth state from previous sessions
      await _authService.clearOAuthState();
      
      final auth = await _authService.getStoredAuth();
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
      await _authService.startAuthFlow();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> handleAuthCallback(String code, String state) async {
    try {
      final auth = await _authService.exchangeCodeForTokens(code, state);
      this.state = AsyncValue.data(auth);
    } catch (e) {
      debugPrint('Auth callback error: $e');
      // Don't set error state if user is already authenticated
      final currentAuth = this.state.value;
      if (currentAuth == null || currentAuth.isExpired) {
        this.state = AsyncValue.error(e, StackTrace.current);
      } else {
        debugPrint('Ignoring auth error - user already authenticated');
      }
    }
  }

  Future<void> refreshAuth(String refreshToken) async {
    try {
      final auth = await _authService.refreshToken(refreshToken);
      state = AsyncValue.data(auth);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<SpotifyAuth?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (auth) => auth != null && !auth.isExpired,
    orElse: () => false,
  );
});