import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track.dart';
import '../../playlists/services/playlist_service.dart';
import '../../auth/providers/auth_providers.dart';

/// PlaylistServiceのプロバイダー
/// プレイリスト詳細機能でもplaylists featureのサービスを共有
final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return PlaylistService();
});

/// プレイリストのトラック一覧を取得するプロバイダー
///
/// [playlistId]を引数に取り、そのプレイリストに含まれる全トラックを返す
/// 認証状態を監視し、トークンが期限切れの場合は自動的にリフレッシュする
final playlistTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  playlistId,
) async {
  // 認証状態を監視
  final authState = ref.watch(authProvider);

  return authState.when(
    // 認証成功時の処理
    data: (auth) async {
      // 認証情報がnullの場合はエラー
      if (auth == null) {
        throw Exception('Not authenticated');
      }

      final playlistService = ref.read(playlistServiceProvider);
      final authService = ref.read(authServiceProvider);

      // トークンが期限切れの場合はリフレッシュ
      if (auth.isExpired) {
        final refreshedAuth = await authService.refreshToken(auth.refreshToken);
        ref.read(authProvider.notifier).refreshAuth(refreshedAuth.refreshToken);
        return playlistService.getPlaylistTracks(
          refreshedAuth.accessToken,
          playlistId,
        );
      }

      // 通常のトークンでトラック一覧を取得
      return playlistService.getPlaylistTracks(auth.accessToken, playlistId);
    },
    // ローディング中はエラーをスロー
    loading: () => throw Exception('Authentication loading'),
    // エラー時はそのままエラーを伝播
    error: (error, stack) => throw error,
  );
});
