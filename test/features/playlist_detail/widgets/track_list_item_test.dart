import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_albumer/features/playlist_detail/models/track.dart';
import 'package:spotify_albumer/features/playlist_detail/widgets/track_list_item.dart';

void main() {
  group('TrackListItem', () {
    late Track testTrack;

    setUp(() {
      testTrack = Track(
        id: 'track123',
        name: 'Test Track',
        artists: ['Artist 1', 'Artist 2'],
        albumName: 'Test Album',
        albumImageUrl: 'https://example.com/album.jpg',
        durationMs: 195000, // 3:15
        uri: 'spotify:track:track123',
      );
    });

    testWidgets('トラック情報を正しく表示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TrackListItem(track: testTrack, index: 0)),
        ),
      );

      // トラック番号を確認
      expect(find.text('1'), findsOneWidget);

      // トラック名を確認
      expect(find.text('Test Track'), findsOneWidget);

      // アーティスト名を確認
      expect(find.text('Artist 1, Artist 2'), findsOneWidget);

      // 再生時間を確認
      expect(find.text('3:15'), findsOneWidget);
    });

    testWidgets('画像URLがない場合はアイコンを表示', (tester) async {
      final trackWithoutImage = Track(
        id: 'track456',
        name: 'No Image Track',
        artists: ['Artist'],
        albumName: 'Album',
        durationMs: 120000,
        uri: 'spotify:track:track456',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrackListItem(track: trackWithoutImage, index: 5),
          ),
        ),
      );

      // トラック番号を確認
      expect(find.text('6'), findsOneWidget);

      // 音楽アイコンを確認
      expect(find.byIcon(Icons.music_note), findsOneWidget);
    });

    testWidgets('タップでスナックバーを表示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TrackListItem(track: testTrack, index: 0)),
        ),
      );

      // トラックをタップ
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // スナックバーが表示されることを確認
      expect(find.text('Play: Test Track'), findsOneWidget);
    });

    testWidgets('複数のトラックで異なる番号を表示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TrackListItem(track: testTrack, index: 0),
                TrackListItem(track: testTrack, index: 1),
                TrackListItem(track: testTrack, index: 9),
              ],
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('長いトラック名を省略表示', (tester) async {
      final longNameTrack = Track(
        id: 'track789',
        name: 'This is a very long track name that should be truncated',
        artists: ['Artist'],
        albumName: 'Album',
        durationMs: 180000,
        uri: 'spotify:track:track789',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TrackListItem(track: longNameTrack, index: 0)),
        ),
      );

      final textFinder = find.text(
        'This is a very long track name that should be truncated',
      );
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });

    testWidgets('異なる再生時間を正しくフォーマット', (tester) async {
      final shortTrack = Track(
        id: 'short',
        name: 'Short',
        artists: ['Artist'],
        albumName: 'Album',
        durationMs: 65000, // 1:05
        uri: 'spotify:track:short',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TrackListItem(track: shortTrack, index: 0)),
        ),
      );

      expect(find.text('1:05'), findsOneWidget);
    });
  });
}
