# Publishing Guide (Google Play + Apple App Store) — `spotify_albumer`

This guide is written for a complete beginner and is tailored to this repo.

- Android package name currently: `com.example.spotify_albumer` (you must change this before publishing)
- App version currently (from `pubspec.yaml`): `1.0.0+1`
- You are on **Windows**. Android publishing is doable on Windows; iOS publishing requires access to **macOS**.

This guide is **GitHub Actions-first**:

- Local machine: for day-to-day dev, screenshots, store listing work
- GitHub Actions: for consistent builds, signing, and uploads (Play Console / TestFlight)

If you want a Japanese guide, see `APP_DEPLOYMENT_GUIDE.md` (older/longer). This file is the “do-this-next” checklist.

---

## 0) What you need (one-time setup)

### Accounts

1. **Google Play Developer** account ($25 one-time)
   - Sign up: https://play.google.com/console/signup
2. **Apple Developer Program** ($99/year)
   - Sign up: https://developer.apple.com/programs/
   - You also need **App Store Connect** access (created automatically for the team).

### Hardware / OS reality check

- **Android**: Windows is fine.
- **iOS**: You need **macOS + Xcode** to build and upload.
  - Options:
    - A physical Mac
    - A cloud Mac service (MacStadium, etc.)
    - CI services that can build/sign iOS (Codemagic, Bitrise, GitHub Actions with a macOS runner) — still requires Apple Developer account.

### Tooling for this repo

This project’s instructions say: **use `fvm`** for Flutter/Dart.

In this repo, VS Code is configured to use Flutter **3.38.3** (see `.vscode/settings.json`).
In CI we’ll pin Flutter to the same version so builds are reproducible.

- Verify FVM:
  - `fvm --version`
- Verify Flutter:
  - `fvm flutter --version`

Recommended one-time health checks:

```bash
fvm flutter doctor -v
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```

---

## 0.1) GitHub Actions: the recommended release pipeline

You will typically have **3 workflows**:

1. **CI** (runs on every PR/push)
  - `flutter analyze`, `flutter test`
2. **Android Release** (manual or tag-triggered)
  - Builds a signed `.aab`
  - Uploads to **Google Play Internal testing**
3. **iOS Release** (manual or tag-triggered)
  - Builds a signed `.ipa` on a **macOS runner**
  - Uploads to **TestFlight**

This repo includes workflow templates that you can customize in `.github/workflows/`.

### Recommended triggers

- CI: `pull_request` + `push` to `main`
- Releases: `workflow_dispatch` (button click) and/or Git tags like `v1.0.0+1`

### Where secrets live

GitHub → your repo → **Settings → Secrets and variables → Actions**

- Use **Secrets** for private data (keystore, passwords, API keys)
- Use **Variables** for non-sensitive values (track name, package name)

Recommended GitHub **Variables** for this repo:

- `ANDROID_PACKAGE_NAME` (your final Android `applicationId`, e.g. `com.yourcompany.spotifyalbumer`)
- `IOS_BUNDLE_ID` (your final iOS Bundle Identifier, e.g. `com.yourcompany.spotifyalbumer`)
---

## 1) Decide your “forever” app identity (do this before any store upload)

You need stable identifiers. Once you publish, changing them is painful (or impossible).

### 1.1 Pick a unique app ID / bundle ID

Choose something like:

- Android `applicationId`: `com.yourcompany.spotifyalbumer`
- iOS `Bundle Identifier`: `com.yourcompany.spotifyalbumer`

Rules of thumb:

- Must be globally unique
- Lowercase letters, numbers, dots
- Reverse-domain style

### 1.2 Update Android identifiers (required)

Right now, Android uses the template ID `com.example.spotify_albumer` in `android/app/build.gradle.kts`.

You must update **both**:

- `applicationId`
- `namespace`

In practice, you’ll change:

- `namespace = "..."`
- `applicationId = "..."`

Then you may need to update Kotlin/manifest package paths if your project contains Android-side code (many Flutter apps don’t).

### 1.3 Confirm iOS identifier

iOS uses `$(PRODUCT_BUNDLE_IDENTIFIER)` (set inside Xcode).

- You will set the Bundle Identifier in Xcode:
  - `ios/Runner.xcworkspace` → Runner target → Signing & Capabilities → Bundle Identifier

---

## 2) Prepare required store materials (do this once, used on both stores)

You will need these *before* you can ship:

- App name
- Short description + full description
- Support contact email
- Support URL (can be a simple page)
- **Privacy Policy URL** (required because you handle auth + user data)
- App icon (1024×1024 source)
- Screenshots (from real devices/emulators)

### 2.1 Privacy policy (don’t skip)

Because this app uses Spotify OAuth and stores tokens (via `flutter_secure_storage`), you must provide a privacy policy.

Minimum contents:

