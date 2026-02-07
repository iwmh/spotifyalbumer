# GitHub Copilot Instructions for spotify_albumer

## プロジェクト概要

**Spotify Albumer**は、Spotifyアルバムコレクションを管理・閲覧するFlutterモバイルアプリケーションです。最新のFlutter（3.24+）、Dart（3.5+）、Riverpod状態管理を使用し、クリーンアーキテクチャと機能ファースト原則に従って構築されています。

**コア技術:**
- Flutter 3.24+（FVM経由）
- Dart 3.5+
- Riverpod 2.6+（状態管理とDI）
- Spotify Web API統合
- Material Design 3

## スキルとエージェント

GitHub Copilotは、このプロジェクト用の専門的な**スキル**と**エージェント**にアクセスできます:

### 📚 スキル（専門分野）
特定のドメインに関する詳細な知識ベース:

- **[Spotify Web API](skills/spotify-api/SKILL.md)**: OAuth、エンドポイント、レート制限、エラーハンドリング
- **[Flutter & Dart](skills/flutter-dart/SKILL.md)**: 最新のFlutter/Dartパターン、ウィジェット、パフォーマンス
- **[モバイルリリース](skills/mobile-release/SKILL.md)**: Android・iOSデプロイメント、署名、ストア申請
- **[テスト](skills/testing/SKILL.md)**: ユニット、ウィジェット、統合テスト戦略
- **[HCI & UX](skills/hci-ux/SKILL.md)**: ユーザー中心設計、アクセシビリティ、モバイルインタラクションパターン

### 🤖 エージェント（タスク専門家）
特定のタスクに特化したワークフロー:

- **[機能開発者](agents/feature-developer.agent.md)**: 新機能のエンドツーエンド実装
- **[コードレビュアー](agents/code-reviewer.agent.md)**: 包括的なコード品質レビュー
- **[デバッガー](agents/debugger.agent.md)**: バグの診断と修正

> **注意:** 特定のタスクに取り組む際、Copilotは関連するスキルとエージェントを自動的に適用し、コンテキストを考慮した支援を提供します。

## クイックスタート

### 必須コマンド

**常に`fvm`を使用して正しいSDKバージョンを確保:**

```bash
# コード生成（@riverpod、freezedなどを変更した後）
fvm dart run build_runner build --delete-conflicting-outputs

# Watchモード（ファイル保存時に自動生成）
fvm dart run build_runner watch --delete-conflicting-outputs

# コードをフォーマット
fvm dart format .

# コードを分析
fvm flutter analyze

# テストを実行
fvm flutter test

# アプリを実行
fvm flutter run

# クリーンビルド
fvm flutter clean && fvm flutter pub get
```

## アーキテクチャ概要

### 機能ファースト構造
```
lib/
├── main.dart
├── features/              # 機能モジュール（auth、playlistsなど）
│   └── feature_name/
│       ├── data/          # モデル、リポジトリ
│       ├── presentation/  # スクリーン、ウィジェット
│       └── providers/     # Riverpodプロバイダー
└── shared/                # 共有コード（ウィジェット、ユーティリティ）
```

### コアの原則
- **状態管理**: コード生成を使用したRiverpod（`@riverpod`）
- **データモデル**: 不変性のためのFreezed
- **API統合**: OAuth 2.0 PKCEを使用したSpotify Web API
- **エラーハンドリング**: すべての非同期操作にAsyncValue
- **テスト**: 包括的なユニット、ウィジェット、統合テスト

## 主要な規約

### 命名規則
- **ファイル**: `snake_case.dart`
- **クラス**: `PascalCase`
- **変数/関数**: `camelCase`
- **プライベート**: `_prefixWithUnderscore`

### Riverpodパターン
```dart
// ✅ 推奨: コード生成
@riverpod
class FeatureNotifier extends _$FeatureNotifier {
  @override
  FutureOr<State> build() async => initialState;
}

// ✅ ウィジェットで使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(featureProvider).when(
      data: (data) => DataView(data),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorView(error),
    );
  }
}
```

### コード品質要件
- ✅ すべてのanalyzer警告を解決
- ✅ `dart format`でコードをフォーマット
- ✅ テストが通る
- ✅ すべてのAsyncValue状態を処理（data、loading、error）
- ✅ デバッグprintやコメントアウトされたコードなし
- ✅ アクセシビリティを考慮（セマンティクス、コントラスト、タッチターゲット）

## プロジェクト固有のルール

### Spotify API
- 認証情報をコミットしない（環境変数を使用）
- 期限切れトークンのリフレッシュを実装
- 指数バックオフでレート制限を処理
- 適切な場合はレスポンスをキャッシュ

### セキュリティ
- トークンに`flutter_secure_storage`を使用
- すべてのユーザー入力を検証
- 機密データをログに記録しない

### UXガイドライン
- すべての非同期操作にローディング状態を表示
- リトライオプション付きの明確なエラーメッセージを提供
- 動的なテキストサイズとハイコントラストをサポート
- 最小タッチターゲット: 44x44pt

## リソース

- [Effective Dart](https://dart.dev/effective-dart)
- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [Spotify Web API](https://developer.spotify.com/documentation/web-api)
- [Material Design 3](https://m3.material.io/)

## Copilotとの作業

ヘルプをリクエストする際:
- **機能の場合**: "feature-developerエージェントに従って[機能]を実装"
- **レビューの場合**: "code-reviewer基準を使用してこのコードをレビュー"
- **バグの場合**: "debuggerエージェントを使用してこの問題をデバッグ"
- **API作業の場合**: "Spotify APIスキルを使用して[エンドポイント]を実装"
- **UXの場合**: "HCI/UXガイドラインに従ってこのスクリーンを設計"

Copilotは、適切なスキルとエージェントを自動的に参照し、簡潔で焦点を絞ったインタラクションを維持しながら、コンテキストを考慮した支援を提供します。
