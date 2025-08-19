import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/spotify_auth.dart';

class AuthService {
  static const String clientId = 'd22dd3dd32a34060876238f6aab7b758';
  static const String redirectUri = 'spotifyalbumer.iwmh.com://iwmh.app/callback/';
  static const String authUrl = 'https://accounts.spotify.com/authorize';
  static const String tokenUrl = 'https://accounts.spotify.com/api/token';
  
  static const scopes = [
    // Read permissions
    'playlist-read-private',
    'playlist-read-collaborative',
    'user-read-private',
    'user-read-email',
    // Write permissions for playlist manipulation
    'playlist-modify-public',
    'playlist-modify-private',
    // Additional useful scopes
    'user-library-read',
    'user-library-modify',
    'user-follow-read',
    'user-top-read',
  ];

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  Future<String> startAuthFlow() async {
    final codeVerifier = _generateRandomString(128);
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final state = _generateRandomString(16);

    await _storage.write(key: 'code_verifier', value: codeVerifier);
    await _storage.write(key: 'auth_state', value: state);

    final params = {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': codeChallenge,
      'state': state,
      'scope': scopes.join(' '),
    };

    final uri = Uri.parse(authUrl).replace(
      queryParameters: params,
    );

    print('Attempting to launch URL: $uri');

    try {
      // Try different launch modes
      bool canLaunch = await canLaunchUrl(uri);
      print('Can launch URL: $canLaunch');
      
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Try with platform default mode
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Try launching with just the external browser
      try {
        await launchUrl(uri);
      } catch (e2) {
        print('Secondary launch attempt failed: $e2');
        throw Exception('Could not launch auth URL: $e2');
      }
    }

    return state;
  }

  Future<SpotifyAuth> exchangeCodeForTokens(String code, String state) async {
    final storedState = await _storage.read(key: 'auth_state');
    if (storedState != state) {
      throw Exception('Invalid state parameter');
    }

    final codeVerifier = await _storage.read(key: 'code_verifier');
    if (codeVerifier == null) {
      throw Exception('Code verifier not found');
    }

    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': codeVerifier,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final auth = SpotifyAuth.fromJson(data);
      
      await _storage.write(key: 'spotify_auth', value: json.encode(auth.toJson()));
      await _storage.delete(key: 'code_verifier');
      await _storage.delete(key: 'auth_state');
      
      return auth;
    } else {
      throw Exception('Failed to exchange code for tokens: ${response.body}');
    }
  }

  Future<SpotifyAuth?> getStoredAuth() async {
    final storedAuth = await _storage.read(key: 'spotify_auth');
    if (storedAuth != null) {
      final data = json.decode(storedAuth);
      return SpotifyAuth(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
        expiresIn: data['expires_in'],
        expiresAt: DateTime.parse(data['expires_at']),
      );
    }
    return null;
  }

  Future<SpotifyAuth> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': clientId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final auth = SpotifyAuth(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'] ?? refreshToken,
        expiresIn: data['expires_in'],
        expiresAt: DateTime.now().add(Duration(seconds: data['expires_in'])),
      );
      
      await _storage.write(key: 'spotify_auth', value: json.encode(auth.toJson()));
      return auth;
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'spotify_auth');
  }

  Future<void> clearOAuthState() async {
    await _storage.delete(key: 'code_verifier');
    await _storage.delete(key: 'auth_state');
  }
}