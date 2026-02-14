import 'package:flutter/material.dart';
import '../models/track.dart';
import '../../../shared/constants/app_colors.dart';

/// トラックリストのアイテムウィジェット
/// プレイリスト詳細画面でトラック情報を表示するためのウィジェット
class TrackListItem extends StatelessWidget {
  /// 表示するトラック情報
  final Track track;

  /// トラックの順番（0始まり）
  final int index;

  const TrackListItem({super.key, required this.track, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // トラック番号を表示
          SizedBox(
            width: 30,
            child: Text(
              '${index + 1}', // 1始まりで表示
              style: const TextStyle(color: AppColors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // アルバムアート
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppColors.darkGray,
            ),
            child:
                track.albumImageUrl != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        track.albumImageUrl!,
                        fit: BoxFit.cover,
                        // 画像読み込みエラー時の代替表示
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.music_note,
                            color: AppColors.white54,
                            size: 24,
                          );
                        },
                      ),
                    )
                    // 画像URLがない場合はアイコンを表示
                    : const Icon(
                      Icons.music_note,
                      color: AppColors.white54,
                      size: 24,
                    ),
          ),
        ],
      ),
      // トラック名
      title: Text(
        track.name,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // アーティスト名（複数の場合はカンマ区切り）
      subtitle: Text(
        track.artistsString,
        style: const TextStyle(color: AppColors.white70, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // 再生時間
      trailing: Text(
        track.formattedDuration,
        style: const TextStyle(color: AppColors.white54, fontSize: 14),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Play: ${track.name}'),
            backgroundColor: AppColors.spotifyGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}
