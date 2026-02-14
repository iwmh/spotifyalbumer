import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/playlist.dart';
import '../../playlist_detail/models/track.dart';

/// Spotify APIと連携するプレイリストサービス
/// プレイリストとトラックの取得、操作を行う
class PlaylistService {
  /// Spotify Web APIのベースURL
  static const String apiBaseUrl = 'https://api.spotify.com/v1';

  /// ユーザーのプレイリスト一覧を取得
  ///
  /// 自分が作成したプレイリストとフォローしているプレイリストの両方を取得
  /// ページネーションを処理して全てのプレイリストを返す
  ///
  /// [accessToken] Spotify APIのアクセストークン
  /// Returns: プレイリストのリスト
  Future<List<Playlist>> getUserPlaylists(String accessToken) async {
    final List<Playlist> allPlaylists = [];
    String? nextUrl = '$apiBaseUrl/me/playlists?limit=50';

    // 全てのページを取得（自分が作成したプレイリスト + フォロー中のプレイリスト）
    while (nextUrl != null) {
      final response = await http.get(
        Uri.parse(nextUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        allPlaylists.addAll(items.map((item) => Playlist.fromJson(item)));
        // 次のページのURLを取得（nullの場合は最後のページ）
        nextUrl = data['next'];
      } else {
        throw Exception('Failed to fetch playlists: ${response.body}');
      }
    }

    return allPlaylists;
  }

  /// プレイリストのトラック一覧を取得
  ///
  /// 指定されたプレイリストに含まれる全トラックを取得
  /// ページネーションを処理して全てのトラックを返す
  ///
  /// [accessToken] Spotify APIのアクセストークン
  /// [playlistId] 取得対象のプレイリストID
  /// Returns: トラックのリスト
  Future<List<Track>> getPlaylistTracks(
    String accessToken,
    String playlistId,
  ) async {
    final List<Track> allTracks = [];
    String? nextUrl = '$apiBaseUrl/playlists/$playlistId/tracks?limit=100';

    // 全てのページを取得
    while (nextUrl != null) {
      final response = await http.get(
        Uri.parse(nextUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        allTracks.addAll(items.map((item) => Track.fromJson(item)));
        // 次のページのURLを取得（nullの場合は最後のページ）
        nextUrl = data['next'];
      } else {
        throw Exception('Failed to fetch playlist tracks: ${response.body}');
      }
    }

    return allTracks;
  }

  /// プレイリストにトラックを追加
  ///
  /// [accessToken] Spotify APIのアクセストークン
  /// [playlistId] トラックを追加するプレイリストID
  /// [trackUri] 追加するトラックのURI（例: spotify:track:xxx）
  Future<void> addTrackToPlaylist(
    String accessToken,
    String playlistId,
    String trackUri,
  ) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/playlists/$playlistId/tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'uris': [trackUri],
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add track to playlist: ${response.body}');
    }
  }

  /// プレイリストからトラックを削除
  ///
  /// [accessToken] Spotify APIのアクセストークン
  /// [playlistId] トラックを削除するプレイリストID
  /// [trackUri] 削除するトラックのURI（例: spotify:track:xxx）
  Future<void> removeTrackFromPlaylist(
    String accessToken,
    String playlistId,
    String trackUri,
  ) async {
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/playlists/$playlistId/tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tracks': [
          {'uri': trackUri},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove track from playlist: ${response.body}');
    }
  }
}
