import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../playlists/models/playlist.dart';
import '../providers/playlist_albums_provider.dart';
import '../widgets/album_list_item.dart';
import '../../../shared/constants/app_colors.dart';

/// プレイリスト詳細画面
/// プレイリストに含まれるトラックから抽出したアルバムの一覧を表示する
class PlaylistDetailScreen extends ConsumerWidget {
  /// 表示するプレイリスト情報
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プレイリストのアルバム一覧を監視
    final albumsAsync = ref.watch(filteredAlbumsProvider(playlist.id));
    // シングル表示状態を監視
    final includeSingles = ref.watch(includeSinglesProvider);

    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      // CustomScrollViewを使用してスクロール可能なレイアウトを構築
      body: RefreshIndicator(
        // 引き下げ更新時の処理
        onRefresh: () async {
          // プロバイダーをリフレッシュしてアルバム一覧を再取得
          ref.invalidate(playlistAlbumsProvider(playlist.id));
          // リフレッシュが完了するまで待機
          await ref.read(filteredAlbumsProvider(playlist.id).future);
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
              // Show Singlesトグルをactionsに配置
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Singles',
                        style: TextStyle(
                          color: includeSingles
                              ? AppColors.spotifyGreen
                              : AppColors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: includeSingles,
                        onChanged: (value) {
                          ref.read(includeSinglesProvider.notifier).state =
                              value;
                        },
                        activeColor: AppColors.spotifyGreen,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ],
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
                  ],
                ),
              ),
            ),
            // アルバムリスト
            albumsAsync.when(
              // データ取得成功時
              data: (albums) {
                // アルバムが空の場合のメッセージ
                if (albums.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        includeSingles
                            ? 'No albums in this playlist'
                            : 'No albums (excluding singles) in this playlist',
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // アルバム一覧を表示
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AlbumListItem(album: albums[index]);
                    },
                    childCount: albums.length,
                  ),
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
                            'Error loading albums:\n${error.toString()}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // リトライボタン
                          ElevatedButton(
                            onPressed:
                                () => ref.refresh(
                                  playlistAlbumsProvider(playlist.id),
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