- What data you access (Spotify account data you request via scopes)
- What you store on-device (tokens, user preferences)
- Whether you share data with third parties (Spotify is a third party)
- Contact for deletion requests

Hosting options:

- GitHub Pages
- A simple static website
- Notion public page

---

## 3) Android: publish to Google Play

### 3.1 Create a release signing key (one-time)

This key signs your Android releases. **If you lose it, you can lose update ability**.

1. Create a keystore (run from repo root):

```bash
cd android\app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties` (DO NOT commit this file):

```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

3. Ensure git ignores secrets:

- Confirm `android/.gitignore` includes:
  - `key.properties`
  - `*.jks`

### 3.1.1 Store Android signing secrets for GitHub Actions

GitHub Actions cannot read your local `upload-keystore.jks` unless you provide it as a secret.

1. Base64-encode the keystore (PowerShell):

```powershell
$bytes = [System.IO.File]::ReadAllBytes("android\\app\\upload-keystore.jks")
[Convert]::ToBase64String($bytes) | Set-Clipboard
```

2. Add these GitHub **Secrets**:

- `ANDROID_KEYSTORE_BASE64` (paste the clipboard content)
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS` (usually `upload`)
- `ANDROID_KEY_PASSWORD`

The workflow will reconstruct `upload-keystore.jks` at build time.

### 3.2 Configure Gradle signing for release (required)

In `android/app/build.gradle.kts`:

- Load `key.properties`
- Create `signingConfigs.release`
- Set `buildTypes.release.signingConfig` to the release config

Important:

- When you publish on Play, enable **Play App Signing**.
  - You still keep your upload key safe.

### 3.2.1 Create a Google Play service account (for GitHub Actions upload)

To upload builds automatically, you create a service account JSON key and grant it access.

1. In Play Console: **Setup → API access**
2. Link a Google Cloud project (if not already linked)
3. Create a **Service Account** and a **JSON key**
4. In Play Console: grant the service account permissions (minimum: release manager)
5. Add GitHub **Secret**:
  - `PLAY_SERVICE_ACCOUNT_JSON` (paste the whole JSON contents)

The Android release workflow uses this to upload your `.aab`.

### 3.3 Set version and build number

Version comes from `pubspec.yaml`:

- `version: 1.0.0+1`
  - `1.0.0` = human-visible version
  - `1` = build number (Android `versionCode`)

Before each store submission, increment the build number:

- `1.0.0+2`, `1.0.0+3`, etc.

### 3.4 Build an Android App Bundle (AAB)

From repo root:

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter build appbundle --release
```

Output:

- `build/app/outputs/bundle/release/app-release.aab`

### 3.4.1 Build via GitHub Actions (recommended)

Instead of building locally, you can use the included workflow:

- `.github/workflows/release-android.yml`

It will:

- Set up Flutter 3.38.3
- Restore dependencies
- Build a signed `app-release.aab`
- Upload to Google Play **internal testing** track

### 3.5 Create the app in Play Console

1. Go to https://play.google.com/console
2. **Create app**
3. Fill in:
   - App name
   - Default language
   - App/Game
   - Free/Paid

### 3.6 Complete required Play Console sections

Google blocks publishing until these are done:

- Store listing (descriptions, screenshots, feature graphic)
- App access (if login required: provide test credentials or instructions)
- Content rating
- Target audience
- Data safety form
- Privacy policy URL
- Ads declaration (Yes/No)

### 3.7 Upload and release

1. Go to **Testing → Internal testing** (recommended first)
2. Create a release and upload your `.aab`
3. Add testers (your email) and install from the test link
4. Fix issues, then promote:
   - Internal → Closed/Open testing → Production

Expect review times from hours to days.

---

## 4) iOS: publish to the App Store

Because you are on Windows, treat this as two parts:

- Part A: do the Apple account + app setup anywhere
- Part B: do the build/sign/upload on macOS

### 4.1 Apple setup (one-time)

1. Enroll in Apple Developer Program
2. Open App Store Connect: https://appstoreconnect.apple.com/
3. Create the app record:
   - My Apps → “+” → New App
   - Choose:
     - Bundle ID (must match Xcode)
     - SKU (any unique string, e.g. `spotify-albumer-001`)

### 4.2 Get a macOS build environment

You need one of:

- Local Mac with Xcode installed
- Cloud Mac / CI (Codemagic/Bitrise/macOS GitHub runner)

If you want to “greatly utilize GitHub Actions”, use the **GitHub-hosted macOS runner**.

### 4.3 Configure signing + bundle identifier (on macOS)

On macOS:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Runner target → Signing & Capabilities
3. Set:
   - Team
   - Bundle Identifier (the one you picked)
4. Let Xcode manage signing (simplest for beginners)

### 4.3.1 iOS signing in CI (recommended approach)

For iOS on CI, the most reliable pattern is:

- Use **fastlane + match** to fetch signing certs/profiles
- Use **App Store Connect API key** (not your Apple ID password)
- Build on GitHub Actions `macos-latest` runner
- Upload to TestFlight

You’ll set up a separate private git repo for match (Apple signing assets).

Practical note (CI authentication):

- If your match repo is private, `fastlane match` must be able to clone it in CI.
- The simplest beginner approach is to put an HTTPS URL with a GitHub token into the `MATCH_GIT_URL` **secret** (treat it like a password).
  - Example shape: `https://x-access-token:YOUR_TOKEN@github.com/owner/certs-repo.git`
  - Use a fine-scoped token with the minimum permissions needed (read-only for `readonly: true`).

