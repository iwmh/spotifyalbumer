import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/playlist.dart';

class PlaylistService {
  static const String apiBaseUrl = 'https://api.spotify.com/v1';

  Future<List<Playlist>> getUserPlaylists(String accessToken) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/me/playlists?limit=50'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((item) => Playlist.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch playlists: ${response.body}');
    }
  }

  // Future methods for playlist manipulation
  Future<void> addTrackToPlaylist(String accessToken, String playlistId, String trackUri) async {
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

  Future<void> removeTrackFromPlaylist(String accessToken, String playlistId, String trackUri) async {
    final response = await http.delete(
      Uri.parse('$apiBaseUrl/playlists/$playlistId/tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'tracks': [
          {'uri': trackUri}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove track from playlist: ${response.body}');
    }
  }
}