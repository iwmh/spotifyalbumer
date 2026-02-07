---
name: spotify-api
description: Spotify Web APIとの統合に関する専門知識。アルバムやプレイリスト管理のためのOAuth、エンドポイント、レート制限、エラーハンドリングについて。
---

# Spotify Web API 統合

## 概要
アルバムおよびプレイリスト管理のためのSpotify Web API統合の専門知識。

## 主要な専門分野

### 認証と認可
- **OAuth 2.0フロー**: モバイルアプリ向けのPKCE（Proof Key for Code Exchange）
- **トークン管理**: アクセストークン、リフレッシュトークン、トークンの有効期限
- **スコープ**: アルバム/プレイリスト操作に必要なスコープ
  - `user-library-read` - ユーザーの保存済みアルバムの読み取り
  - `user-library-modify` - ユーザーの保存済みアルバムの変更
  - `playlist-read-private` - プライベートプレイリストの読み取り
  - `playlist-modify-public` - パブリックプレイリストの変更
  - `playlist-modify-private` - プライベートプレイリストの変更

### APIエンドポイント
- **アルバム**: `/v1/me/albums`, `/v1/albums/{id}`, `/v1/albums/{id}/tracks`
- **プレイリスト**: `/v1/me/playlists`, `/v1/playlists/{id}`, `/v1/playlists/{id}/tracks`
- **検索**: `/v1/search?q={query}&type=album,artist`
- **ユーザープロフィール**: `/v1/me`

### ベストプラクティス
- **レート制限**: エクスポネンシャルバックオフを実装（429レスポンス）
- **ページネーション**: `next`, `previous`, `limit`, `offset`パラメータの処理
- **エラーハンドリング**: 
  - 401: トークン期限切れ → リフレッシュをトリガー
  - 403: 権限不足 → ユーザーにプロンプト
  - 429: レート制限 → バックオフ付きでリトライ
  - 500/502/503: サーバーエラー → バックオフ付きでリトライ
- **キャッシング**: API呼び出しを減らすためにレスポンスをキャッシュ
- **バッチリクエスト**: 利用可能な場合はバッチエンドポイントを使用

### セキュリティ
- **絶対にコミットしない**: コード内のclient_id、client_secret
- **セキュアストレージ**: トークンには`flutter_secure_storage`を使用
- **HTTPSのみ**: すべてのAPI呼び出しはHTTPS経由
- **トークン検証**: リクエスト前にトークンの有効期限を確認

### レスポンス処理
- **ページネーション**: 完全なデータ取得のため全ページを取得
- **Null安全性**: 欠落している可能性のあるオプションフィールドを処理
- **画像URL**: 適切な画像サイズを選択（300x300、640x640）
- **URI**: Spotify URI（`spotify:album:xxx`）のパース

## 実装パターン

### サービスレイヤー
```dart
@riverpod
class SpotifyApi extends _$SpotifyApi {
  @override
  Dio build() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.spotify.com/v1',
      headers: {'Content-Type': 'application/json'},
    ));
    
    dio.interceptors.add(AuthInterceptor(ref));
    dio.interceptors.add(RetryInterceptor());
    return dio;
  }
}
```

### トークンリフレッシュ
```dart
@riverpod
class TokenRefresher extends _$TokenRefresher {
  Future<void> refreshIfNeeded() async {
    final auth = ref.read(authProvider);
    if (auth.expiresAt.isBefore(DateTime.now())) {
      await _refreshToken();
    }
  }
}
```

## テスト
- **APIレスポンスのモック**: `dio_mock_adapter`を使用
- **トークンシナリオ**: 期限切れ、無効、欠落トークンのテスト
- **エラーケース**: すべてのエラーレスポンスコードをテスト
- **ページネーション**: 単一/複数ページのテスト

## リファレンス
- [Spotify Web API ドキュメント](https://developer.spotify.com/documentation/web-api)
- [認可ガイド](https://developer.spotify.com/documentation/general/guides/authorization-guide/)
- [APIレート制限](https://developer.spotify.com/documentation/web-api/concepts/rate-limits)
