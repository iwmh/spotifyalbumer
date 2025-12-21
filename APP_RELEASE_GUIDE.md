# Spotify Albumer アプリ公開ガイド

このドキュメントでは、FlutterアプリをGoogle Play StoreとApp Storeに公開するための完全な手順を説明します。

---

## 目次

1. [事前準備](#1-事前準備)
2. [Android - Google Play Store公開](#2-android---google-play-store公開)
3. [iOS - App Store公開](#3-ios---app-store公開)
4. [GitHub Actionsによる自動化](#4-github-actionsによる自動化)
5. [Push通知の実装](#5-push通知の実装)
6. [トラブルシューティング](#6-トラブルシューティング)

---

## 1. 事前準備

### 1.1 開発者アカウントの作成

#### Google Play Console（Android）

1. **アカウント作成**
   - [Google Play Console](https://play.google.com/console) にアクセス
   - Googleアカウントでログイン
   - 登録料: **$25（一度きり）**
   - 本人確認書類の提出が必要な場合があります

2. **組織情報の登録**
   - 開発者名（ストアに表示される名前）
   - 連絡先メールアドレス
   - 電話番号
   - 住所

#### Apple Developer Program（iOS）

1. **Apple IDの作成**
   - [Apple ID](https://appleid.apple.com/) を作成（既にあればスキップ）
   - 二要素認証を有効化（必須）

2. **Developer Programへの登録**
   - [Apple Developer Program](https://developer.apple.com/programs/) にアクセス
   - 登録料: **年間 $99（約15,000円）**
   - 個人または組織として登録
   - 組織の場合はD-U-N-S番号が必要

### 1.2 アプリアイコンの準備

アプリアイコンは複数のサイズが必要です。

```
必要なアイコンサイズ:

Android:
- 48x48 (mdpi)
- 72x72 (hdpi)
- 96x96 (xhdpi)
- 144x144 (xxhdpi)
- 192x192 (xxxhdpi)
- 512x512 (Play Store用)

iOS:
- 20x20, 29x29, 40x40, 58x58, 60x60, 76x76, 80x80, 87x87
- 120x120, 152x152, 167x167, 180x180
- 1024x1024 (App Store用)
```

**推奨ツール:**
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) パッケージを使用

```yaml
# pubspec.yaml に追加
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
```

```bash
# アイコン生成コマンド
fvm dart run flutter_launcher_icons
```

### 1.3 スプラッシュスクリーンの設定

```yaml
# pubspec.yaml に追加
dev_dependencies:
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#1DB954"  # Spotifyグリーン
  image: assets/splash/splash_logo.png
  android: true
  ios: true
```

```bash
fvm dart run flutter_native_splash:create
```

### 1.4 アプリのバージョン管理

`pubspec.yaml` でバージョンを管理:

```yaml
version: 1.0.0+1
# 形式: major.minor.patch+buildNumber
# 1.0.0 = versionName (ユーザーに表示)
# +1 = versionCode/buildNumber (ストア内部で使用、公開ごとに増やす)
```

**バージョン番号のルール:**
- `buildNumber`（+以降の数字）は公開ごとに**必ず増やす**
- 一度使ったbuildNumberは再利用できない

---

## 2. Android - Google Play Store公開

### 2.1 署名キーの作成

アプリに署名するためのキーストアを作成します。

```bash
# キーストアの作成
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**入力項目:**
- キーストアのパスワード（忘れないように！）
- 名前（本名）
- 組織単位
- 組織名
- 市区町村
- 都道府県
- 国コード（JP）

⚠️ **重要:** キーストアファイルとパスワードは**絶対に紛失しないでください**。紛失するとアプリの更新ができなくなります。

### 2.2 署名設定

#### 2.2.1 key.properties ファイルの作成

`android/key.properties` を作成（**Gitにコミットしない**）:

```properties
storePassword=<キーストアのパスワード>
keyPassword=<キーのパスワード>
keyAlias=upload
storeFile=<キーストアファイルへの絶対パス>
```

#### 2.2.2 .gitignore に追加

```gitignore
# Android signing
android/key.properties
*.jks
*.keystore
```

#### 2.2.3 build.gradle.kts の修正

`android/app/build.gradle.kts` を以下のように修正:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// key.properties を読み込む
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.iwmh.spotifyalbumer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.iwmh.spotifyalbumer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
```

#### 2.2.4 ProGuard設定の作成

`android/app/proguard-rules.pro` を作成:

```proguard
# Flutter関連
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# アプリ固有のルール（必要に応じて追加）
-keep class com.iwmh.spotifyalbumer.** { *; }
```

### 2.3 リリースビルドの作成

```bash
# App Bundle形式（推奨）
fvm flutter build appbundle --release

# 出力先: build/app/outputs/bundle/release/app-release.aab
```

### 2.4 Google Play Consoleでの設定

#### 2.4.1 アプリの作成

1. Google Play Console にログイン
2. 「アプリを作成」をクリック
3. 以下の情報を入力:
   - アプリ名: `Spotify Albumer`
   - デフォルトの言語: 日本語
   - アプリまたはゲーム: アプリ
   - 無料または有料: 無料
   - 宣言（各項目にチェック）

#### 2.4.2 ストア掲載情報の設定

**メインのストア掲載情報:**
- アプリ名（30文字以内）
- 簡単な説明（80文字以内）
- 詳しい説明（4000文字以内）
- アプリアイコン（512x512 PNG）
- フィーチャーグラフィック（1024x500 PNG）
- スクリーンショット（最低2枚）
  - 電話: 16:9 または 9:16
  - 7インチタブレット
  - 10インチタブレット

#### 2.4.3 コンテンツのレーティング

質問票に回答してレーティングを取得:
1. 「ポリシー」→「アプリのコンテンツ」→「コンテンツのレーティング」
2. 質問に正直に回答
3. レーティングを取得

#### 2.4.4 プライバシーポリシー

プライバシーポリシーのURLが必要です。
- 自分のWebサイトに掲載
- または GitHub Pages で公開

```markdown
# プライバシーポリシー（例）

## 収集する情報
- Spotifyアカウント情報（認証のため）
- アルバム・プレイリスト情報

## 情報の使用目的
- アプリ機能の提供のみ

## 第三者への提供
- 第三者への提供は行いません

## お問い合わせ
email@example.com
```

### 2.5 内部テストへの公開

1. 「テスト」→「内部テスト」を選択
2. 「新しいリリースを作成」
3. App Bundle (.aab) をアップロード
4. リリースノートを入力
5. テスターのメールアドレスを追加
6. 「リリースのレビュー」→「内部テストとして公開開始」

### 2.6 本番公開

内部テストで問題なければ:
1. 「本番」→「新しいリリースを作成」
2. 内部テストからリリースを昇格、またはApp Bundleを再アップロード
3. リリースノートを入力
4. 「リリースのレビュー」→「本番環境として公開開始」
5. Googleの審査（通常1〜3日）

---

## 3. iOS - App Store公開

### 3.1 証明書とプロビジョニングプロファイル

#### 3.1.1 証明書の種類

| 証明書 | 用途 |
|--------|------|
| Development | 開発・デバッグ用 |
| Distribution | App Store公開用 |

#### 3.1.2 Apple Developer Portalでの設定

1. [Apple Developer Portal](https://developer.apple.com/account/) にアクセス
2. 「Certificates, Identifiers & Profiles」を選択

**App IDの作成:**
1. 「Identifiers」→「+」ボタン
2. 「App IDs」→「Continue」
3. 「App」を選択
4. Description: `Spotify Albumer`
5. Bundle ID: `com.iwmh.spotifyalbumer`（Explicit）
6. Capabilities: 必要な機能を選択（Push Notificationsなど）

**証明書の作成:**
1. 「Certificates」→「+」ボタン
2. 「Apple Distribution」を選択
3. CSR（Certificate Signing Request）をアップロード
   - Mac の「キーチェーンアクセス」→「証明書アシスタント」→「認証局に証明書を要求」
4. 証明書をダウンロードしてダブルクリックでインストール

**プロビジョニングプロファイルの作成:**
1. 「Profiles」→「+」ボタン
2. 「App Store Connect」を選択
3. App IDを選択
4. 証明書を選択
5. プロファイル名を入力
6. ダウンロードしてXcodeにインストール

### 3.2 Xcodeでの設定

```bash
# iOSフォルダを開く
cd ios
open Runner.xcworkspace
```

**Xcodeでの設定項目:**

1. **Signing & Capabilities**
   - Team: 自分の開発者アカウント
   - Bundle Identifier: `com.iwmh.spotifyalbumer`
   - Signing Certificate: Distribution
   - Provisioning Profile: App Store用プロファイル

2. **General**
   - Display Name: `Spotify Albumer`
   - Version: `1.0.0`
   - Build: `1`

3. **Build Settings**
   - iOS Deployment Target: `12.0` 以上推奨

### 3.3 リリースビルドの作成

```bash
# iOSビルド
fvm flutter build ipa --release

# 出力先: build/ios/ipa/spotify_albumer.ipa
```

または Xcode から:
1. Product → Archive
2. アーカイブ完了後、Organizer が開く
3. 「Distribute App」→「App Store Connect」

### 3.4 App Store Connectでの設定

#### 3.4.1 アプリの作成

1. [App Store Connect](https://appstoreconnect.apple.com/) にアクセス
2. 「マイApp」→「+」→「新規App」
3. 以下を入力:
   - プラットフォーム: iOS
   - 名前: `Spotify Albumer`
   - プライマリ言語: 日本語
   - バンドルID: `com.iwmh.spotifyalbumer`
   - SKU: `spotify-albumer-001`（任意の一意な文字列）

#### 3.4.2 App情報の設定

**App情報タブ:**
- 名前（ストアに表示）
- サブタイトル（30文字）
- カテゴリ: ミュージック
- コンテンツ配信権: 該当なし
- 年齢制限指定: 質問に回答

**価格および配信状況:**
- 価格: 無料
- 配信する国/地域を選択

#### 3.4.3 バージョン情報

**App Store タブ:**
- スクリーンショット（必須）
  - 6.7インチ（iPhone 15 Pro Max）: 1290 x 2796
  - 6.5インチ（iPhone 11 Pro Max）: 1284 x 2778
  - 5.5インチ（iPhone 8 Plus）: 1242 x 2208
  - iPad Pro 12.9インチ: 2048 x 2732
- プロモーションテキスト（170文字）
- 概要（4000文字）
- キーワード（100文字、カンマ区切り）
- サポートURL
- マーケティングURL（オプション）
- プライバシーポリシーURL

#### 3.4.4 App Review情報

- 連絡先情報
- サインイン情報（テストアカウント）
- 添付ファイル（必要に応じて）
- 備考（審査員への説明）

### 3.5 TestFlightでのテスト

1. Xcode または Transporter でビルドをアップロード
2. App Store Connect で「TestFlight」タブ
3. 処理完了後（約15〜30分）
4. テスターを追加:
   - 内部テスター: チームメンバー（最大100人）
   - 外部テスター: メールで招待（最大10,000人、審査必要）

### 3.6 本番公開

1. App Store タブで「ビルド」を選択
2. 「審査へ提出」
3. Appleの審査（通常1〜3日）
4. 承認後、自動公開または手動公開

---

## 4. GitHub Actionsによる自動化

### 4.1 ディレクトリ構成

```
.github/
├── workflows/
│   ├── ci.yml              # プルリクエスト時のCI
│   ├── deploy-android.yml  # Android デプロイ
│   └── deploy-ios.yml      # iOS デプロイ
└── copilot-instructions.md
```

### 4.2 必要なシークレットの設定

GitHub リポジトリの Settings → Secrets and variables → Actions で以下を設定:

#### Android用シークレット

| シークレット名 | 説明 |
|---------------|------|
| `KEYSTORE_BASE64` | キーストアファイルをBase64エンコードしたもの |
| `KEYSTORE_PASSWORD` | キーストアのパスワード |
| `KEY_ALIAS` | キーのエイリアス（通常 `upload`） |
| `KEY_PASSWORD` | キーのパスワード |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Play Console サービスアカウントのJSON |

**Base64エンコードの方法:**
```bash
# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard

# macOS/Linux
base64 -i upload-keystore.jks | pbcopy
```

**サービスアカウントの作成:**
1. Google Cloud Console でプロジェクト作成
2. 「APIとサービス」→「認証情報」→「サービスアカウント作成」
3. JSON キーをダウンロード
4. Google Play Console で API アクセスを有効化し、サービスアカウントをリンク

#### iOS用シークレット

| シークレット名 | 説明 |
|---------------|------|
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API キーID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | 発行者ID |
| `APP_STORE_CONNECT_API_KEY_BASE64` | APIキー(.p8)をBase64エンコード |
| `MATCH_PASSWORD` | fastlane match の暗号化パスワード |
| `MATCH_GIT_BASIC_AUTHORIZATION` | 証明書リポジトリ用のGit認証 |
| `IOS_TEAM_ID` | Apple Developer Team ID |

**App Store Connect API キーの作成:**
1. App Store Connect → ユーザーとアクセス → キー
2. 「キーを生成」→「App Manager」ロール
3. キーID、発行者ID をメモ
4. .p8 ファイルをダウンロード

### 4.3 CIワークフロー（ci.yml）

プルリクエスト時に自動でテストを実行します。

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main, develop ]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.1'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

### 4.4 Android デプロイワークフロー

```yaml
# .github/workflows/deploy-android.yml
name: Deploy Android

on:
  push:
    tags:
      - 'v*'  # v1.0.0 などのタグでトリガー
  workflow_dispatch:
    inputs:
      track:
        description: 'Release track'
        required: true
        default: 'internal'
        type: choice
        options:
          - internal
          - alpha
          - beta
          - production

env:
  FLUTTER_VERSION: '3.27.1'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Decode Keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks

      - name: Create key.properties
        run: |
          cat > android/key.properties << EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=upload-keystore.jks
          EOF

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT_JSON }}
          packageName: com.iwmh.spotifyalbumer
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: ${{ github.event.inputs.track || 'internal' }}
          status: completed
```

### 4.5 iOS デプロイワークフロー

```yaml
# .github/workflows/deploy-ios.yml
name: Deploy iOS

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    inputs:
      destination:
        description: 'Deploy destination'
        required: true
        default: 'testflight'
        type: choice
        options:
          - testflight
          - appstore

env:
  FLUTTER_VERSION: '3.27.1'

jobs:
  build-and-deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install Fastlane
        run: |
          cd ios
          gem install bundler
          bundle install

      - name: Setup App Store Connect API Key
        run: |
          mkdir -p ~/.appstoreconnect/private_keys
          echo "${{ secrets.APP_STORE_CONNECT_API_KEY_BASE64 }}" | base64 --decode > ~/.appstoreconnect/private_keys/AuthKey_${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}.p8

      - name: Build and Deploy to TestFlight
        if: ${{ github.event.inputs.destination == 'testflight' || github.event.inputs.destination == '' }}
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_BASIC_AUTHORIZATION }}
          IOS_TEAM_ID: ${{ secrets.IOS_TEAM_ID }}
        run: |
          cd ios
          bundle exec fastlane beta

      - name: Build and Deploy to App Store
        if: ${{ github.event.inputs.destination == 'appstore' }}
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_ISSUER_ID }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_BASIC_AUTHORIZATION }}
          IOS_TEAM_ID: ${{ secrets.IOS_TEAM_ID }}
        run: |
          cd ios
          bundle exec fastlane release
```

### 4.6 Fastlane設定（iOS）

#### 4.6.1 Gemfile

`ios/Gemfile`:

```ruby
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

#### 4.6.2 Fastfile

`ios/fastlane/Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    setup_ci if ENV['CI']
    
    app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_API_ISSUER_ID"],
      key_filepath: "~/.appstoreconnect/private_keys/AuthKey_#{ENV['APP_STORE_CONNECT_API_KEY_ID']}.p8",
      in_house: false
    )
    
    match(
      type: "appstore",
      readonly: is_ci,
      git_basic_authorization: Base64.strict_encode64(ENV["MATCH_GIT_BASIC_AUTHORIZATION"])
    )
    
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store",
      output_directory: "../build/ios/ipa"
    )
    
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
  
  desc "Push a new release build to App Store"
  lane :release do
    setup_ci if ENV['CI']
    
    app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_API_ISSUER_ID"],
      key_filepath: "~/.appstoreconnect/private_keys/AuthKey_#{ENV['APP_STORE_CONNECT_API_KEY_ID']}.p8",
      in_house: false
    )
    
    match(
      type: "appstore",
      readonly: is_ci,
      git_basic_authorization: Base64.strict_encode64(ENV["MATCH_GIT_BASIC_AUTHORIZATION"])
    )
    
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store",
      output_directory: "../build/ios/ipa"
    )
    
    upload_to_app_store(
      submit_for_review: false,
      automatic_release: false,
      skip_screenshots: true,
      skip_metadata: true
    )
  end
end
```

#### 4.6.3 Matchfile

`ios/fastlane/Matchfile`:

```ruby
git_url("https://github.com/YOUR_USERNAME/certificates.git")

storage_mode("git")

type("appstore")

app_identifier(["com.iwmh.spotifyalbumer"])

team_id(ENV["IOS_TEAM_ID"])
```

### 4.7 リリースフロー

```
開発フロー:
1. feature ブランチで開発
2. develop ブランチへ PR → CI が自動実行
3. main ブランチへマージ

リリースフロー:
1. バージョンを更新 (pubspec.yaml)
2. タグを作成: git tag v1.0.0
3. タグをプッシュ: git push origin v1.0.0
4. GitHub Actions が自動でビルド・デプロイ

手動リリース:
1. GitHub Actions タブ
2. 対象のワークフローを選択
3. "Run workflow" をクリック
4. トラック（internal/beta/production）を選択
5. 実行
```

---

## 5. Push通知の実装

### 5.1 Push通知の仕組み

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Push通知のアーキテクチャ                        │
└─────────────────────────────────────────────────────────────────────┘

┌─────────┐    ┌──────────────┐    ┌─────────────────┐    ┌─────────┐
│  Your   │───▶│   Firebase   │───▶│  APNs / FCM     │───▶│  User   │
│  Server │    │   Cloud      │    │  (Apple/Google) │    │  Device │
│         │    │   Messaging  │    │                 │    │         │
└─────────┘    └──────────────┘    └─────────────────┘    └─────────┘
     │                                                          │
     │              Push通知の流れ                               │
     │                                                          │
     │  1. サーバーがFCMにメッセージ送信                          │
     │  2. FCMがプラットフォーム別に振り分け                      │
     │     - iOS: APNs (Apple Push Notification service)        │
     │     - Android: FCM直接                                   │
     │  3. デバイスに通知が届く                                  │
     └──────────────────────────────────────────────────────────┘
```

### 5.2 Push通知の種類

| 種類 | 説明 | 表示 |
|------|------|------|
| **Notification Message** | FCMが自動処理、アプリがバックグラウンドでも表示 | システム通知 |
| **Data Message** | アプリが処理、カスタムロジック可能 | アプリ実装次第 |
| **Notification + Data** | 両方の組み合わせ | 両方 |

### 5.3 Firebase プロジェクトのセットアップ

#### 5.3.1 Firebase Console での設定

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. 「プロジェクトを追加」
3. プロジェクト名: `spotify-albumer`
4. Google アナリティクスを有効化（オプション）

#### 5.3.2 Android アプリの追加

1. 「Android アプリを追加」
2. パッケージ名: `com.iwmh.spotifyalbumer`
3. アプリのニックネーム: `Spotify Albumer Android`
4. `google-services.json` をダウンロード
5. `android/app/` に配置

#### 5.3.3 iOS アプリの追加

1. 「iOS アプリを追加」
2. バンドルID: `com.iwmh.spotifyalbumer`
3. アプリのニックネーム: `Spotify Albumer iOS`
4. `GoogleService-Info.plist` をダウンロード
5. `ios/Runner/` に配置

### 5.4 APNs 証明書の設定（iOS）

#### 5.4.1 APNs認証キーの作成（推奨）

1. Apple Developer Portal → Keys
2. 「+」→「Apple Push Notifications service (APNs)」
3. キー名を入力して作成
4. `.p8` ファイルをダウンロード
5. Key ID をメモ

#### 5.4.2 Firebase に APNs キーを登録

1. Firebase Console → プロジェクト設定
2. 「Cloud Messaging」タブ
3. 「APNs 認証キー」セクション
4. `.p8` ファイルをアップロード
5. Key ID と Team ID を入力

### 5.5 Flutter での実装

#### 5.5.1 パッケージのインストール

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^3.8.0
  firebase_messaging: ^15.1.5
  flutter_local_notifications: ^18.0.1
```

```bash
fvm flutter pub get
```

#### 5.5.2 Android の設定

**android/build.gradle.kts:**

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

**android/app/build.gradle.kts:**

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // 追加
}

android {
    // ... 既存の設定
    
    defaultConfig {
        // ... 既存の設定
        
        // 通知チャンネル用
        multiDexEnabled = true
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
}
```

**AndroidManifest.xml に追加:**

```xml
<manifest>
    <application>
        <!-- 通知アイコン（オプション） -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_notification" />
        
        <!-- 通知カラー（オプション） -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
        
        <!-- 通知チャンネル（Android 8.0+） -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
    </application>
</manifest>
```

#### 5.5.3 iOS の設定

**ios/Runner/AppDelegate.swift:**

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // プッシュ通知の権限リクエスト
    UNUserNotificationCenter.current().delegate = self
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // APNsトークンの受信
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
```

**ios/Runner/Info.plist に追加:**

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

**Xcode での設定:**
1. Runner.xcworkspace を開く
2. Runner ターゲット → Signing & Capabilities
3. 「+ Capability」→「Push Notifications」
4. 「+ Capability」→「Background Modes」→「Remote notifications」にチェック

#### 5.5.4 Dart コードの実装

**lib/shared/services/push_notification_service.dart:**

```dart
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// バックグラウンドメッセージハンドラ（トップレベル関数である必要がある）
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

/// Push通知サービスのプロバイダー
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

/// FCMトークンのプロバイダー
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(pushNotificationServiceProvider);
  return service.getToken();
});

/// Push通知サービス
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// 初期化
  Future<void> initialize() async {
    // バックグラウンドハンドラの設定
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 通知の権限リクエスト
    await _requestPermission();

    // ローカル通知の初期化
    await _initializeLocalNotifications();

    // フォアグラウンドでの通知表示設定（iOS）
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // メッセージリスナーの設定
    _setupMessageListeners();
  }

  /// 通知権限のリクエスト
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  /// ローカル通知の初期化
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android用の通知チャンネル作成
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// メッセージリスナーの設定
  void _setupMessageListeners() {
    // アプリがフォアグラウンドの時
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 通知タップでアプリが開かれた時
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// フォアグラウンドでのメッセージ処理
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    final notification = message.notification;
    final android = message.notification?.android;

    // フォアグラウンドでローカル通知を表示
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// 通知タップでアプリが開かれた時の処理
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.data}');
    // ここでナビゲーションなどの処理を行う
    _handleNotificationNavigation(message.data);
  }

  /// 通知タップ時の処理
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // ペイロードに基づいて画面遷移などを行う
  }

  /// 通知に基づくナビゲーション
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // 例: data['type'] に基づいて画面遷移
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'album':
        // アルバム詳細画面に遷移
        print('Navigate to album: $id');
        break;
      case 'playlist':
        // プレイリスト画面に遷移
        print('Navigate to playlist: $id');
        break;
      default:
        // ホーム画面
        print('Navigate to home');
    }
  }

  /// FCMトークンの取得
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    return token;
  }

  /// トークン更新のリスナー
  void onTokenRefresh(Function(String) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }

  /// 特定のトピックを購読
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// トピックの購読解除
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  /// アプリ終了時に通知から起動したかチェック
  Future<RemoteMessage?> getInitialMessage() async {
    return _messaging.getInitialMessage();
  }
}
```

**lib/main.dart の修正:**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase の初期化
  await Firebase.initializeApp();
  
  // Push通知サービスの初期化
  final pushService = PushNotificationService();
  await pushService.initialize();
  
  // アプリ終了状態から通知で起動した場合の処理
  final initialMessage = await pushService.getInitialMessage();
  if (initialMessage != null) {
    // 初期メッセージに基づく処理
    print('App opened from notification: ${initialMessage.data}');
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 5.6 サーバーからの通知送信

#### 5.6.1 Firebase Admin SDK（Node.js）

```javascript
// server/send-notification.js
const admin = require('firebase-admin');