GitHub **Secrets** you will need:

- `ASC_KEY_ID` (App Store Connect API Key ID)
- `ASC_ISSUER_ID` (App Store Connect Issuer ID)
- `ASC_API_KEY_P8_BASE64` (base64 of the `.p8` private key file)
- `APPLE_TEAM_ID` (your Apple Developer Team ID)
- `MATCH_GIT_URL` (URL to the private cert/profile repo)
- `MATCH_PASSWORD` (encryption password for match)

Notes:

- The iOS workflow only works once your Bundle ID exists in Apple Developer portal.
- You still must complete App Store Connect metadata manually (screenshots, privacy, etc.).

### 4.4 Set the version/build number

This repo uses Flutter build variables:

- `CFBundleShortVersionString` = `$(FLUTTER_BUILD_NAME)`
- `CFBundleVersion` = `$(FLUTTER_BUILD_NUMBER)`

So you control it via `pubspec.yaml` version or build flags.

Example build numbers:

- First upload: `1.0.0+1`
- Next upload: `1.0.0+2`

### 4.5 Build the iOS release

Option 1 (Flutter CLI):

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter build ipa --release
```

Option 2 (Xcode Archive, easiest to upload):

- Xcode → Product → Archive
- Organizer opens → Distribute App → App Store Connect

### 4.5.1 Build + upload via GitHub Actions (recommended)

Use the included workflow:

- `.github/workflows/release-ios.yml`

It will:

- Set up Flutter 3.38.3
- Install fastlane
- Fetch signing via match
- Build an IPA
- Upload to TestFlight

### 4.6 Upload + submit for review

In App Store Connect, you must fill:

- App information
- Pricing and availability
- App privacy questionnaire
- Age rating
- Screenshots (iPhone sizes required; iPad optional unless you support iPad-only)
- Review information (contact + test account if login required)

Then submit for review.

Apple review commonly takes 1–3 days, sometimes longer.

---

## 5) Spotify-specific checklist (important)

Because this app authenticates with Spotify:

- Ensure you are using **Authorization Code with PKCE** (good for mobile). Never ship a client secret inside the app.
- In the Spotify Developer Dashboard:
  - Add your **Redirect URI(s)** for both Android and iOS
  - Ensure the redirect scheme/host matches what the app uses

In iOS, this repo currently defines a URL scheme in `ios/Runner/Info.plist`:

- `spotifyalbumer.iwmh.com`

Make sure your Spotify redirect URI matches that exactly (or change both).

Also ensure:

- Your Privacy Policy explains Spotify data usage
- “App access” (Google) / “Review information” (Apple) includes test instructions

---

## 6) Suggested “first release” order (minimize pain)

1. Fix app identifiers (Android + iOS)
2. Create privacy policy + support URL
3. Configure Android signing + Play service account secrets
4. Publish Android to **Internal testing** (via GitHub Actions)
5. Set up App Store Connect API key + match repo/secrets
6. Upload iOS to **TestFlight** (via GitHub Actions), then submit for review

---

## 7) When something goes wrong (common beginner issues)

- **Android upload rejected: signing**
  - Make sure release build uses `signingConfigs.release`, not debug.
- **Play Console: “Data safety form” blocks release**
  - Fill it completely; mismatches can trigger rejection.
- **iOS build fails on Windows**
  - That’s expected. Use macOS.
- **App Review can’t log in**
  - Provide test credentials or a demo mode.

Additional CI/CD gotchas:

- **Android workflow fails: “Keystore was tampered with”**
  - Your base64 secret is corrupted (line breaks) or password is wrong.
- **Play upload fails: permission denied**
  - Service account wasn’t granted access in Play Console.
- **iOS workflow fails: match can’t decrypt**
  - `MATCH_PASSWORD` mismatch.
- **iOS workflow fails: no profiles found**
  - Bundle ID/team mismatch or you haven’t created the app/capabilities yet.

---

## 8) Next actions I can do for you

If you want, tell me your chosen app ID (e.g. `com.yourcompany.spotifyalbumer`) and I can:

- Update Android `namespace`/`applicationId` safely
- Add the release signing config to `android/app/build.gradle.kts`
- Add/verify `.gitignore` rules for keystores
- Add a minimal `PRIVACY_POLICY.md` template and a checklist for hosting it
