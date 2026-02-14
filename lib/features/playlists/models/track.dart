class Track {
  final String id;
  final String name;
  final List<String> artists;
  final String albumName;
  final String? albumImageUrl;
  final int durationMs;
  final String uri;

  Track({
    required this.id,
    required this.name,
    required this.artists,
    required this.albumName,
    this.albumImageUrl,
    required this.durationMs,
    required this.uri,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final track = json['track'] ?? json;

    return Track(
      id: track['id'] ?? '',
      name: track['name'] ?? 'Unknown Track',
      artists:
          (track['artists'] as List?)
              ?.map((artist) => artist['name'] as String)
              .toList() ??
          ['Unknown Artist'],
      albumName: track['album']?['name'] ?? 'Unknown Album',
      albumImageUrl:
          track['album']?['images']?.isNotEmpty == true
              ? track['album']['images'][0]['url']
              : null,
      durationMs: track['duration_ms'] ?? 0,
      uri: track['uri'] ?? '',
    );
  }

  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get artistsString => artists.join(', ');
}
