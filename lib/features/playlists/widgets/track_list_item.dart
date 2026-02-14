import 'package:flutter/material.dart';
import '../models/track.dart';
import '../../../shared/constants/app_colors.dart';

class TrackListItem extends StatelessWidget {
  final Track track;
  final int index;

  const TrackListItem({super.key, required this.track, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Track number
          SizedBox(
            width: 30,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: AppColors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Album art
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
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.music_note,
                            color: AppColors.white54,
                            size: 24,
                          );
                        },
                      ),
                    )
                    : const Icon(
                      Icons.music_note,
                      color: AppColors.white54,
                      size: 24,
                    ),
          ),
        ],
      ),
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
      subtitle: Text(
        track.artistsString,
        style: const TextStyle(color: AppColors.white70, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        track.formattedDuration,
        style: const TextStyle(color: AppColors.white54, fontSize: 14),
      ),
      onTap: () {
        // TODO: Implement play track functionality
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
