import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_albumer/features/playlist_detail/models/album_info.dart';
import 'package:spotify_albumer/features/playlist_detail/widgets/album_list_item.dart';

void main() {
  group('AlbumListItem', () {
    late AlbumInfo testAlbum;

    setUp(() {
      testAlbum = AlbumInfo(
        id: 'album123',
        title: 'Test Album',
        type: 'album',
        imageUrl: 'https://example.com/album.jpg',
        totalTracks: 12,
        releaseDate: '2023-01-15',
        totalDurationMs: 3600000, // 1:00:00
        artists: ['Artist 1', 'Artist 2'],
      );
    });

    testWidgets('アルバム情報を正しく表示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AlbumListItem(album: testAlbum))),
      );

      // アルバムタイトルを確認
      expect(find.text('Test Album'), findsOneWidget);

      // アーティスト名を確認
      expect(find.text('Artist 1, Artist 2'), findsOneWidget);

      // 総トラック数を確認
      expect(find.textContaining('12'), findsAtLeastNWidgets(1));

      // リリース日を確認
      expect(find.text('2023-01-15'), findsOneWidget);

      // 再生時間を確認
      expect(find.text('1:00:00'), findsOneWidget);
    });

    testWidgets('画像URLがない場合はアイコンを表示', (tester) async {
      final albumWithoutImage = AlbumInfo(
        id: 'album456',
        title: 'No Image Album',
        type: 'album',
        totalTracks: 10,
        releaseDate: '2023-02-01',
        totalDurationMs: 1800000,
        artists: ['Artist'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AlbumListItem(album: albumWithoutImage)),
        ),
      );

      // アルバムアイコンを確認
      expect(find.byIcon(Icons.album), findsOneWidget);
    });

    testWidgets('シングルバッジを表示', (tester) async {
      final singleAlbum = AlbumInfo(
        id: 'single123',
        title: 'Test Single',
        type: 'single',
        totalTracks: 1,
        releaseDate: '2023-03-01',
        totalDurationMs: 180000,
        artists: ['Artist'],
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AlbumListItem(album: singleAlbum))),
      );

      // SINGLEバッジを確認
      expect(find.text('SINGLE'), findsOneWidget);
    });

    testWidgets('EPバッジを表示', (tester) async {
      final epAlbum = AlbumInfo(
        id: 'ep123',
        title: 'Test EP',
        type: 'album',
        totalTracks: 5, // 4-6曲でEP
        releaseDate: '2023-04-01',
        totalDurationMs: 900000,
        artists: ['Artist'],
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AlbumListItem(album: epAlbum))),
      );

      // EPバッジを確認
      expect(find.text('EP'), findsOneWidget);
    });

    testWidgets('コンピレーションバッジを表示', (tester) async {
      final compilationAlbum = AlbumInfo(
        id: 'comp123',
        title: 'Best Hits',
        type: 'compilation',
        totalTracks: 20,
        releaseDate: '2023-05-01',
        totalDurationMs: 3600000,
        artists: ['Various Artists'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AlbumListItem(album: compilationAlbum)),
        ),
      );

      // COMPILATIONバッジを確認
      expect(find.text('COMPILATION'), findsOneWidget);
    });

    testWidgets('通常のアルバムにはバッジを表示しない', (tester) async {
      // 7曲以上の通常アルバム
      final normalAlbum = AlbumInfo(
        id: 'album789',
        title: 'Normal Album',
        type: 'album',
        totalTracks: 10,
        releaseDate: '2023-06-01',
        totalDurationMs: 2400000,
        artists: ['Artist'],
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AlbumListItem(album: normalAlbum))),
      );

      // バッジが表示されないことを確認
      expect(find.text('SINGLE'), findsNothing);
      expect(find.text('EP'), findsNothing);
      expect(find.text('COMPILATION'), findsNothing);
    });

    testWidgets('レーベル名がある場合は表示', (tester) async {
      final albumWithLabel = AlbumInfo(
        id: 'album999',
        title: 'Album with Label',
        type: 'album',
        totalTracks: 10,
        releaseDate: '2023-07-01',
        totalDurationMs: 1800000,
        artists: ['Artist'],
        label: 'Test Records',
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AlbumListItem(album: albumWithLabel))),
      );

      // レーベル名を確認
      expect(find.text('Test Records'), findsOneWidget);
    });

    testWidgets('長いアルバム名を省略表示', (tester) async {
      final longTitleAlbum = AlbumInfo(
        id: 'album_long',
        title: 'This is a very long album title that should be truncated',
        type: 'album',
        totalTracks: 10,
        releaseDate: '2023-08-01',
        totalDurationMs: 1800000,
        artists: ['Artist'],
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AlbumListItem(album: longTitleAlbum))),
      );

      final textFinder = find.text(
        'This is a very long album title that should be truncated',
      );
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 2);
    });

    testWidgets('情報アイコンを正しく表示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AlbumListItem(album: testAlbum))),
      );

      // 各情報アイコンを確認
      expect(find.byIcon(Icons.access_time), findsOneWidget); // Duration
      expect(find.byIcon(Icons.music_note), findsOneWidget); // Tracks
      expect(find.byIcon(Icons.calendar_today), findsOneWidget); // Released
    });

    testWidgets('カードウィジェットとして表示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AlbumListItem(album: testAlbum))),
      );

      // Cardウィジェットを確認
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
