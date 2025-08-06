class Playlist {
  final String id;
  final String name;
  final String? description;
  final int totalTracks;
  final String? imageUrl;
  final String? ownerId;
  final String? ownerDisplayName;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.totalTracks,
    this.imageUrl,
    this.ownerId,
    this.ownerDisplayName,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      totalTracks: json['tracks']['total'],
      imageUrl: json['images']?.isNotEmpty == true ? json['images'][0]['url'] : null,
      ownerId: json['owner']['id'],
      ownerDisplayName: json['owner']['display_name'],
    );
  }
}