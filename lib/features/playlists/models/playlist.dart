/// プレイリストモデル
/// Spotifyのプレイリスト情報を表現するクラス
class Playlist {
  /// プレイリストID
  final String id;

  /// プレイリスト名
  final String name;

  /// プレイリストの説明（オプショナル）
  final String? description;

  /// 含まれるトラックの総数
  final int totalTracks;

  /// プレイリスト画像URL（オプショナル）
  final String? imageUrl;

  /// プレイリストの所有者ID（オプショナル）
  final String? ownerId;

  /// プレイリストの所有者表示名（オプショナル）
  final String? ownerDisplayName;

  /// コンストラクタ
  Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.totalTracks,
    this.imageUrl,
    this.ownerId,
    this.ownerDisplayName,
  });

  /// JSONからPlaylistオブジェクトを作成するファクトリメソッド
  /// Spotify APIのレスポンス形式に対応
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      totalTracks: json['tracks']['total'],
      imageUrl:
          json['images']?.isNotEmpty == true ? json['images'][0]['url'] : null,
      ownerId: json['owner']['id'],
      ownerDisplayName: json['owner']['display_name'],
    );
  }
}