// サービスアカウントの初期化
admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

// 単一デバイスへの送信
async function sendToDevice(token, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    token: token,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.error('Error sending message:', error);
    throw error;
  }
}

// トピックへの送信
async function sendToTopic(topic, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    topic: topic,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent to topic:', response);
    return response;
  } catch (error) {
    console.error('Error sending to topic:', error);
    throw error;
  }
}

// 複数デバイスへの送信
async function sendToMultipleDevices(tokens, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    tokens: tokens, // 最大500トークン
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`${response.successCount} messages were sent successfully`);
    return response;
  } catch (error) {
    console.error('Error sending messages:', error);
    throw error;
  }
}

// 使用例
sendToDevice(
  'FCM_DEVICE_TOKEN',
  '新しいアルバム',
  'お気に入りのアーティストが新しいアルバムをリリースしました！',
  {
    type: 'album',
    id: 'spotify_album_id',
  }
);
```

#### 5.6.2 HTTP API での送信（REST）

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "FCM_DEVICE_TOKEN",
      "notification": {
        "title": "新しいアルバム",
        "body": "お気に入りのアーティストが新しいアルバムをリリースしました！"
      },
      "data": {
        "type": "album",
        "id": "spotify_album_id"
      }
    }
  }'
```

### 5.7 Push通知のテスト

