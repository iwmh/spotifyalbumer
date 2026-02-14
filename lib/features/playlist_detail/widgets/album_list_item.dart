import 'package:flutter/material.dart';
import '../models/album_info.dart';
import '../../../shared/constants/app_colors.dart';

/// アルバムリストのアイテムウィジェット
/// プレイリスト詳細画面でアルバム情報を表示するためのウィジェット
class AlbumListItem extends StatelessWidget {
  /// 表示するアルバム情報
  final AlbumInfo album;

  /// 表示するDurationテキスト（指定がない場合はalbum.formattedDuration）
  final String? durationText;

  /// クイック追加アクションボタン
  final List<AlbumQuickAddAction> quickAddActions;

  const AlbumListItem({
    super.key,
    required this.album,
    this.durationText,
    this.quickAddActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkGray,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アルバムアート
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.spotifyBlack,
              ),
              child:
                  album.imageUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          album.imageUrl!,
                          fit: BoxFit.cover,
                          // 画像読み込みエラー時の代替表示
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.album,
                              color: AppColors.white54,
                              size: 40,
                            );
                          },
                        ),
                      )
                      // 画像URLがない場合はアイコンを表示
                      : const Icon(
                        Icons.album,
                        color: AppColors.white54,
                        size: 40,
                      ),
            ),
            const SizedBox(width: 12),
            // アルバム情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // アルバムタイトル
                  Text(
                    album.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // アーティスト名
                  Text(
                    album.artistsString,
                    style: const TextStyle(
                      color: AppColors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // アルバムの長さ
                  _buildInfoRow(
                    Icons.access_time,
                    'Duration',
                    durationText ?? album.formattedDuration,
                  ),
                  const SizedBox(height: 4),
                  // 総トラック数
                  _buildInfoRow(
                    Icons.music_note,
                    'Tracks',
                    '${album.totalTracks}',
                  ),
                  const SizedBox(height: 4),
                  // リリース日
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Released',
                    album.releaseDate,
                  ),
                  // レーベル名（存在する場合のみ表示）
                  if (album.label != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: _buildInfoRow(Icons.label, 'Label', album.label!),
                    ),
                  // タイプバッジ（シングル、EP、コンピレーションの場合）
                  if (album.isSingle || album.isEP || album.isCompilation)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildTypeBadge(),
                    ),
                  if (quickAddActions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            quickAddActions
                                .map((action) => _buildQuickAddAction(action))
                                .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddAction(AlbumQuickAddAction action) {
    final isCompleted = action.isCompleted;

    return ElevatedButton.icon(
      onPressed: action.isLoading ? null : action.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isCompleted
                ? AppColors.spotifyGreen.withValues(alpha: 0.55)
                : AppColors.darkGray,
        foregroundColor: isCompleted ? AppColors.white : AppColors.white70,
        disabledBackgroundColor:
            isCompleted
                ? AppColors.spotifyGreen.withValues(alpha: 0.4)
                : AppColors.darkGray,
        disabledForegroundColor: AppColors.white54,
        side: BorderSide(
          color: isCompleted ? AppColors.spotifyGreen : AppColors.white54,
        ),
        elevation: 0,
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(44, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      icon:
          action.isLoading
              ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
              : Icon(isCompleted ? Icons.check : Icons.playlist_add, size: 16),
      label: Text(
        action.label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// タイプバッジを構築するヘルパーメソッド
  Widget _buildTypeBadge() {
    String label;
    Color color;

    if (album.isSingle) {
      label = 'SINGLE';
      color = AppColors.spotifyGreen;
    } else if (album.isEP) {
      label = 'EP';
      color = Colors.orange;
    } else if (album.isCompilation) {
      label = 'COMPILATION';
      color = Colors.purple;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 情報行を構築するヘルパーメソッド
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.white54),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.white54, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class AlbumQuickAddAction {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isCompleted;

  const AlbumQuickAddAction({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isCompleted = false,
  });
}
