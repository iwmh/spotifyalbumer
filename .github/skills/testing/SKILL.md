---
name: testing
description: Flutterアプリケーションの包括的なテスト戦略に関する専門知識。ユニット、ウィジェット、統合テストのベストプラクティスについて。
---

# Flutterテストのベストプラクティス

## 概要
Flutterアプリケーションの包括的なテスト戦略に関する専門知識。

## テストピラミッド

### ユニットテスト（60-70%）
- ビジネスロジック、ユーティリティ、データモデル
- 高速、独立、依存関係なし
- 外部依存関係をモック

### ウィジェットテスト（20-30%）
- UIコンポーネント、ユーザーインタラクション
- ウィジェットのレンダリングと動作をテスト
- プロバイダー、サービスをモック

### 統合テスト（5-10%）
- 完全なユーザーフロー、E2Eシナリオ
- 実際のアプリ環境
- クリティカルパスのみ

## ユニットテスト

### プラクティス
- t-wadaや、Kent Beckが実践するテスト駆動開発を実践してください。
- 追加した新機能には、ユニットテストを追加することを忘れないでください。

### テスト構造
```dart
void main() {
  group('FeatureNotifier', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(MockRepository()),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('アクションを正常に実行', () async {
      final notifier = container.read(featureProvider.notifier);
      await notifier.performAction();
      
      final state = container.read(featureProvider);
      expect(state.hasValue, true);
    });
  });
}
```

### mocktailを使用したモック
```dart
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository repository;
  
  setUp(() {
    repository = MockRepository();
  });
  
  test('データを取得', () async {
    when(() => repository.getData()).thenAnswer((_) async => mockData);
    
    final result = await repository.getData();
    
    expect(result, mockData);
    verify(() => repository.getData()).called(1);
  });
}
```

## ウィジェットテスト

### 基本的なウィジェットテスト
```dart
void main() {
  testWidgets('アルバム名を表示', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AlbumCard(album: testAlbum),
        ),
      ),
    );
    
    expect(find.text('アルバム名'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
```

### インタラクションのテスト
```dart
testWidgets('タップでナビゲーション', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: AlbumCard(album: testAlbum),
      ),
    ),
  );
  
  await tester.tap(find.byType(AlbumCard));
  await tester.pumpAndSettle();
  
  expect(find.byType(AlbumDetailScreen), findsOneWidget);
});
```

### Riverpodプロバイダーのテスト
```dart
testWidgets('ローディング状態を表示', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        albumsProvider.overrideWith((ref) => const AsyncValue.loading()),
      ],
      child: MaterialApp(home: AlbumsScreen()),
    ),
  );
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### AsyncValue状態のテスト
```dart
testWidgets('エラー状態を処理', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        albumsProvider.overrideWith(
          (ref) => AsyncValue.error('エラー', StackTrace.current),
        ),
      ],
      child: MaterialApp(home: AlbumsScreen()),
    ),
  );
  
  expect(find.text('エラー'), findsOneWidget);
  expect(find.byType(RetryButton), findsOneWidget);
});
```

## 統合テスト

### セットアップ
```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('E2Eテスト', () {
    testWidgets('完全なユーザーフロー', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // テストフロー
    });
  });
}
```

### ユーザーフローテスト
```dart
testWidgets('ログインしてアルバムを表示', (tester) async {
  app.main();
  await tester.pumpAndSettle();
  
  // ログイン
  await tester.tap(find.text('Spotifyでログイン'));
  await tester.pumpAndSettle();
  
  // ホーム画面を検証
  expect(find.byType(AlbumsScreen), findsOneWidget);
  
  // アルバムをタップ
  await tester.tap(find.byType(AlbumCard).first);
  await tester.pumpAndSettle();
  
  // 詳細画面を検証
  expect(find.byType(AlbumDetailScreen), findsOneWidget);
});
```

## ゴールデンテスト

### ゴールデンファイルの生成
```dart
testWidgets('アルバムカードのゴールデン', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: AlbumCard(album: testAlbum),
      ),
    ),
  );
  
  await expectLater(
    find.byType(AlbumCard),
    matchesGoldenFile('goldens/album_card.png'),
  );
});
```

### ゴールデンの更新
```bash
fvm flutter test --update-goldens
```

## テストのベストプラクティス

### 一般
- **AAAパターン**: Arrange（準備）、Act（実行）、Assert（検証）
- **1つの検証**: 1テストにつき1つの事柄
- **説明的な名前**: テスト名は動作を説明
- **高速テスト**: 各テストを1秒以内に
- **独立したテスト**: テスト間に依存関係なし
- **決定論的**: 同じ入力 → 同じ出力

### ウィジェットテスト
- **pumpWidget**: 初回レンダリング
- **pump**: 単一フレーム更新
- **pumpAndSettle**: アニメーション完了を待機
- **Finderを使用**: find.text、find.byType、find.byKey
- **テスト用のKeys**: 重要なウィジェットにキーを追加

### モッキング
- **外部をモック**: API、データベース、ストレージ
- **値はモックしない**: 実際の値オブジェクトを使用
- **インタラクションを検証**: 副作用が重要な場合
- **戻り値をスタブ**: クエリ操作の場合

### カバレッジ
- **カバレッジを測定**: `fvm flutter test --coverage`
- **80%以上を目指す**: クリティカルパスに焦点
- **生成コードを除外**: *.g.dartファイルを除外
- **カバレッジ ≠ 品質**: 高カバレッジは良いテストを保証しない

## テストツール

### コア
- `test`: Dartテストフレームワーク
- `flutter_test`: Flutterウィジェットテスト
- `integration_test`: 統合テスト
- `mocktail`: モッキングライブラリ

### 追加
- `golden_toolkit`: 強化されたゴールデンテスト
- `patrol`: 高度な統合テスト
- `alchemist`: ゴールデンテストユーティリティ
- `test_coverage`: カバレッジレポート

## 一般的なパターン

### テストデータビルダー
```dart
class AlbumBuilder {
  String id = 'test-id';
  String name = 'テストアルバム';
  
  AlbumBuilder withId(String value) {
    id = value;
    return this;
  }
  
  Album build() => Album(id: id, name: name);
}
```

### カスタムマッチャー
```dart
Matcher hasLength(int length) => 
  Having((list) => list.length, 'length', equals(length));
```

### テストフィクスチャ
```dart
// test/fixtures/albums.dart
final testAlbum = Album(id: '1', name: 'テストアルバム');
final testAlbums = [testAlbum, ...];
```

## コマンドリファレンス

```bash
# すべてのテストを実行
fvm flutter test

# 特定のテストファイルを実行
fvm flutter test test/features/auth_test.dart

# カバレッジ付きで実行
fvm flutter test --coverage

# 統合テストを実行
fvm flutter test integration_test

# ゴールデンファイルを更新
fvm flutter test --update-goldens

# ウォッチモードで実行（外部ツールで）
fvm flutter test --watch
```

## リファレンス
- [Flutterテストドキュメント](https://docs.flutter.dev/testing)
- [効果的なテスト](https://dart.dev/guides/testing)
- [Riverpodテストガイド](https://riverpod.dev/docs/essentials/testing)
