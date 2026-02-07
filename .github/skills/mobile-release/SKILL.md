---
name: mobile-release
description: FlutterアプリをGoogle Play StoreとApple App Storeにリリースするための専門知識。Android/iOSのビルド設定、署名、ストア申請プロセスについて。
---

# モバイルアプリリリース（Android & iOS）

## 概要
FlutterアプリをGoogle Play StoreとApple App Storeにリリースするための専門知識。

## Androidリリース

### ビルド設定
- **build.gradle.kts**: バージョンコード、バージョン名、SDKバージョン
- **署名**: keystore.properties、リリース署名設定
- **ProGuard/R8**: コードの難読化と最小化
- **App Bundle**: Play StoreにはAPKよりAABを優先

### バージョン管理
```gradle
android {
    defaultConfig {
        versionCode = 1 // リリースごとにインクリメント
        versionName = "1.0.0" // セマンティックバージョニング
    }
}
```

### ビルドタイプ
- **Debug**: 開発用、デバッグ有効
- **Profile**: パフォーマンステスト
- **Release**: 本番環境、最適化済み、署名済み

### 署名設定
```properties
# keystore.properties（コミット禁止）
storePassword=***
keyPassword=***
keyAlias=release
storeFile=release-keystore.jks
```

### リリースチェックリスト
- [ ] versionCodeとversionNameを更新
- [ ] リリース用keystoreを生成（初回のみ）
- [ ] build.gradle.ktsで署名を設定
- [ ] 必要に応じてProGuard/R8ルールを有効化
- [ ] App Bundleをビルド: `fvm flutter build appbundle --release`
- [ ] 実機で署名済みバンドルをテスト
- [ ] プライバシーポリシーURLを生成
- [ ] ストア掲載情報を準備（スクリーンショット、説明文）

### Fastlane（オプション）
```ruby
# android/fastlane/Fastfile
lane :beta do
  gradle(task: "clean bundleRelease")
  upload_to_play_store(
    track: 'internal',
    aab: '../build/app/outputs/bundle/release/app-release.aab'
  )
end
```

## iOSリリース

### Xcode設定
- **Info.plist**: Bundle ID、バージョン、パーミッション
- **Signing & Capabilities**: チーム、証明書、プロビジョニングプロファイル
- **Build Settings**: 最適化レベル、アーキテクチャ
- **Schemes**: Debug、Profile、Release

### バージョン管理
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleShortVersionString</key>
<string>1.0.0</string> <!-- ユーザーに表示されるバージョン -->
<key>CFBundleVersion</key>
<string>1</string> <!-- ビルド番号、アップロードごとにインクリメント -->
```

### 証明書とプロビジョニング
- **Development**: デバイスでのローカルテスト
- **Ad Hoc**: 内部配布
- **App Store**: 本番リリース
- **Fastlane Match**: チーム証明書管理

### リリースチェックリスト
- [ ] CFBundleShortVersionStringとCFBundleVersionを更新
- [ ] Xcodeで署名を設定（自動または手動）
- [ ] Info.plistに必要なパーミッションを追加
- [ ] アーカイブをビルド: `fvm flutter build ipa --release`
- [ ] XcodeまたはTransporterでアーカイブを検証
- [ ] App Store Connectにアップロード
- [ ] App Store Connectのメタデータを完成
- [ ] レビュー申請

### Fastlane（推奨）
```ruby
# ios/fastlane/Fastfile
lane :beta do
  build_app(
    workspace: "Runner.xcworkspace",
    scheme: "Runner",
    export_method: "app-store"
  )
  upload_to_testflight(
    skip_waiting_for_build_processing: true
  )
end
```

## クロスプラットフォームベストプラクティス

### セマンティックバージョニング
- **MAJOR.MINOR.PATCH**（例: 2.1.3）
- MAJOR: 破壊的変更
- MINOR: 新機能、後方互換性あり
- PATCH: バグ修正

### バージョン同期
- AndroidのversionNameとiOSのCFBundleShortVersionStringを同期
- ビルドごとにAndroidのversionCodeとiOSのCFBundleVersionをインクリメント

### App Storeアセット
- **スクリーンショット**: 複数のデバイスサイズ、ローカライズ済み
- **アイコン**: ストア用1024x1024、アプリ用マルチサイズ
- **フィーチャーグラフィック**: Android Play Store（1024x500）
- **アプリプレビュー動画**: オプションだが推奨

### メタデータ準備
- **アプリ名**: 簡潔で検索しやすい
- **説明文**: 
  - 短文: ユーザーを引き付ける（Google Playは80文字）
  - 詳細: 機能、利点、キーワード
- **キーワード**: iOSのみ、カンマ区切り（最大100文字）
- **カテゴリ**: プライマリとセカンダリ
- **コンテンツレーティング**: ESRB、PEGIなど
- **プライバシーポリシー**: 必須、公開アクセス可能なURL

### リリース前テスト
- [ ] 実機でテスト（Android & iOS）
- [ ] 異なるOSバージョンでテスト
- [ ] 異なる画面サイズでテスト
- [ ] すべてのユーザーフローをテスト
- [ ] オフラインシナリオをテスト
- [ ] API統合を検証
- [ ] パフォーマンスをチェック（メモリ、バッテリー）
- [ ] アナリティクストラッキングを検証

### 配布チャネル
- **内部テスト**: チームとのアルファ/ベータテスト
- **クローズドテスト**: 招待ユーザーとのベータテスト
- **オープンテスト**: パブリックベータ
- **本番**: フルリリース

### ロールアウト戦略
- **段階的ロールアウト**: 5-10%から開始、監視しながら徐々に増加
- **A/Bテスト**: ユーザーの一部で機能をテスト
- **フィーチャーフラグ**: リモートで機能を有効/無効化

### リリース後のモニタリング
- **クラッシュレポート**: Firebase Crashlytics、Sentry
- **アナリティクス**: ユーザー行動、リテンション、エンゲージメント
- **パフォーマンス**: アプリ起動時間、ネットワーク待機時間
- **レビュー**: ユーザーフィードバックを監視・対応
- **メトリクス**: DAU、MAU、リテンション率

## よくある問題と解決策

### Android
- **ビルド失敗**: JDKバージョン、Gradleバージョンを確認
- **署名エラー**: keystoreパス、パスワードを検証
- **ProGuard問題**: リフレクションベースコード用のkeepルールを追加
- **Play Storeリジェクション**: ポリシー準拠を確認

### iOS
- **証明書期限切れ**: Apple Developer Portalで更新
- **プロビジョニングプロファイル**: デバイスが登録されているか確認
- **アーカイブ失敗**: ビルドフォルダをクリーン、スキームを確認
- **App Storeリジェクション**: Human Interface Guidelinesを確認

## 自動化ツール
- **Fastlane**: ビルド、スクリーンショット、アップロードを自動化
- **Codemagic**: Flutter用CI/CD
- **GitHub Actions**: カスタムワークフロー
- **Bitrise**: モバイル特化CI/CD

## コマンドリファレンス

### Android
```bash
# App Bundle（リリース）をビルド
fvm flutter build appbundle --release

# APK（リリース）をビルド
fvm flutter build apk --release --split-per-abi
```

### iOS
```bash
# iOSアーカイブをビルド
fvm flutter build ipa --release

# コード署名なしでビルド（CI用）
fvm flutter build ios --release --no-codesign
```

## リファレンス
- [Flutter Deployment（Android）](https://docs.flutter.dev/deployment/android)
- [Flutter Deployment（iOS）](https://docs.flutter.dev/deployment/ios)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Fastlaneドキュメント](https://docs.fastlane.tools/)
