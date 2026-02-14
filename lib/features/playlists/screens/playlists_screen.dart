import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/playlists_provider.dart';
import '../widgets/playlist_card.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/constants/app_colors.dart';

/// プレイリスト一覧画面
/// ユーザーのSpotifyプレイリスト（自分が作成したものとフォローしているもの）を表示
class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プレイリストの非同期状態を監視
    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      appBar: AppBar(
        title: const Text(
          'Your Playlists',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.spotifyBlack,
        elevation: 0,
        actions: [
          // ログアウトボタン
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      // AsyncValueの状態によって異なるUIを表示
      body: playlistsAsync.when(
        // データ取得成功時
        data: (playlists) {
          if (playlists.isEmpty) {
            return const Center(
              child: Text(
                'No playlists found',
                style: TextStyle(color: AppColors.white70, fontSize: 18),
              ),
            );
          }

          // 引き下げ更新機能付きのプレイリスト一覧
          return RefreshIndicator(
            onRefresh: () => ref.refresh(playlistsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return PlaylistCard(playlist: playlists[index]);
              },
            ),
          );
        },
        // ローディング中
        loading:
            () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.spotifyGreen,
                ),
              ),
            ),
        // エラー発生時
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading playlists:\n${error.toString()}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // 再試行ボタン
                  ElevatedButton(
                    onPressed: () => ref.refresh(playlistsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.spotifyGreen,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
