import 'package:flutter_test/flutter_test.dart';
import 'package:spotify_albumer/features/playlist_detail/models/album_info.dart';
import 'package:spotify_albumer/features/playlist_detail/models/track.dart';

void main() {
  group('AlbumInfo', () {
    group('fromTracks', () {
      test('トラックリストからアルバム情報を作成', () {
        final tracks = [
          Track(
            id: 'track1',
            name: 'Track 1',
            artists: ['Artist 1', 'Artist 2'],
            albumName: 'Test Album',
            albumId: 'album123',
            albumType: 'album',
            albumTotalTracks: 12,
            albumReleaseDate: '2023-01-15',
            albumImageUrl: 'https://example.com/image.jpg',
            durationMs: 180000,
            uri: 'spotify:track:track1',
          ),
          Track(
            id: 'track2',
            name: 'Track 2',
            artists: ['Artist 1', 'Artist 3'],
            albumName: 'Test Album',
            albumId: 'album123',
            albumType: 'album',
            albumTotalTracks: 12,
            albumReleaseDate: '2023-01-15',
            durationMs: 210000,
            uri: 'spotify:track:track2',
          ),
        ];

        final album = AlbumInfo.fromTracks(tracks);

        expect(album.id, 'album123');
        expect(album.title, 'Test Album');
        expect(album.type, 'album');
        expect(album.imageUrl, 'https://example.com/image.jpg');
        expect(album.totalTracks, 12);
        expect(album.releaseDate, '2023-01-15');
        expect(album.totalDurationMs, 390000); // 180000 + 210000
        expect(
          album.artists,
          containsAll(['Artist 1', 'Artist 2', 'Artist 3']),
        );
        expect(album.label, isNull);
      });

      test('空のトラックリストでエラーをスロー', () {
        expect(() => AlbumInfo.fromTracks([]), throwsA(isA<ArgumentError>()));
      });

      test('重複するアーティストを除外', () {
        final tracks = [
          Track(
            id: 'track1',
            name: 'Track 1',
            artists: ['Artist 1', 'Artist 2'],
            albumName: 'Test Album',
            albumId: 'album123',
            albumType: 'album',
            albumTotalTracks: 10,
            albumReleaseDate: '2023-01-01',
            durationMs: 180000,
            uri: 'spotify:track:track1',
          ),
          Track(
            id: 'track2',
            name: 'Track 2',
            artists: ['Artist 1', 'Artist 2'], // 同じアーティスト
            albumName: 'Test Album',
            albumId: 'album123',
            albumType: 'album',
            albumTotalTracks: 10,
            albumReleaseDate: '2023-01-01',
            durationMs: 200000,
            uri: 'spotify:track:track2',
          ),
        ];

        final album = AlbumInfo.fromTracks(tracks);

        expect(album.artists.length, 2);
        expect(album.artists, containsAll(['Artist 1', 'Artist 2']));
      });
    });

    group('isSingle', () {
      test('シングルタイプでtrueを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Single',
          type: 'single',
          totalTracks: 1,
          releaseDate: '2023-01-01',
          totalDurationMs: 180000,
          artists: ['Artist'],
        );

        expect(album.isSingle, isTrue);
      });

      test('アルバムタイプでfalseを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Album',
          type: 'album',
          totalTracks: 12,
          releaseDate: '2023-01-01',
          totalDurationMs: 3600000,
          artists: ['Artist'],
        );

        expect(album.isSingle, isFalse);
      });
    });

    group('isEP', () {
      test('4曲のアルバムでtrueを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'EP',
          type: 'album',
          totalTracks: 4,
          releaseDate: '2023-01-01',
          totalDurationMs: 720000,
          artists: ['Artist'],
        );

        expect(album.isEP, isTrue);
      });

      test('6曲のアルバムでtrueを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'EP',
          type: 'album',
          totalTracks: 6,
          releaseDate: '2023-01-01',
          totalDurationMs: 1080000,
          artists: ['Artist'],
        );

        expect(album.isEP, isTrue);
      });

      test('3曲のアルバムでfalseを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Mini Album',
          type: 'album',
          totalTracks: 3,
          releaseDate: '2023-01-01',
          totalDurationMs: 540000,
          artists: ['Artist'],
        );

        expect(album.isEP, isFalse);
      });

      test('7曲以上のアルバムでfalseを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Full Album',
          type: 'album',
          totalTracks: 10,
          releaseDate: '2023-01-01',
          totalDurationMs: 1800000,
          artists: ['Artist'],
        );

        expect(album.isEP, isFalse);
      });

      test('シングルタイプでfalseを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Single',
          type: 'single',
          totalTracks: 4,
          releaseDate: '2023-01-01',
          totalDurationMs: 720000,
          artists: ['Artist'],
        );

        expect(album.isEP, isFalse);
      });
    });

    group('isCompilation', () {
      test('コンピレーションタイプでtrueを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Best Hits',
          type: 'compilation',
          totalTracks: 20,
          releaseDate: '2023-01-01',
          totalDurationMs: 3600000,
          artists: ['Various Artists'],
        );

        expect(album.isCompilation, isTrue);
      });

      test('アルバムタイプでfalseを返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Album',
          type: 'album',
          totalTracks: 12,
          releaseDate: '2023-01-01',
          totalDurationMs: 3600000,
          artists: ['Artist'],
        );

        expect(album.isCompilation, isFalse);
      });
    });

    group('formattedDuration', () {
      test('1時間以上の場合は「時:分:秒」形式', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Long Album',
          type: 'album',
          totalTracks: 15,
          releaseDate: '2023-01-01',
          totalDurationMs: 3665000, // 1:01:05
          artists: ['Artist'],
        );

        expect(album.formattedDuration, '1:01:05');
      });

      test('1時間未満の場合は「分:秒」形式', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'EP',
          type: 'album',
          totalTracks: 5,
          releaseDate: '2023-01-01',
          totalDurationMs: 1245000, // 20:45
          artists: ['Artist'],
        );

        expect(album.formattedDuration, '20:45');
      });

      test('秒が1桁の場合はゼロパディング', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Album',
          type: 'album',
          totalTracks: 10,
          releaseDate: '2023-01-01',
          totalDurationMs: 605000, // 10:05
          artists: ['Artist'],
        );

        expect(album.formattedDuration, '10:05');
      });
    });

    group('releaseYear', () {
      test('リリース年を正しく抽出', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Album',
          type: 'album',
          totalTracks: 10,
          releaseDate: '2023-06-15',
          totalDurationMs: 1800000,
          artists: ['Artist'],
        );

        expect(album.releaseYear, '2023');
      });

      test('空の日付で"Unknown"を返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Album',
          type: 'album',
          totalTracks: 10,
          releaseDate: '',
          totalDurationMs: 1800000,
          artists: ['Artist'],
        );

        expect(album.releaseYear, 'Unknown');
      });
    });

    group('artistsString', () {
      test('単一アーティストをそのまま返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Album',
          type: 'album',
          totalTracks: 10,
          releaseDate: '2023-01-01',
          totalDurationMs: 1800000,
          artists: ['Solo Artist'],
        );

        expect(album.artistsString, 'Solo Artist');
      });

      test('複数アーティストをカンマ区切りで返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Album',
          type: 'album',
          totalTracks: 10,
          releaseDate: '2023-01-01',
          totalDurationMs: 1800000,
          artists: ['Artist 1', 'Artist 2', 'Artist 3'],
        );

        expect(album.artistsString, 'Artist 1, Artist 2, Artist 3');
      });

      test('空のアーティストリストで空文字列を返す', () {
        final album = AlbumInfo(
          id: 'album1',
          title: 'Album',
          type: 'album',
          totalTracks: 10,
          releaseDate: '2023-01-01',
          totalDurationMs: 1800000,
          artists: [],
        );

        expect(album.artistsString, '');
      });
    });
  });
}