#### 5.7.1 Firebase Console からの送信

1. Firebase Console → Cloud Messaging
2. 「最初のキャンペーンを作成」
3. 通知タイトルとテキストを入力
4. ターゲット（デバイス、トピック、ユーザーセグメント）を選択
5. 「テスト メッセージを送信」

#### 5.7.2 FCMトークンの取得

```dart
// アプリ内でトークンを表示
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
// このトークンをコピーしてテストに使用
```

### 5.8 Push通知のベストプラクティス

1. **ユーザー体験**
   - 適切なタイミングで権限をリクエスト
   - 通知の頻度を適切に保つ
   - 有益な情報のみを通知

2. **セキュリティ**
   - FCMトークンは機密情報として扱う
   - サーバーキーは絶対に公開しない
   - HTTPS でトークンを送信

3. **トークン管理**
   - トークンは定期的に更新される
   - 無効なトークンは削除
   - トークン更新時にサーバーに通知

4. **通知チャンネル（Android）**
   - 用途別にチャンネルを作成
   - ユーザーが個別に管理可能

---

## 6. トラブルシューティング

### 6.1 一般的な問題

#### ビルドエラー

```bash
# クリーンビルド
fvm flutter clean
fvm flutter pub get
fvm flutter build appbundle --release

# iOS の場合
cd ios
pod deintegrate
pod install
cd ..
fvm flutter build ipa --release
```

