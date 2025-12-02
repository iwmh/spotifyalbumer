# Flutter アプリ公開ガイド - iOS & Android

このガイドでは、`spotify_albumer` アプリをGoogle Play StoreとApple App Storeに公開する手順を、初心者向けにステップバイステップで解説します。

---

## 目次

1. [事前準備](#事前準備)
2. [Android向け公開手順](#android向け公開手順)
3. [iOS向け公開手順](#ios向け公開手順)
4. [公開後の管理](#公開後の管理)
5. [トラブルシューティング](#トラブルシューティング)

---

## 事前準備

### 1. 開発者アカウントの取得

#### Google Play Developer アカウント（Android用）
- **費用**: $25（一度きりの登録料）
- **登録URL**: https://play.google.com/console/signup
- **必要なもの**:
  - Googleアカウント
  - クレジットカード
  - 本人確認書類（場合による）
- **所要時間**: 数時間〜2日程度（審査あり）

#### Apple Developer アカウント（iOS用）
- **費用**: $99/年（年間更新）
- **登録URL**: https://developer.apple.com/programs/enroll/
- **必要なもの**:
  - Apple ID
  - クレジットカード
  - 本人確認書類
- **所要時間**: 1〜2日程度（審査あり）

### 2. アプリの情報を準備

公開前に以下の情報を用意してください：

- **アプリ名**: 正式なアプリ名（32文字以内推奨）
- **アプリの説明**:
  - 短い説明（80文字程度）
  - 詳細な説明（4000文字以内）
- **アプリアイコン**:
  - Android: 512x512 PNG
  - iOS: 1024x1024 PNG（透過なし）
- **スクリーンショット**:
  - 各画面サイズで最低2枚、最大8枚
  - Android: 複数の解像度対応
  - iOS: 6.7インチ、6.5インチ必須
- **プライバシーポリシーURL**: 必須（無料ツール: [Privacy Policy Generator](https://app-privacy-policy-generator.nisrulz.com/)）
- **カテゴリ**: アプリのカテゴリ（音楽＆オーディオなど）
- **連絡先情報**: メールアドレス、サポートURL

---

## Android向け公開手順

### ステップ 1: キーストアの作成

キーストアは、アプリに署名するための重要なファイルです。**紛失すると更新できなくなる**ので厳重に保管してください。

#### 1.1 キーストアファイルを生成

**Windowsの場合:**

```bash
# PowerShellまたはコマンドプロンプトで実行
cd c:\Users\hiros\dev\spotify_albumer\android\app

keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**実行時の質問に回答**:
- パスワード: 覚えやすく安全なものを設定（2回入力）
- 名前と組織: 任意（本名または会社名）
- 組織単位、市区町村、都道府県、国コード: 任意

**重要**: このパスワードは後で使うので必ずメモしてください。

#### 1.2 キーストア情報をプロジェクトに設定

`android/key.properties` ファイルを作成（**このファイルは絶対にGitにコミットしない**）:

```properties
storePassword=<ステップ1.1で設定したパスワード>
keyPassword=<ステップ1.1で設定したパスワード>
keyAlias=upload
storeFile=upload-keystore.jks
```

#### 1.3 .gitignoreの確認

`android/.gitignore` に以下が含まれていることを確認:

```
key.properties
*.jks
```

### ステップ 2: build.gradle.kts の設定

`android/app/build.gradle.kts` を編集して署名設定を追加します。

#### 2.1 キーストア設定の読み込み

ファイルの先頭付近（`plugins` ブロックの後）に追加:

```kotlin
// キーストア設定の読み込み
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

#### 2.2 署名設定の追加

`android` ブロック内に以下を追加:

```kotlin
android {
    // 既存の設定...

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // 既存の設定...
        }
    }
}
```

#### 2.3 アプリバージョンの設定

同じファイル内で、バージョン情報を確認・更新:

```kotlin
android {
    defaultConfig {
        applicationId = "com.yourcompany.spotify_albumer"  // 一意のID
        minSdk = 21  // 最小Androidバージョン
        targetSdk = 34  // ターゲットAndroidバージョン
        versionCode = 1  // ビルド番号（更新の度に増やす）
        versionName = "1.0.0"  // ユーザー向けバージョン
    }
}
```

**重要**: `applicationId` はアプリの一意の識別子です。一度公開すると変更できません。

### ステップ 3: AndroidManifest.xml の設定

`android/app/src/main/AndroidManifest.xml` を確認・編集:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 必要な権限を追加 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- Spotify APIを使う場合など -->

    <application
        android:label="Spotify Albumer"  <!-- アプリ名 -->
        android:icon="@mipmap/ic_launcher"  <!-- アイコン -->
        android:usesCleartextTraffic="false">  <!-- HTTPSのみ -->
        <!-- 既存の設定... -->
    </application>
</manifest>
```

### ステップ 4: アプリアイコンの準備

#### 4.1 アイコンの生成

オンラインツールを使用（推奨）:
- [App Icon Generator](https://www.appicon.co/)
- [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/)

1024x1024のPNG画像をアップロードすると、全サイズが自動生成されます。

#### 4.2 アイコンの配置

生成されたファイルを以下のディレクトリに配置:

```
android/app/src/main/res/
  ├── mipmap-hdpi/ic_launcher.png
  ├── mipmap-mdpi/ic_launcher.png
  ├── mipmap-xhdpi/ic_launcher.png
  ├── mipmap-xxhdpi/ic_launcher.png
  └── mipmap-xxxhdpi/ic_launcher.png
```

### ステップ 5: リリースビルドの作成

#### 5.1 プロジェクトのクリーン

```bash
cd c:\Users\hiros\dev\spotify_albumer
flutter clean
flutter pub get
```

#### 5.2 App Bundleのビルド

Google Playは `.aab` (Android App Bundle) 形式を推奨:

```bash
flutter build appbundle --release
```

成功すると以下に生成されます:
```
build/app/outputs/bundle/release/app-release.aab
```

#### 5.3 ビルドの確認

ファイルサイズを確認（通常10〜50MB程度）:
```bash
dir build\app\outputs\bundle\release\
```

### ステップ 6: Google Play Consoleでの公開

#### 6.1 アプリの作成

1. [Google Play Console](https://play.google.com/console) にログイン
2. 「アプリを作成」をクリック
3. 必要情報を入力:
   - アプリ名: "Spotify Albumer"
   - デフォルトの言語: 日本語
   - アプリまたはゲーム: アプリ
   - 無料または有料: 無料
4. 「アプリを作成」をクリック

#### 6.2 ストアの設定（左メニュー「ストアの設定」→「メインのストアの掲載情報」）

**アプリの詳細**:
- アプリ名: 30文字以内
- 簡単な説明: 80文字以内
- 詳しい説明: 4000文字以内
- アプリアイコン: 512x512 PNG（透過なし）
- フィーチャーグラフィック: 1024x500 PNG（必須）

**スクリーンショット**:
- 最低2枚、最大8枚
- 携帯電話用（必須）: 320〜3840 px
- 7インチタブレット用（推奨）
- 10インチタブレット用（推奨）

**分類**:
- アプリカテゴリ: 音楽＆オーディオ
- タグ（オプション）

**連絡先の詳細**:
- メールアドレス（必須）
- 電話番号（オプション）
- ウェブサイト（オプション）

**プライバシーポリシー**:
- URL（必須）: プライバシーポリシーのURL

#### 6.3 コンテンツレーティング

1. 「コンテンツレーティング」セクションへ
2. メールアドレスとカテゴリ（「ユーティリティ、生産性、コミュニケーション、その他」など）を選択
3. アンケートに回答（暴力、性的コンテンツなどの有無）
4. レーティングを取得

#### 6.4 ターゲット層と内容

1. 「ターゲット層と内容」→「ターゲット層」
2. 対象年齢層を選択（通常「13歳以上」）
3. 「ストアでの表示」で適切なカテゴリを選択

#### 6.5 アプリのコンテンツ

以下の項目を完了:
- プライバシーポリシー（既に入力済み）
- 広告の有無
- データセーフティ（どのようなデータを収集するか）
- アプリへのアクセス権限（必要な権限の説明）

#### 6.6 リリースの作成（「リリース」→「製品版」）

1. 「新しいリリースを作成」をクリック
2. 「App Bundle」をアップロード:
   - `build/app/outputs/bundle/release/app-release.aab` をドラッグ＆ドロップ
3. リリース名: "1.0.0 (1)" など
4. リリースノート（日本語）を記入:
   ```
   初回リリース
   - Spotifyのアルバムを管理できます
   - プレイリストの表示機能
   ```
5. 「次へ」→「審査に送信」をクリック

#### 6.7 審査と公開

- 審査期間: 通常数時間〜数日
- 承認後、自動的にストアに公開されます
- ステータスは「製品版」ダッシュボードで確認可能

---

## iOS向け公開手順

**注意**: 以下の手順は**MacBook Pro**で実行してください。

### ステップ 1: Xcodeの準備

#### 1.1 Xcodeのインストール

```bash
# Mac App Storeからインストール（無料、10GB以上）
# または
xcode-select --install
```

最新版のXcode（15.0以上）をインストールしてください。

#### 1.2 Xcodeコマンドラインツールの設定

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### ステップ 2: Apple Developer アカウントの設定

#### 2.1 Xcodeにアカウントを追加

1. Xcodeを開く
2. メニューバー「Xcode」→「Settings」（または「Preferences」）
3. 「Accounts」タブ
4. 「+」ボタン→「Apple ID」
5. Apple Developer アカウントのApple IDでサインイン

### ステップ 3: プロジェクトの設定

#### 3.1 Xcodeでプロジェクトを開く

```bash
cd ~/dev/spotify_albumer
open ios/Runner.xcworkspace
```

**重要**: `.xcodeproj` ではなく `.xcworkspace` を開いてください。

#### 3.2 Bundle Identifierの設定

1. 左側のプロジェクトナビゲーターで「Runner」を選択
2. 「TARGETS」→「Runner」を選択
3. 「General」タブ
4. 「Identity」セクション:
   - **Display Name**: "Spotify Albumer"（ホーム画面に表示される名前）
   - **Bundle Identifier**: "com.yourcompany.spotifyalbumer"（一意のID、変更不可）

**Bundle Identifierの命名規則**:
- 逆ドメイン形式: `com.会社名.アプリ名`
- 小文字とドットのみ使用
- 例: `com.example.spotifyalbumer`

#### 3.3 バージョン情報の設定

同じ画面の「Identity」セクション:
- **Version**: "1.0.0"（ユーザー向けバージョン）
- **Build**: "1"（ビルド番号、更新の度に増やす）

#### 3.4 Signing & Capabilitiesの設定

1. 「Signing & Capabilities」タブ
2. **Team**: 自分のApple Developer チームを選択
3. **Automatically manage signing**: チェックを入れる（推奨）
4. Xcodeが自動的に証明書とプロビジョニングプロファイルを管理

エラーが出る場合:
- Bundle Identifierが他のアプリと重複していないか確認
- Apple Developer アカウントが有効か確認

### ステップ 4: Info.plistの設定

`ios/Runner/Info.plist` を編集して、必要な権限と情報を追加:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- アプリの表示名 -->
    <key>CFBundleDisplayName</key>
    <string>Spotify Albumer</string>
    
    <!-- アプリの説明（App Storeに表示） -->
    <key>CFBundleGetInfoString</key>
    <string>Spotifyのアルバムを管理</string>
    
    <!-- インターネット接続の説明（必要に応じて） -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
    
    <!-- その他必要な権限の説明 -->
    <!-- 例: カメラ、写真ライブラリなど -->
    
    <!-- 既存の設定はそのまま残す -->
</dict>
</plist>
```

### ステップ 5: アプリアイコンの設定

#### 5.1 アイコンの準備

- **サイズ**: 1024x1024 PNG
- **透過**: なし（背景色必須）
- **角丸**: 不要（iOSが自動で処理）

#### 5.2 Xcodeでアイコンを設定

1. Xcode左側のナビゲーターで `Runner/Assets.xcassets` を開く
2. `AppIcon` を選択
3. 1024x1024の画像を「App Store iOS」スロットにドラッグ＆ドロップ

または、複数サイズを個別に設定することも可能。

### ステップ 6: テストビルド

#### 6.1 シミュレーターでテスト

```bash
# プロジェクトディレクトリで
flutter run -d ios
```

または、Xcodeで:
1. デバイス選択メニューから任意のシミュレーターを選択
2. 「Product」→「Run」（または⌘R）

#### 6.2 実機でテスト（推奨）

実機（iPhoneやiPad）で動作確認:

1. デバイスをMacに接続
2. Xcodeのデバイス選択メニューから接続したデバイスを選択
3. 「Product」→「Run」

初回は「信頼されていない開発者」エラーが出る場合:
- デバイスで「設定」→「一般」→「VPNとデバイス管理」
- 自分の開発者アカウントを信頼

### ステップ 7: App Store Connect でアプリ登録

#### 7.1 App Store Connect にログイン

1. [App Store Connect](https://appstoreconnect.apple.com/) にアクセス
2. Apple Developer アカウントでログイン

#### 7.2 新規アプリの作成

1. 「マイApp」をクリック
2. 「+」ボタン→「新規App」
3. 必要情報を入力:
   - **プラットフォーム**: iOS
   - **名前**: "Spotify Albumer"（App Storeに表示される名前、30文字以内）
   - **プライマリ言語**: 日本語
   - **バンドルID**: Xcodeで設定したBundle Identifierを選択
   - **SKU**: 一意の識別子（例: "spotifyalbumer001"）
   - **ユーザーアクセス**: フルアクセス
4. 「作成」をクリック

#### 7.3 アプリ情報の入力

**「App情報」セクション**:
- カテゴリ:
  - プライマリ: 音楽
  - セカンダリ: （オプション）
- コンテンツ配信権: 自分が権利を持っているか確認

**「価格および配信可能状況」**:
- 価格: 無料
- 配信可能な国: すべての国・地域（または選択）

**「App プライバシー」**:
1. 「プライバシーポリシー」のURLを入力
2. 「データの取り扱い」を設定:
   - 収集するデータの種類を選択
   - データの使用目的を説明
   - データの共有について説明

### ステップ 8: リリースビルドの作成とアップロード

#### 8.1 Archiveの作成

**方法1: Xcodeから（推奨）**

1. Xcodeで `ios/Runner.xcworkspace` を開く
2. デバイス選択メニューから「Any iOS Device (arm64)」を選択
3. メニューバー「Product」→「Archive」
4. ビルドが完了すると「Organizer」ウィンドウが開く

**方法2: コマンドラインから**

```bash
cd ~/dev/spotify_albumer
flutter build ipa --release
```

成功すると以下に生成されます:
```
build/ios/ipa/spotify_albumer.ipa
```

#### 8.2 App Store Connect へアップロード

**Xcodeから（方法1を使った場合）**:

1. 「Organizer」ウィンドウで作成したアーカイブを選択
2. 「Distribute App」ボタンをクリック
3. 「App Store Connect」を選択→「Next」
4. 「Upload」を選択→「Next」
5. 署名オプション:
   - 「Automatically manage signing」を選択（推奨）
   - 「Next」
6. 確認画面で「Upload」をクリック

**Transporter アプリから（方法2を使った場合）**:

1. Mac App Storeから「Transporter」アプリをダウンロード
2. Transporterを開き、Apple IDでサインイン
3. `.ipa` ファイルをドラッグ＆ドロップ
4. 「配信」をクリック

#### 8.3 アップロードの確認

- アップロード完了後、App Store Connect の「アクティビティ」タブで確認
- 処理中: 10〜30分程度
- 処理完了後、ビルドが「ビルド」セクションに表示される

### ステップ 9: ストア掲載情報の設定

#### 9.1 スクリーンショット

App Store Connect の「App Store」タブ:

1. 「メディア」セクションへ
2. 必要な画面サイズのスクリーンショットをアップロード:
   - **6.7"ディスプレイ**（iPhone 15 Pro Max等）: 必須
   - **6.5"ディスプレイ**（iPhone 14 Plus等）: 必須
   - **5.5"ディスプレイ**（iPhone 8 Plus等）: 推奨
   - **iPad Pro（第3世代）12.9"**: iPad対応の場合

**スクリーンショットの取得方法**:

**シミュレーターから**:
```bash
# iPhone 15 Pro Max シミュレーターで起動
flutter run -d "iPhone 15 Pro Max"

# シミュレーター内でスクリーンショット撮影: ⌘S
# 保存先: ~/Desktop/
```

**実機から**:
- 音量上ボタン + サイドボタン（Face ID搭載機種）
- 「写真」アプリから転送

各画面サイズで最低2枚、最大10枚必要です。

#### 9.2 App プレビュー（オプション）

動画プレビュー（15〜30秒）をアップロード可能。

#### 9.3 説明文

**「App Store」タブ→「App情報」**:

- **プロモーションテキスト**（オプション、170文字）:
  ```
  Spotifyのアルバムを簡単に管理！お気に入りのアルバムをひと目で確認できます。
  ```

- **説明**（4000文字以内）:
  ```
  Spotify Albumerは、Spotifyのアルバムコレクションを効率的に管理できるアプリです。
  
  【主な機能】
  ・プレイリストの一覧表示
  ・アルバムの詳細情報
  ・お気に入り管理
  ・シンプルで使いやすいUI
  
  【こんな方におすすめ】
  ・大量のアルバムを整理したい
  ・Spotifyをよく使う
  ・音楽コレクションを可視化したい
  
  ※本アプリの使用にはSpotifyアカウントが必要です。
  ```

- **キーワード**（100文字、カンマ区切り）:
  ```
  spotify,音楽,アルバム,プレイリスト,管理,コレクション
  ```

- **サポートURL**: サポートサイトまたはGitHubページのURL

- **マーケティングURL**（オプション）: プロモーション用URL

#### 9.4 バージョン情報

**「このバージョンの新機能」**（4000文字以内）:
```
初回リリース

・Spotifyアカウントと連携
・プレイリスト一覧の表示
・シンプルで直感的なUI
```

### ステップ 10: 審査への提出

#### 10.1 最終チェックリスト

- [ ] すべての必須項目が入力済み
- [ ] スクリーンショットが全サイズアップロード済み
- [ ] プライバシーポリシーが設定済み
- [ ] ビルドが選択されている
- [ ] コンテンツレーティングが適切
- [ ] テストアカウント情報（必要な場合）

#### 10.2 テスト情報の入力（必要な場合）

アプリがログインを必要とする場合:

1. 「App レビュー情報」セクション
2. 「サインインが必要」にチェック
3. テストアカウントの情報を入力:
   - ユーザー名
   - パスワード
   - 使用方法の説明

#### 10.3 審査に提出

1. すべての情報を確認
2. 「審査に提出」ボタンをクリック
3. 輸出コンプライアンスの質問に回答:
   - 暗号化を使用していますか？
     - HTTPS通信のみ: 「いいえ」でOK
     - 独自の暗号化: 「はい」を選択し詳細を説明

#### 10.4 審査プロセス

- **ステータス**: 「審査待ち」→「審査中」→「承認待ち」→「販売準備完了」
- **審査期間**: 通常24〜48時間（初回は1週間程度かかる場合も）
- **結果通知**: メールで通知される
- **リジェクト**: 理由が説明され、修正後再提出可能

---

## 公開後の管理

### アプリの更新

#### Androidの更新

1. `android/app/build.gradle.kts` でバージョンを上げる:
   ```kotlin
   versionCode = 2  // 前回の1から増やす
   versionName = "1.0.1"  // 新しいバージョン
   ```

2. リリースビルドを作成:
   ```bash
   flutter build appbundle --release
   ```

3. Google Play Consoleで新しいリリースを作成
4. `.aab` ファイルをアップロード
5. リリースノートを記入
6. 審査に送信

#### iOSの更新

1. Xcodeでバージョンを上げる:
   - Version: "1.0.1"
   - Build: "2"（前回より大きい数字）

2. Archive を作成してアップロード（ステップ8と同じ）

3. App Store Connect で:
   - 「+バージョンまたはプラットフォーム」をクリック
   - 新しいバージョン番号を入力
   - 「このバージョンの新機能」を更新
   - 新しいビルドを選択
   - 審査に提出

### 分析とフィードバック

#### Google Play Console

- **統計情報**: インストール数、アクティブユーザー、評価
- **クラッシュとANR**: アプリのクラッシュレポート
- **ユーザーフィードバック**: レビューと評価

#### App Store Connect

- **App 分析**: ダウンロード数、セッション数、アクティブユーザー
- **評価とレビュー**: ユーザーの評価とコメント
- **クラッシュ**: クラッシュログ（Xcode Organizer で確認）

### ユーザーサポート

- メールやWebサイトでサポート対応
- よくある質問（FAQ）の作成
- アップデートでの問題修正

---

## トラブルシューティング

### Android関連

#### エラー: "Keystore file not found"

**原因**: `key.properties` のパスが間違っている

**解決策**:
```properties
# 絶対パスではなく相対パスを使う
storeFile=upload-keystore.jks  # ○
# storeFile=/full/path/to/upload-keystore.jks  # ×
```

#### エラー: "Duplicate class found"

**原因**: 依存関係の競合

**解決策**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build appbundle --release
```

#### エラー: "SDK version too old"

**原因**: `minSdk` が低すぎる

**解決策**:
`android/app/build.gradle.kts` で:
```kotlin
minSdk = 21  // Android 5.0以上
```

### iOS関連

#### エラー: "Signing for "Runner" requires a development team"

**原因**: Apple Developer アカウントが設定されていない

**解決策**:
1. Xcode「Settings」→「Accounts」でApple IDを追加
2. プロジェクトの「Signing & Capabilities」でTeamを選択

#### エラー: "No profiles for [Bundle ID] were found"

**原因**: Bundle Identifierが未登録または重複

**解決策**:
1. Bundle Identifierを一意のものに変更
2. 「Automatically manage signing」を有効化
3. Xcodeに自動作成させる

#### エラー: "Archive not found"

**原因**: ビルド設定が間違っている

**解決策**:
1. デバイスで「Any iOS Device」を選択
2. スキームを「Release」に設定
3. 再度「Product」→「Archive」

#### App Store Connect でビルドが表示されない

**原因**: 処理中またはエラー

**解決策**:
1. 10〜30分待つ
2. 「アクティビティ」タブで処理状況を確認
3. エラーメールが届いていないか確認
4. Info.plist の設定を確認（特に`ITSAppUsesNonExemptEncryption`）

### 共通の問題

#### 依存関係のエラー

```bash
# Flutter のクリーンとキャッシュクリア
flutter clean
flutter pub cache clean
flutter pub get

# ネイティブのクリーン
cd android && ./gradlew clean && cd ..  # Android
rm -rf ios/Pods && cd ios && pod install && cd ..  # iOS (Mac)
```

#### ビルドが遅い

- `.gitignore` でビルド成果物を除外
- 不要なアセットを削除
- ビルドキャッシュをクリーン
- Gradle daemon を使用（Android）

---

## 便利なリソース

### 公式ドキュメント

- [Flutter デプロイメント](https://docs.flutter.dev/deployment)
- [Android アプリ公開](https://docs.flutter.dev/deployment/android)
- [iOS アプリ公開](https://docs.flutter.dev/deployment/ios)
- [Google Play Console ヘルプ](https://support.google.com/googleplay/android-developer)
- [App Store Connect ヘルプ](https://developer.apple.com/help/app-store-connect/)

### ツール

- [App Icon Generator](https://www.appicon.co/) - アイコン生成
- [Screenshot Generator](https://www.mokupframes.com/) - スクリーンショット作成
- [Privacy Policy Generator](https://app-privacy-policy-generator.nisrulz.com/) - プライバシーポリシー作成
- [Fastlane](https://fastlane.tools/) - デプロイ自動化（上級者向け）

### コミュニティ

- [Flutter Discord](https://discord.gg/flutter)
- [Flutter日本語コミュニティ](https://flutter-jp.connpass.com/)
- [Stack Overflow - Flutter タグ](https://stackoverflow.com/questions/tagged/flutter)

---

## チェックリスト

### 公開前の最終確認

#### 全般
- [ ] アプリが正常に動作する
- [ ] クラッシュやバグがない
- [ ] UI が適切に表示される
- [ ] パフォーマンスが良好
- [ ] プライバシーポリシーが完成している
- [ ] サポート体制が整っている

#### Android
- [ ] キーストアを安全に保管している
- [ ] `applicationId` が一意である
- [ ] バージョン情報が正しい
- [ ] アプリアイコンが設定されている
- [ ] スクリーンショットが準備できている
- [ ] ストア掲載情報が完成している
- [ ] `.aab` ファイルのビルドが成功している

#### iOS
- [ ] Apple Developer アカウントが有効
- [ ] Bundle Identifier が一意である
- [ ] バージョン情報が正しい
- [ ] アプリアイコンが設定されている（1024x1024）
- [ ] スクリーンショットが全サイズ準備できている
- [ ] ストア掲載情報が完成している
- [ ] Archive のアップロードが成功している
- [ ] テストアカウント情報を提供している（必要な場合）

---

このガイドに従って、`spotify_albumer` アプリを無事に公開できることを願っています！

質問や問題が発生した場合は、公式ドキュメントやコミュニティを活用してください。

Happy Deploying! 🚀
