import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_albumer/features/playlist_detail/models/track.dart';

void main() {
  group('Track', () {
    group('fromJson', () {
      test('正常なJSONから Track を作成', () {
        final json = {
          'track': {
            'id': 'track123',
            'name': 'Test Track',
            'artists': [
              {'name': 'Artist 1'},
              {'name': 'Artist 2'},
            ],
            'album': {
              'id': 'album123',
              'name': 'Test Album',
              'album_type': 'album',
              'total_tracks': 12,
              'release_date': '2023-01-15',
              'images': [
                {'url': 'https://example.com/image.jpg'},
              ],
            },
            'duration_ms': 180000,
            'uri': 'spotify:track:track123',
          },
        };

        final track = Track.fromJson(json);

        expect(track.id, 'track123');
        expect(track.name, 'Test Track');
        expect(track.artists, ['Artist 1', 'Artist 2']);
        expect(track.albumName, 'Test Album');
        expect(track.albumId, 'album123');
        expect(track.albumType, 'album');
        expect(track.albumTotalTracks, 12);
        expect(track.albumReleaseDate, '2023-01-15');
        expect(track.albumImageUrl, 'https://example.com/image.jpg');
        expect(track.durationMs, 180000);
        expect(track.uri, 'spotify:track:track123');
      });

      test('trackキーなしのJSONから Track を作成', () {
        final json = {
          'id': 'track456',
          'name': 'Direct Track',
          'artists': [
            {'name': 'Solo Artist'},
          ],
          'album': {
            'id': 'album456',
            'name': 'Direct Album',
            'album_type': 'single',
            'total_tracks': 1,
            'release_date': '2023-06-01',
            'images': [],
          },
          'duration_ms': 120000,
          'uri': 'spotify:track:track456',
        };

        final track = Track.fromJson(json);

        expect(track.id, 'track456');
        expect(track.name, 'Direct Track');
        expect(track.artists, ['Solo Artist']);
        expect(track.albumName, 'Direct Album');
        expect(track.albumId, 'album456');
        expect(track.albumType, 'single');
        expect(track.albumImageUrl, isNull);
        expect(track.durationMs, 120000);
        expect(track.uri, 'spotify:track:track456');
      });

      test('不完全なJSONからデフォルト値で Track を作成', () {
        final json = {
          'track': {'id': '', 'artists': null, 'album': null},
        };

        final track = Track.fromJson(json);

        expect(track.id, '');
        expect(track.name, 'Unknown Track');
        expect(track.artists, ['Unknown Artist']);
        expect(track.albumName, 'Unknown Album');
        expect(track.albumId, '');
        expect(track.albumType, 'album');
        expect(track.albumTotalTracks, 0);
        expect(track.albumReleaseDate, '');
        expect(track.albumImageUrl, isNull);
        expect(track.durationMs, 0);
        expect(track.uri, '');
      });

      test('画像がない場合は null を返す', () {
        final json = {
          'track': {
            'id': 'track789',
            'name': 'No Image Track',
            'artists': [
              {'name': 'Artist'},
            ],
            'album': {
              'id': 'album789',
              'name': 'Album',
              'album_type': 'album',
              'total_tracks': 10,
              'release_date': '2023-03-20',
              'images': [],
            },
            'duration_ms': 60000,
            'uri': 'spotify:track:track789',
          },
        };

        final track = Track.fromJson(json);

        expect(track.albumImageUrl, isNull);
      });
    });

    group('formattedDuration', () {
      test('180秒 (3分) を "3:00" としてフォーマット', () {
        final track = Track(
          id: 'test',
          name: 'Test',
          artists: ['Artist'],
          albumName: 'Album',
          albumId: 'album1',
          albumType: 'album',
          albumTotalTracks: 10,
          albumReleaseDate: '2023-01-01',
          durationMs: 180000,
          uri: 'spotify:track:test',
        );

        expect(track.formattedDuration, '3:00');
      });

      test('195秒 (3分15秒) を "3:15" としてフォーマット', () {
        final track = Track(
          id: 'test',
          name: 'Test',
          artists: ['Artist'],
          albumName: 'Album',
          albumId: 'album1',
          albumType: 'album',
          albumTotalTracks: 10,
          albumReleaseDate: '2023-01-01',
          durationMs: 195000,
          uri: 'spotify:track:test',
        );

        expect(track.formattedDuration, '3:15');
      });

      test('65秒 (1分5秒) を "1:05" としてフォーマット', () {
        final track = Track(
          id: 'test',
          name: 'Test',
          artists: ['Artist'],
          albumName: 'Album',
          albumId: 'album1',
          albumType: 'album',
          albumTotalTracks: 10,
          albumReleaseDate: '2023-01-01',
          durationMs: 65000,
          uri: 'spotify:track:test',
        );

        expect(track.formattedDuration, '1:05');
      });

      test('0秒を "0:00" としてフォーマット', () {
        final track = Track(
          id: 'test',
          name: 'Test',
          artists: ['Artist'],
          albumName: 'Album',
          albumId: 'album1',
          albumType: 'album',
          albumTotalTracks: 10,
          albumReleaseDate: '2023-01-01',
          durationMs: 0,
          uri: 'spotify:track:test',
        );

        expect(track.formattedDuration, '0:00');
      });
    });

    group('artistsString', () {
      test('単一アーティストをそのまま返す', () {
        final track = Track(
          id: 'test',
          name: 'Test',
          artists: ['Solo Artist'],
          albumName: 'Album',
          albumId: 'album1',
          albumType: 'album',
          albumTotalTracks: 10,
          albumReleaseDate: '2023-01-01',
          durationMs: 180000,
          uri: 'spotify:track:test',
        );

        expect(track.artistsString, 'Solo Artist');
      });

      test('複数アーティストをカンマ区切りで結合', () {
        final track = Track(
          id: 'test',
          name: 'Test',
          artists: ['Artist 1', 'Artist 2', 'Artist 3'],
          albumName: 'Album',
          albumId: 'album1',
          albumType: 'album',
          albumTotalTracks: 10,
          albumReleaseDate: '2023-01-01',
          durationMs: 180000,
          uri: 'spotify:track:test',
        );

        expect(track.artistsString, 'Artist 1, Artist 2, Artist 3');
      });

      test('空のアーティストリストで空文字列を返す', () {
        final track = Track(
          id: 'test',
          name: 'Test',
          artists: [],
          albumName: 'Album',
          albumId: 'album1',
          albumType: 'album',
          albumTotalTracks: 10,
          albumReleaseDate: '2023-01-01',
          durationMs: 180000,
          uri: 'spotify:track:test',
        );

        expect(track.artistsString, '');
      });
    });
  });
}
