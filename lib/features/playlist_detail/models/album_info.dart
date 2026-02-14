import 'track.dart';

/// アルバム情報モデル
/// プレイリスト内のトラックから抽出されたアルバム情報を表現するクラス
class AlbumInfo {
  /// アルバムID
  final String id;

  /// アルバムタイトル
  final String title;

  /// アルバムタイプ（album、single、compilation）
  final String type;

  /// アルバム画像URL（オプショナル）
  final String? imageUrl;

  /// アルバムの総トラック数
  final int totalTracks;

  /// アルバムのリリース日（YYYY-MM-DD形式）
  final String releaseDate;

  /// アルバムの合計時間（ミリ秒）
  final int totalDurationMs;

  /// アーティスト名のリスト
  final List<String> artists;

  /// レーベル名（オプショナル）
  /// 注意: トラック情報のアルバムオブジェクトには含まれない可能性があります
  final String? label;

  /// コンストラクタ
  AlbumInfo({
    required this.id,
    required this.title,
    required this.type,
    this.imageUrl,
    required this.totalTracks,
    required this.releaseDate,
    required this.totalDurationMs,
    required this.artists,
    this.label,
  });

  /// トラックのリストからアルバム情報を作成
  /// 同じアルバムの複数トラックから情報を統合
  factory AlbumInfo.fromTracks(List<Track> tracks) {
    if (tracks.isEmpty) {
      throw ArgumentError('Tracks list cannot be empty');
    }

    // 最初のトラックから基本情報を取得
    final firstTrack = tracks.first;

    // 全トラックの合計時間を計算
    final totalDuration = tracks.fold<int>(
      0,
      (sum, track) => sum + track.durationMs,
    );

    // アーティストを重複なしで収集
    final artistsSet = <String>{};
    for (final track in tracks) {
      artistsSet.addAll(track.artists);
    }

    return AlbumInfo(
      id: firstTrack.albumId,
      title: firstTrack.albumName,
      type: firstTrack.albumType,
      imageUrl: firstTrack.albumImageUrl,
      totalTracks: firstTrack.albumTotalTracks,
      releaseDate: firstTrack.albumReleaseDate,
      totalDurationMs: totalDuration,
      artists: artistsSet.toList(),
      label: null, // トラック情報にはレーベル名が含まれていない
    );
  }

  /// シングルかどうかを判定
  bool get isSingle => type == 'single';

  /// EPかどうかを判定
  /// EPは一般的に4-6曲のアルバムとして扱われる
  bool get isEP {
    // Spotify APIでは明示的なEPタイプはないため、
    // アルバムタイプが'album'で総トラック数が4-6曲の場合をEPと判定
    return type == 'album' && totalTracks >= 4 && totalTracks <= 6;
  }

  /// コンピレーションアルバムかどうかを判定
  bool get isCompilation => type == 'compilation';

  /// アルバムの合計時間を「時間:分:秒」または「分:秒」形式にフォーマット
  String get formattedDuration {
    final hours = totalDurationMs ~/ 3600000;
    final minutes = (totalDurationMs % 3600000) ~/ 60000;
    final seconds = (totalDurationMs % 60000) ~/ 1000;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// リリース年を取得
  String get releaseYear {
    if (releaseDate.isEmpty) return 'Unknown';
    return releaseDate.split('-').first;
  }

  /// アーティスト名をカンマ区切りで結合した文字列を返す
  String get artistsString => artists.join(', ');
}
