import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../playlists/models/playlist.dart';
import '../../playlists/providers/playlists_provider.dart';
import '../../playlists/services/playlist_service.dart';

const _quickAddTargetPlaylistIdsKey = 'quick_add_target_playlist_ids';
const _maxQuickAddTargets = 3;

final playlistServiceForQuickAddProvider = Provider<PlaylistService>((ref) {
  return PlaylistService();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// 認証済みアクセストークンを取得するヘルパー関数
Future<String> _resolveValidAccessToken(Ref ref) async {
  final authState = ref.read(authProvider);

  return authState.when(
    data: (auth) async {
      if (auth == null) {
        throw Exception('Not authenticated');
      }

      if (auth.isExpired) {
        final authService = ref.read(authServiceProvider);
        final refreshedAuth = await authService.refreshToken(auth.refreshToken);
        ref.read(authProvider.notifier).refreshAuth(refreshedAuth.refreshToken);
        return refreshedAuth.accessToken;
      }

      return auth.accessToken;
    },
    loading: () => throw Exception('Authentication loading'),
    error: (error, stack) => throw error,
  );
}

/// アルバム全体の合計時間を取得するProvider
final albumTotalDurationMsProvider = FutureProvider.family<int, String>((
  ref,
  albumId,
) async {
  final accessToken = await _resolveValidAccessToken(ref);
  final playlistService = ref.read(playlistServiceForQuickAddProvider);
  return playlistService.getAlbumTotalDurationMs(accessToken, albumId);
});

class QuickAddTargetNotifier extends StateNotifier<AsyncValue<List<String>>> {
  QuickAddTargetNotifier(this._storage) : super(const AsyncValue.loading()) {
    _load();
  }

  final FlutterSecureStorage _storage;

  Future<void> _load() async {
    try {
      final raw = await _storage.read(key: _quickAddTargetPlaylistIdsKey);
      if (raw == null || raw.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      final decoded = json.decode(raw) as List<dynamic>;
      final ids = decoded.whereType<String>().toList();
      state = AsyncValue.data(ids.take(_maxQuickAddTargets).toList());
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> setTargets(List<String> playlistIds) async {
    final normalized =
        playlistIds.toSet().toList().take(_maxQuickAddTargets).toList();

    state = AsyncValue.data(normalized);
    await _storage.write(
      key: _quickAddTargetPlaylistIdsKey,
      value: json.encode(normalized),
    );
  }
}

final quickAddTargetIdsProvider =
    StateNotifierProvider<QuickAddTargetNotifier, AsyncValue<List<String>>>((
      ref,
    ) {
      final storage = ref.watch(secureStorageProvider);
      return QuickAddTargetNotifier(storage);
    });

final quickAddTargetPlaylistsProvider = Provider<AsyncValue<List<Playlist>>>((
  ref,
) {
  final selectedIdsAsync = ref.watch(quickAddTargetIdsProvider);
  final playlistsAsync = ref.watch(playlistsProvider);

  return selectedIdsAsync.when(
    data:
        (selectedIds) => playlistsAsync.when(
          data: (playlists) {
            final byId = {
              for (final playlist in playlists) playlist.id: playlist,
            };
            final selectedPlaylists =
                selectedIds
                    .map((id) => byId[id])
                    .whereType<Playlist>()
                    .toList();
            return AsyncValue.data(selectedPlaylists);
          },
          loading: () => const AsyncValue.loading(),
          error: (error, stack) => AsyncValue.error(error, stack),
        ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

class AlbumQuickAddNotifier extends StateNotifier<AlbumQuickAddState> {
  AlbumQuickAddNotifier(this.ref) : super(const AlbumQuickAddState());

  final Ref ref;

  bool isAdding(String albumId, String playlistId) {
    return state.inFlight.contains(_operationKey(albumId, playlistId));
  }

  bool isCompleted(String albumId, String playlistId) {
    return state.completed.contains(_operationKey(albumId, playlistId));
  }

  Future<int> addAlbumToPlaylist({
    required String albumId,
    required String targetPlaylistId,
  }) async {
    final opKey = _operationKey(albumId, targetPlaylistId);
    state = state.copyWith(inFlight: {...state.inFlight, opKey});

    try {
      final accessToken = await _resolveValidAccessToken(ref);
      final playlistService = ref.read(playlistServiceForQuickAddProvider);

      final albumTrackUris = await playlistService.getAlbumTrackUris(
        accessToken,
        albumId,
      );

      await playlistService.addTracksToPlaylist(
        accessToken,
        targetPlaylistId,
        albumTrackUris,
      );

      // 追加完了したらcompletedに追加
      state = state.copyWith(completed: {...state.completed, opKey});

      return albumTrackUris.length;
    } finally {
      // inFlightから削除
      state = state.copyWith(
        inFlight: state.inFlight.where((key) => key != opKey).toSet(),
      );
    }
  }

  String _operationKey(String albumId, String playlistId) {
    return '$albumId:$playlistId';
  }
}

final albumQuickAddProvider =
    StateNotifierProvider<AlbumQuickAddNotifier, AlbumQuickAddState>((ref) {
      return AlbumQuickAddNotifier(ref);
    });

/// クイック追加の状態を管理するクラス
class AlbumQuickAddState {
  final Set<String> inFlight;
  final Set<String> completed;

  const AlbumQuickAddState({
    this.inFlight = const {},
    this.completed = const {},
  });

  AlbumQuickAddState copyWith({Set<String>? inFlight, Set<String>? completed}) {
    return AlbumQuickAddState(
      inFlight: inFlight ?? this.inFlight,
      completed: completed ?? this.completed,
    );
  }
}
