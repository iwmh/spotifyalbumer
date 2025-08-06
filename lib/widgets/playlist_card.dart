import 'package:flutter/material.dart';
import '../models/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const PlaylistCard({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF282828),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF404040),
          ),
          child: playlist.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    playlist.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 28,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.music_note,
                  color: Colors.white54,
                  size: 28,
                ),
        ),
        title: Text(
          playlist.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (playlist.description != null && playlist.description!.isNotEmpty)
              Text(
                playlist.description!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              '${playlist.totalTracks} tracks • ${playlist.ownerDisplayName ?? 'Unknown'}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.more_vert,
          color: Colors.white54,
        ),
        onTap: () {
          // TODO: Navigate to playlist details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${playlist.name}'),
              backgroundColor: const Color(0xFF1DB954),
            ),
          );
        },
      ),
    );
  }
}