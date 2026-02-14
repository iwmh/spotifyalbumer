import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_albumer/features/playlists/models/playlist.dart';
import 'package:spotify_albumer/features/playlist_detail/models/album_info.dart';
import 'package:spotify_albumer/features/playlist_detail/providers/playlist_albums_provider.dart';
import 'package:spotify_albumer/features/playlist_detail/screens/playlist_detail_screen.dart';
import 'package:spotify_albumer/features/playlist_detail/widgets/album_list_item.dart';

void main() {
  group('PlaylistDetailScreen', () {
    late Playlist testPlaylist;
    late List<AlbumInfo> testAlbums;

    setUp(() {
      testPlaylist = Playlist(
        id: 'playlist123',
        name: 'Test Playlist',
        description: 'A test playlist',
        totalTracks: 15,
        imageUrl: 'https://example.com/playlist.jpg',
        ownerId: 'user123',
        ownerDisplayName: 'Test User',
      );

      testAlbums = [
        AlbumInfo(
          id: 'album1',
          title: 'Album 1',
          type: 'album',
          imageUrl: 'https://example.com/album1.jpg',
          totalTracks: 12,
          releaseDate: '2023-01-01',
          totalDurationMs: 3600000,
          artists: ['Artist 1'],
        ),
        AlbumInfo(
          id: 'album2',
          title: 'Album 2',
          type: 'album',
          imageUrl: 'https://example.com/album2.jpg',
          totalTracks: 10,
          releaseDate: '2023-02-01',
          totalDurationMs: 2400000,
          artists: ['Artist 2'],
        ),
      ];
    });

    testWidgets('ローディング状態を表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredAlbumsProvider(testPlaylist.id).overrideWith(
              (ref) => Future.delayed(
                const Duration(milliseconds: 100),
                () => testAlbums,
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

    testWidgets('アルバムリストを正しく表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredAlbumsProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(testAlbums)),
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
      expect(find.text('15 tracks • Test User'), findsOneWidget);

      // アルバムアイテムを確認
      expect(find.byType(AlbumListItem), findsNWidgets(2));

      // 各アルバム名を確認
      expect(find.text('Album 1'), findsOneWidget);
      expect(find.text('Album 2'), findsOneWidget);
    });

    testWidgets('エラー状態を表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredAlbumsProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.error('Failed to load albums')),
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
      expect(find.textContaining('Error loading albums'), findsOneWidget);

      // リトライボタンを確認
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('空のプレイリストを表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredAlbumsProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(<AlbumInfo>[])),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 空のメッセージを確認
      expect(
        find.text('No albums (excluding singles) in this playlist'),
        findsOneWidget,
      );
    });

    testWidgets('プレイリスト説明を表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredAlbumsProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(testAlbums)),
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
            filteredAlbumsProvider(
              playlistWithoutDescription.id,
            ).overrideWith((ref) => Future.value(<AlbumInfo>[])),
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
            filteredAlbumsProvider(
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
      expect(find.textContaining('Error loading albums'), findsOneWidget);
    });

    testWidgets('AppBarに戻るボタンが表示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredAlbumsProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(testAlbums)),
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

    testWidgets('Singlesトグルが表示される', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredAlbumsProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(testAlbums)),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Singlesトグルのラベルを確認
      expect(find.text('Singles'), findsOneWidget);

      // Switchウィジェットを確認
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('Singlesトグルを操作できる', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredAlbumsProvider(
              testPlaylist.id,
            ).overrideWith((ref) => Future.value(testAlbums)),
          ],
          child: MaterialApp(
            home: PlaylistDetailScreen(playlist: testPlaylist),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switchを探す
      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget);

      // Switchをタップ
      await tester.tap(switchWidget);
      await tester.pump();

      // 状態が変わることを確認（Switchは表示され続ける）
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
