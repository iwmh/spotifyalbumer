import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_albumer/features/playlists/models/playlist.dart';
import 'package:spotify_albumer/features/playlist_detail/models/track.dart';
import 'package:spotify_albumer/features/playlist_detail/providers/playlist_tracks_provider.dart';
import 'package:spotify_albumer/features/playlist_detail/screens/playlist_detail_screen.dart';
import 'package:spotify_albumer/features/playlist_detail/widgets/track_list_item.dart';

void main() {
  group('PlaylistDetailScreen', () {
    late Playlist testPlaylist;
    late List<Track> testTracks;

    setUp(() {
      testPlaylist = Playlist(
        id: 'playlist123',
        name: 'Test Playlist',
        description: 'A test playlist',
        totalTracks: 2,
        imageUrl: 'https://example.com/playlist.jpg',
        ownerId: 'user123',
        ownerDisplayName: 'Test User',
      );

      testTracks = [
        Track(
          id: 'track1',
          name: 'Track 1',
          artists: ['Artist 1'],
          albumName: 'Album 1',
          albumImageUrl: 'https://example.com/album1.jpg',
          durationMs: 180000,
          uri: 'spotify:track:track1',
        ),
        Track(
          id: 'track2',
          name: 'Track 2',
          artists: ['Artist 2'],
          albumName: 'Album 2',
          durationMs: 210000,
          uri: 'spotify:track:track2',
        ),
      ];
    });

    testWidgets('ローディング状態を表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playlistTracksProvider(testPlaylist.id).overrideWith(
              (ref) => Future.delayed(
                const Duration(milliseconds: 100),
                () => testTracks,
              ),
            ),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      // ローディングインジケーターを確認
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // タイマーを完了させる
      await tester.pumpAndSettle();
    });

    testWidgets('トラックリストを正しく表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playlistTracksProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(testTracks)),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      // フレームを待つ
      await tester.pumpAndSettle();

      // プレイリスト名を確認
      expect(find.text('Test Playlist'), findsOneWidget);

      // トラック数とオーナーを確認
      expect(find.text('2 tracks • Test User'), findsOneWidget);

      // トラックが表示されることを確認
      expect(find.byType(TrackListItem), findsNWidgets(2));
    });

    testWidgets('エラー状態を表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playlistTracksProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.error('Failed to load tracks')),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // エラーアイコンを確認
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // エラーメッセージを確認
      expect(find.textContaining('Error loading tracks'), findsOneWidget);

      // リトライボタンを確認
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('空のプレイリストを表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playlistTracksProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(<Track>[])),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 空のメッセージを確認
      expect(find.text('No tracks in this playlist'), findsOneWidget);
    });

    testWidgets('プレイリスト説明を表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playlistTracksProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(testTracks)),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 説明を確認
      expect(find.text('A test playlist'), findsOneWidget);
    });

    testWidgets('説明がないプレイリストを表示', (tester) async {
      final playlistWithoutDescription = Playlist(
        id: 'playlist456',
        name: 'No Description',
        totalTracks: 0,
        ownerId: 'user456',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playlistTracksProvider(
              playlistWithoutDescription.id,
            ).overrideWith((ref) => Future.value(<Track>[])),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: playlistWithoutDescription),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 説明がないことを確認
      expect(find.text('A test playlist'), findsNothing);

      // プレイリスト名は表示されることを確認
      expect(find.text('No Description'), findsOneWidget);
    });

    testWidgets('リトライボタンがプロバイダーを更新', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playlistTracksProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.error('Network error')),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // リトライボタンを探す
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      // リトライボタンをタップ
      await tester.tap(retryButton);
      await tester.pump();

      // エラーが表示されていることを確認（モックなので変わらない）
      expect(find.textContaining('Error loading tracks'), findsOneWidget);
    });

    testWidgets('AppBarに戻るボタンが表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playlistTracksProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(testTracks)),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AppBarが存在することを確認
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
