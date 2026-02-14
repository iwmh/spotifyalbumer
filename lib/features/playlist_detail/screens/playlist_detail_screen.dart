import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../playlists/models/playlist.dart';
import '../../playlists/providers/playlists_provider.dart';
import '../models/album_info.dart';
import '../providers/playlist_albums_provider.dart';
import '../providers/album_quick_add_provider.dart';
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
    // クイック追加先プレイリストを監視
    final quickAddTargetsAsync = ref.watch(quickAddTargetPlaylistsProvider);
    final quickAddState = ref.watch(albumQuickAddProvider);

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
                IconButton(
                  tooltip: 'クイック追加先を設定',
                  onPressed: () async {
                    await _showQuickAddTargetSelector(context, ref);
                  },
                  icon: const Icon(Icons.tune),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Singles',
                        style: TextStyle(
                          color:
                              includeSingles
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
                    const SizedBox(height: 12),
                    quickAddTargetsAsync.when(
                      data: (targets) {
                        if (targets.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.darkGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'クイック追加先が未設定です。右上の設定アイコンからプレイリストを選ぶと、アルバムごとに1タップ追加できます。',
                              style: TextStyle(
                                color: AppColors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const Text(
                                'Quick Add:',
                                style: TextStyle(
                                  color: AppColors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              ...targets.map(
                                (target) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGray,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    target.name,
                                    style: const TextStyle(
                                      color: AppColors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final album = albums[index];

                    // アルバム全体のDurationを取得
                    final fullDurationMsAsync = ref.watch(
                      albumTotalDurationMsProvider(album.id),
                    );

                    final durationText = fullDurationMsAsync.maybeWhen(
                      data: _formatDuration,
                      orElse: () => album.formattedDuration,
                    );

                    final quickAddActions = quickAddTargetsAsync.when(
                      data:
                          (targets) =>
                              targets
                                  .where((target) => target.id != playlist.id)
                                  .map(
                                    (target) => AlbumQuickAddAction(
                                      label: target.name,
                                      isLoading: quickAddState.inFlight
                                          .contains(
                                            _operationKey(album.id, target.id),
                                          ),
                                      isCompleted: quickAddState.completed
                                          .contains(
                                            _operationKey(album.id, target.id),
                                          ),
                                      onPressed: () async {
                                        await _onQuickAddTap(
                                          context,
                                          ref,
                                          album,
                                          target,
                                        );
                                      },
                                    ),
                                  )
                                  .toList(),
                      loading: () => const <AlbumQuickAddAction>[],
                      error: (_, __) => const <AlbumQuickAddAction>[],
                    );

                    return AlbumListItem(
                      album: album,
                      durationText: durationText,
                      quickAddActions: quickAddActions,
                    );
                  }, childCount: albums.length),
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

  static String _operationKey(String albumId, String playlistId) {
    return '$albumId:$playlistId';
  }

  Future<void> _onQuickAddTap(
    BuildContext context,
    WidgetRef ref,
    AlbumInfo album,
    Playlist targetPlaylist,
  ) async {
    try {
      final addedCount = await ref
          .read(albumQuickAddProvider.notifier)
          .addAlbumToPlaylist(
            albumId: album.id,
            targetPlaylistId: targetPlaylist.id,
          );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '「${album.title}」の$addedCount曲を「${targetPlaylist.name}」に追加しました。',
          ),
          backgroundColor: AppColors.spotifyGreen,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('追加に失敗しました: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showQuickAddTargetSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final allPlaylists = await ref.read(playlistsProvider.future);
    final currentTargets =
        ref.read(quickAddTargetIdsProvider).valueOrNull ?? const <String>[];

    if (!context.mounted) return;

    final selectedIds = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: AppColors.spotifyBlack,
      isScrollControlled: true,
      builder: (sheetContext) {
        final working = currentTargets.toSet();

        return StatefulBuilder(
          builder: (context, setState) {
            final selectablePlaylists =
                allPlaylists.where((item) => item.id != playlist.id).toList();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'クイック追加先を選択（最大3件）',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectablePlaylists.length,
                        itemBuilder: (context, index) {
                          final target = selectablePlaylists[index];
                          final selected = working.contains(target.id);
                          final canSelectMore = selected || working.length < 3;

                          return CheckboxListTile(
                            value: selected,
                            activeColor: AppColors.spotifyGreen,
                            checkColor: AppColors.white,
                            title: Text(
                              target.name,
                              style: TextStyle(
                                color:
                                    canSelectMore || selected
                                        ? AppColors.white
                                        : AppColors.white54,
                              ),
                            ),
                            onChanged:
                                canSelectMore
                                    ? (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          working.add(target.id);
                                        } else {
                                          working.remove(target.id);
                                        }
                                      });
                                    }
                                    : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'キャンセル',
                            style: TextStyle(color: AppColors.white70),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.spotifyGreen,
                            foregroundColor: AppColors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(working.toList());
                          },
                          child: const Text('保存'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedIds == null) return;

    await ref.read(quickAddTargetIdsProvider.notifier).setTargets(selectedIds);
  }

  /// ミリ秒からフォーマット済みDuration文字列を生成
  String _formatDuration(int totalDurationMs) {
    final hours = totalDurationMs ~/ 3600000;
    final minutes = (totalDurationMs % 3600000) ~/ 60000;
    final seconds = (totalDurationMs % 60000) ~/ 1000;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
