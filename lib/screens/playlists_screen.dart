import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/spotify_providers.dart';
import '../widgets/playlist_card.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        title: const Text(
          'Your Playlists',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF191414),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: playlistsAsync.when(
        data: (playlists) {
          if (playlists.isEmpty) {
            return const Center(
              child: Text(
                'No playlists found',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            );
          }

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
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
          ),
        ),
        error: (error, stack) => Center(
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
                'Error loading playlists:\n${error.toString()}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(playlistsProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
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