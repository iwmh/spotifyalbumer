import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../../playlist_detail/screens/playlist_detail_screen.dart';
import '../../../shared/constants/app_colors.dart';

/// プレイリストカードウィジェット
/// プレイリスト一覧画面で各プレイリストを表示するカード
class PlaylistCard extends StatelessWidget {
  /// 表示するプレイリスト
  final Playlist playlist;

  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        // プレイリスト画像
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.darkGray,
          ),
          child:
              playlist.imageUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      playlist.imageUrl!,
                      fit: BoxFit.cover,
                      // 画像の読み込みエラー時のフォールバック
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.music_note,
                          color: AppColors.white54,
                          size: 28,
                        );
                      },
                    ),
                  )
                  : const Icon(
                    Icons.music_note,
                    color: AppColors.white54,
                    size: 28,
                  ),
        ),
        // プレイリスト名
        title: Text(
          playlist.name,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // プレイリストの説明とメタ情報
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プレイリストの説明（存在する場合）
            if (playlist.description != null &&
                playlist.description!.isNotEmpty)
              Text(
                playlist.description!,
                style: const TextStyle(color: AppColors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            // トラック数と所有者情報
            Text(
              '${playlist.totalTracks} tracks • ${playlist.ownerDisplayName ?? 'Unknown'}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        // タップ時にプレイリスト詳細画面へ遷移
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlaylistDetailScreen(playlist: playlist),
            ),
          );
        },
      ),
    );
  }
}
