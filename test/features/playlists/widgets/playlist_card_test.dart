import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_albumer/features/playlists/models/playlist.dart';
import 'package:spotify_albumer/features/playlists/screens/playlist_detail_screen.dart';
import 'package:spotify_albumer/features/playlists/widgets/playlist_card.dart';

void main() {
  group('PlaylistCard', () {
    late Playlist testPlaylist;

    setUp(() {
      testPlaylist = Playlist(
        id: 'playlist123',
        name: 'Test Playlist',
        description: 'A test playlist description',
        totalTracks: 25,
        imageUrl: 'https://example.com/playlist.jpg',
        ownerId: 'user123',
        ownerDisplayName: 'Test User',
      );
    });

    testWidgets('プレイリスト情報を正しく表示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PlaylistCard(playlist: testPlaylist))),
      );

      // プレイリスト名を確認
      expect(find.text('Test Playlist'), findsOneWidget);

      // 説明を確認
      expect(find.text('A test playlist description'), findsOneWidget);

      // トラック数とオーナーを確認
      expect(find.text('25 tracks • Test User'), findsOneWidget);
    });

    testWidgets('画像URLがない場合はアイコンを表示', (tester) async {
      final playlistWithoutImage = Playlist(
        id: 'playlist456',
        name: 'No Image Playlist',
        totalTracks: 10,
        ownerId: 'user456',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlaylistCard(playlist: playlistWithoutImage)),
        ),
      );

      // 音楽アイコンを確認
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('説明がない場合は表示しない', (tester) async {
      final playlistWithoutDescription = Playlist(
        id: 'playlist789',
        name: 'No Description',
        totalTracks: 5,
        ownerId: 'user789',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaylistCard(playlist: playlistWithoutDescription),
          ),
        ),
      );

      // 説明がないことを確認
      expect(find.text('A test playlist description'), findsNothing);

      // プレイリスト名は表示されることを確認
      expect(find.text('No Description'), findsOneWidget);
    });

    testWidgets('オーナー名がない場合は "Unknown" を表示', (tester) async {
      final playlistWithoutOwner = Playlist(
        id: 'playlist000',
        name: 'No Owner',
        totalTracks: 15,
        ownerId: 'user000',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlaylistCard(playlist: playlistWithoutOwner)),
        ),
      );

      // "Unknown" が表示されることを確認
      expect(find.text('15 tracks • Unknown'), findsOneWidget);
    });

    testWidgets('タップで詳細画面に遷移', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PlaylistCard(playlist: testPlaylist)),
          ),
        ),
      );

      // カードをタップ
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // 詳細画面が表示されることを確認
      expect(find.byType(PlaylistDetailScreen), findsOneWidget);
    });

    testWidgets('右矢印アイコンを表示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PlaylistCard(playlist: testPlaylist))),
      );

      // 右矢印アイコンを確認
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('長いプレイリスト名を省略表示', (tester) async {
      final longNamePlaylist = Playlist(
        id: 'long',
        name: 'This is a very long playlist name that should be truncated',
        totalTracks: 100,
        ownerId: 'user',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlaylistCard(playlist: longNamePlaylist)),
        ),
      );

      final textFinder = find.text(
        'This is a very long playlist name that should be truncated',
      );
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });

    testWidgets('空の説明は表示しない', (tester) async {
      final emptyDescriptionPlaylist = Playlist(
        id: 'empty',
        name: 'Empty Description',
        description: '',
        totalTracks: 5,
        ownerId: 'user',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaylistCard(playlist: emptyDescriptionPlaylist),
          ),
        ),
      );

      // プレイリスト名は表示されることを確認
      expect(find.text('Empty Description'), findsOneWidget);

      // トラック情報が表示されることを確認
      expect(find.text('5 tracks • Unknown'), findsOneWidget);
    });
  });
}
