import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../providers/playlist_providers.dart';
import '../widgets/track_list_item.dart';
import '../../../shared/constants/app_colors.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(playlistTracksProvider(playlist.id));

    return Scaffold(
      backgroundColor: AppColors.spotifyBlack,
      body: CustomScrollView(
        slivers: [
          // App Bar with playlist header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
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
                  // Playlist image
                  if (playlist.imageUrl != null)
                    Image.network(
                      playlist.imageUrl!,
                      fit: BoxFit.cover,
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
                  else
                    Container(
                      color: AppColors.darkGray,
                      child: const Icon(
                        Icons.music_note,
                        color: AppColors.white54,
                        size: 80,
                      ),
                    ),
                  // Gradient overlay
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
          // Playlist info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          // Tracks list
          tracksAsync.when(
            data: (tracks) {
              if (tracks.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No tracks in this playlist',
                      style: TextStyle(color: AppColors.white70, fontSize: 16),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return TrackListItem(track: tracks[index], index: index);
                }, childCount: tracks.length),
              );
            },
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
    );
  }
}
