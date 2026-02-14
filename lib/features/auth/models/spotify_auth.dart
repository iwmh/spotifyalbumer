class SpotifyAuth {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final DateTime expiresAt;

  SpotifyAuth({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.expiresAt,
  });

  factory SpotifyAuth.fromJson(Map<String, dynamic> json) {
    return SpotifyAuth(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      expiresAt: DateTime.now().add(Duration(seconds: json['expires_in'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
