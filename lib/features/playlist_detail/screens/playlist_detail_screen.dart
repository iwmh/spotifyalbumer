import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../playlists/models/playlist.dart';
import '../providers/playlist_tracks_provider.dart';
import '../widgets/track_list_item.dart';
import '../../../shared/constants/app_colors.dart';

/// プレイリスト詳細画面
/// プレイリストに含まれるトラックの一覧を表示する
class PlaylistDetailScreen extends ConsumerWidget {
  /// 表示するプレイリスト情報
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プレイリストのトラック一覧を監視
    final tracksAsync = ref.watch(playlistTracksProvider(playlist.id));

    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      // CustomScrollViewを使用してスクロール可能なレイアウトを構築
      body: RefreshIndicator(
        // 引き下げ更新時の処理
        onRefresh: () async {
          // プロバイダーをリフレッシュしてトラック一覧を再取得
          ref.invalidate(playlistTracksProvider(playlist.id));
          // リフレッシュが完了するまで待機
          await ref.read(playlistTracksProvider(playlist.id).future);
        },
        color: AppColors.spotifyGreen,
        backgroundColor: AppColors.darkGray,
        child: CustomScrollView(
          slivers: [
            // 拡張可能なアプリバー（プレイリストヘッダー）
            SliverAppBar(
              expandedHeight: 300,
              pinned: true, // スクロール時も表示を維持
              backgroundColor: AppColors.spotifyBlack,
              iconTheme: const IconThemeData(color: AppColors.white),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  playlist.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // プレイリスト画像
                    if (playlist.imageUrl != null)
                      Image.network(
                        playlist.imageUrl!,
                        fit: BoxFit.cover,
                        // 画像読み込みエラー時の代替表示
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.darkGray,
                            child: const Icon(
                              Icons.music_note,
                              color: AppColors.white54,
                              size: 80,
                            ),
                          );
                        },
                      )
                    // 画像URLがない場合はアイコンを表示
                    else
                      Container(
                        color: AppColors.darkGray,
                        child: const Icon(
                          Icons.music_note,
                          color: AppColors.white54,
                          size: 80,
                        ),
                      ),
                    // グラデーションオーバーレイ（読みやすさ向上のため）
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // プレイリスト情報
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // プレイリスト説明（存在する場合のみ表示）
                    if (playlist.description != null &&
                        playlist.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          playlist.description!,
                          style: const TextStyle(
                            color: AppColors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    // トラック数とオーナー情報
                    Text(
                      '${playlist.totalTracks} tracks • ${playlist.ownerDisplayName ?? 'Unknown'}',
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // トラックリスト
            tracksAsync.when(
              // データ取得成功時
              data: (tracks) {
                // トラックが空の場合のメッセージ
                if (tracks.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No tracks in this playlist',
                        style: TextStyle(
                          color: AppColors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }

                // トラック一覧を表示
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return TrackListItem(track: tracks[index], index: index);
                  }, childCount: tracks.length),
                );
              },
              // ローディング中
              loading:
                  () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.spotifyGreen,
                        ),
                      ),
                    ),
                  ),
              // エラー発生時
              error:
                  (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading tracks:\n${error.toString()}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // リトライボタン
                          ElevatedButton(
                            onPressed:
                                () => ref.refresh(
                                  playlistTracksProvider(playlist.id),
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.spotifyGreen,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
