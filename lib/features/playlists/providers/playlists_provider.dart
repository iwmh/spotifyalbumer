import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../services/playlist_service.dart';
import '../../auth/providers/auth_providers.dart';

/// PlaylistServiceのプロバイダー
/// シングルトンとしてPlaylistServiceのインスタンスを提供
final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return PlaylistService();
});

/// ユーザーのプレイリスト一覧を取得するプロバイダー
///
/// 自分が作成したプレイリストとフォローしているプレイリストの両方を取得
/// 認証状態を監視し、トークンが期限切れの場合は自動的にリフレッシュする
final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
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
        return playlistService.getUserPlaylists(refreshedAuth.accessToken);
      }

      // 通常のトークンでプレイリスト一覧を取得
      return playlistService.getUserPlaylists(auth.accessToken);
    },
    // ローディング中はエラーをスロー
    loading: () => throw Exception('Authentication loading'),
    // エラー時はそのままエラーを伝播
    error: (error, stack) => throw error,
  );
});