#### 署名エラー（Android）

```
Error: Keystore was tampered with, or password was incorrect
```

→ キーストアのパスワードが間違っている。`key.properties` を確認。

#### 署名エラー（iOS）

```
No signing certificate "iOS Distribution" found
```

→ プロビジョニングプロファイルと証明書が一致していない。Xcode で確認。

### 6.2 Push通知の問題

#### 通知が届かない（iOS）

1. APNs証明書/キーが正しく設定されているか確認
2. Info.plist に `UIBackgroundModes` が設定されているか確認
3. デバイスの通知設定を確認

#### 通知が届かない（Android）

1. `google-services.json` が正しい場所にあるか確認
2. build.gradle に google-services プラグインがあるか確認
3. AndroidManifest.xml の設定を確認

### 6.3 GitHub Actions の問題

#### シークレットが読み取れない

- シークレット名のスペルを確認
- Base64エンコードが正しいか確認
- ワークフローファイルの構文を確認

#### ビルドがタイムアウト

- キャッシュを有効化
- 不要なステップを削除
- macOS ランナーは時間がかかるため注意

---

## 付録

### A. チェックリスト

#### リリース前チェック

- [ ] アプリアイコンが設定済み
- [ ] スプラッシュスクリーンが設定済み
- [ ] バージョン番号を更新
- [ ] プライバシーポリシーを準備
- [ ] スクリーンショットを準備
- [ ] アプリの説明文を準備
- [ ] テストを実行して全てパス
- [ ] リリースビルドが正常に作成される
- [ ] 署名が正しく設定されている

#### Push通知チェック

- [ ] Firebase プロジェクトを作成
- [ ] google-services.json / GoogleService-Info.plist を配置
- [ ] APNs キーを Firebase に登録
- [ ] アプリで権限をリクエスト
- [ ] FCMトークンを取得できる
- [ ] テスト通知が届く

### B. 参考リンク

- [Flutter 公式ドキュメント - リリース](https://docs.flutter.dev/deployment)
- [Google Play Console ヘルプ](https://support.google.com/googleplay/android-developer/)
- [App Store Connect ヘルプ](https://developer.apple.com/help/app-store-connect/)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [GitHub Actions ドキュメント](https://docs.github.com/en/actions)

### C. 更新履歴

| 日付 | 内容 |
|------|------|
| 2024-12-22 | 初版作成 |

---

このガイドに関する質問や改善提案があれば、Issue を作成してください。
