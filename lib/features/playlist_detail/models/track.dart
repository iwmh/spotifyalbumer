/// トラックモデル
/// Spotifyのトラック情報を表現するクラス
class Track {
  /// トラックID
  final String id;

  /// トラック名
  final String name;

  /// アーティスト名のリスト
  final List<String> artists;

  /// アルバム名
  final String albumName;

  /// アルバムID
  final String albumId;

  /// アルバムタイプ（album、single、compilation）
  final String albumType;

  /// アルバム画像URL（オプショナル）
  final String? albumImageUrl;

  /// アルバムの総トラック数
  final int albumTotalTracks;

  /// アルバムのリリース日（YYYY-MM-DD形式）
  final String albumReleaseDate;

  /// 再生時間（ミリ秒）
  final int durationMs;

  /// Spotify URI（例: spotify:track:xxx）
  final String uri;

  /// コンストラクタ
  Track({
    required this.id,
    required this.name,
    required this.artists,
    required this.albumName,
    required this.albumId,
    required this.albumType,
    this.albumImageUrl,
    required this.albumTotalTracks,
    required this.albumReleaseDate,
    required this.durationMs,
    required this.uri,
  });

  /// JSONからTrackオブジェクトを作成するファクトリメソッド
  /// Spotify APIのレスポンス形式に対応
  factory Track.fromJson(Map<String, dynamic> json) {
    // 'track'キーがある場合はそれを使用、なければjson自体を使用
    final track = json['track'] ?? json;
    final album = track['album'];

    return Track(
      // 各フィールドにデフォルト値を設定してnull安全性を確保
      id: track['id'] ?? '',
      name: track['name'] ?? 'Unknown Track',
      artists:
          (track['artists'] as List?)
              ?.map((artist) => artist['name'] as String)
              .toList() ??
          ['Unknown Artist'],
      albumName: album?['name'] ?? 'Unknown Album',
      albumId: album?['id'] ?? '',
      albumType: album?['album_type'] ?? 'album',
      albumImageUrl:
          album?['images']?.isNotEmpty == true
              ? album['images'][0]['url']
              : null,
      albumTotalTracks: album?['total_tracks'] ?? 0,
      albumReleaseDate: album?['release_date'] ?? '',
      durationMs: track['duration_ms'] ?? 0,
      uri: track['uri'] ?? '',
    );
  }

  /// 再生時間を「分:秒」形式にフォーマット（例: 3:45）
  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// アーティスト名をカンマ区切りで結合した文字列を返す
  String get artistsString => artists.join(', ');
}
