---
name: flutter-dart
description: モダンなFlutter（3.24+）とDart（3.5+）開発に関する専門知識。最新機能、ベストプラクティス、ウィジェット、パフォーマンス最適化について。
---

# モダンFlutter & Dart開発

## 概要
最新機能とベストプラクティスを用いた、モダンなFlutter（3.24+）およびDart（3.5+）開発の専門知識。

## 主要な専門分野

### Dart言語（3.5+）
- **Null安全性**: サウンドなNull安全性、late、required、nullable型
- **パターンマッチング**: switch式、分解、ガード
- **レコード**: 複数戻り値のための位置指定レコードと名前付きレコード
- **シールドクラス**: シールド型による網羅的パターンマッチング
- **拡張型**: ゼロコストラッパー型
- **非同期/await**: Future、Stream、async*、yield
- **コード生成**: build_runner、source_gen

### Flutterフレームワーク（3.24+）
- **ウィジェット**: Stateless、Stateful、InheritedWidgetパターン
- **パフォーマンス**: constコンストラクタ、RepaintBoundary、keys
- **ナビゲーション**: GoRouter、宣言的ルーティング
- **プラットフォーム統合**: MethodChannel、プラットフォーム固有コード
- **アセット**: 画像、フォント、ローカリゼーション
- **レスポンシブデザイン**: MediaQuery、LayoutBuilder、柔軟なレイアウト

### 状態管理（Riverpod 2.6+）
- **コード生成**: `@riverpod`アノテーション、AutoDispose
- **プロバイダータイプ**: Provider、FutureProvider、StreamProvider、Notifier
- **AsyncValue**: パターンマッチングによるローディング、データ、エラー状態
- **依存性注入**: Ref、family、スコーピング
- **副作用**: ref.listen、ref.listenManual
- **テスト**: ProviderContainer、オーバーライド

### UI/UX原則
- **Material Design 3**: M3コンポーネント、ダイナミックカラー、エレベーション
- **アダプティブUI**: プラットフォーム固有ウィジェット（Cupertino、Material）
- **アクセシビリティ**: セマンティクス、スクリーンリーダーサポート、コントラスト
- **アニメーション**: 暗黙的、明示的、Hero、カスタムアニメーション
- **ジェスチャー**: GestureDetector、Draggable、dismissibleパターン

### アーキテクチャ
- **機能優先**: レイヤーではなく機能ごとに整理
- **クリーンアーキテクチャ**: ドメイン、データ、プレゼンテーション層の分離
- **リポジトリパターン**: データソースの抽象化
- **ユースケース**: 単一責任のビジネスロジック
- **DTO**: APIモデルとドメインモデルの分離

### コード品質
- **リンティング**: 厳格なanalysis_options.yaml、カスタムルール
- **フォーマッティング**: dart format、末尾カンマ
- **ドキュメンテーション**: パブリックAPI用のDartDocコメント
- **不変性**: final、const、immutableクラスを優先
- **コード生成**: freezed、json_serializable、riverpod_generator

### テスト
- **ユニットテスト**: ビジネスロジック、ユーティリティ、純粋関数
- **ウィジェットテスト**: UIコンポーネント、インタラクション
- **統合テスト**: 完全なユーザーフロー、E2E
- **ゴールデンテスト**: ビジュアルリグレッションテスト
- **モッキング**: 依存関係のためのmockito、mocktail

### パフォーマンス最適化
- **ビルド最適化**: リビルドを最小化、const、keysを使用
- **リストレンダリング**: ListView.builder、CustomScrollView、slivers
- **画像ロード**: cached_network_image、画像キャッシング
- **メモリ管理**: コントローラー、StreamSubscriptionの破棄
- **バンドルサイズ**: ツリーシェイキング、コード分割

## 実装パターン

### コード生成を用いたRiverpodプロバイダー
```dart
@riverpod
class FeatureNotifier extends _$FeatureNotifier {
  @override
  FutureOr<FeatureState> build() async {
    // 状態を初期化
    return await _loadInitialData();
  }
  
  Future<void> performAction() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // ビジネスロジック
      return newState;
    });
  }
}
```

### AsyncValueパターンマッチング
```dart
ref.watch(dataProvider).when(
  data: (data) => DataView(data),
  loading: () => LoadingIndicator(),
  error: (error, stack) => ErrorView(error),
)
```

### Freezedデータモデル
```dart
@freezed
class Album with _$Album {
  const factory Album({
    required String id,
    required String name,
    String? imageUrl,
  }) = _Album;
  
  factory Album.fromJson(Map<String, dynamic> json) =>
      _$AlbumFromJson(json);
}
```

## ベストプラクティス
- **ウィジェットの構成**: 大きなウィジェットを小さなものに分解
- **ConsumerWidget**: Riverpod使用時はStatefulWidgetより優先
- **AutoDispose**: 監視されていないプロバイダーは自動破棄
- **エラー境界**: 適切なレベルでエラーをキャッチ
- **プラットフォームチェック**: Platform.isAndroid、Platform.isIOSは控えめに使用
- **BuildContext**: パラメータとして渡す、状態に保存しない

## よくある落とし穴
- ❌ RiverpodアプリでsetStateを使用
- ❌ 非同期ギャップでBuildContextを保存
- ❌ コントローラーを破棄しない
- ❌ StatefulWidgetの過度な使用
- ❌ 必要なときにウィジェットのkeysを無視
- ❌ 重い計算でUIスレッドをブロック

## ツール & 拡張機能
- **FVM**: Flutter Version Management
- **build_runner**: コード生成
- **flutter_gen**: アセット/ローカリゼーション生成
- **Dart DevTools**: パフォーマンス、メモリプロファイリング

## リファレンス
- [Flutterドキュメント](https://docs.flutter.dev/)
- [Effective Dart](https://dart.dev/effective-dart)
- [Riverpodドキュメント](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)
