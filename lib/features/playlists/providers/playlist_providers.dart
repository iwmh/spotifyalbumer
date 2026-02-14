import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import '../services/playlist_service.dart';
import '../../auth/providers/auth_providers.dart';

final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return PlaylistService();
});

final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final authState = ref.watch(authProvider);

  return authState.when(
    data: (auth) async {
      if (auth == null) {
        throw Exception('Not authenticated');
      }

      final playlistService = ref.read(playlistServiceProvider);
      final authService = ref.read(authServiceProvider);

      if (auth.isExpired) {
        final refreshedAuth = await authService.refreshToken(auth.refreshToken);
        ref.read(authProvider.notifier).refreshAuth(refreshedAuth.refreshToken);
        return playlistService.getUserPlaylists(refreshedAuth.accessToken);
      }

      return playlistService.getUserPlaylists(auth.accessToken);
    },
    loading: () => throw Exception('Authentication loading'),
    error: (error, stack) => throw error,
  );
});

final playlistTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  playlistId,
) async {
  final authState = ref.watch(authProvider);

  return authState.when(
    data: (auth) async {
      if (auth == null) {
        throw Exception('Not authenticated');
      }

      final playlistService = ref.read(playlistServiceProvider);
      final authService = ref.read(authServiceProvider);

      if (auth.isExpired) {
        final refreshedAuth = await authService.refreshToken(auth.refreshToken);
        ref.read(authProvider.notifier).refreshAuth(refreshedAuth.refreshToken);
        return playlistService.getPlaylistTracks(
          refreshedAuth.accessToken,
          playlistId,
        );
      }

      return playlistService.getPlaylistTracks(auth.accessToken, playlistId);
    },
    loading: () => throw Exception('Authentication loading'),
    error: (error, stack) => throw error,
  );
});
