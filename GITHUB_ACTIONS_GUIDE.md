# GitHub Actions Build Guide

Panduan lengkap menggunakan GitHub Actions untuk build APK dan App Bundle secara otomatis.

## 📚 Quick Start

### 1. Generate Keystore

```bash
chmod +x scripts/generate-keystore.sh
./scripts/generate-keystore.sh
```

Atau menggunakan keytool langsung:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10950 \
  -alias upload
```

### 2. Setup GitHub Secrets

**Option A: Menggunakan Script (Recommended)**

```bash
chmod +x scripts/setup-github-secrets.sh
gh auth login  # Login dulu jika belum
./scripts/setup-github-secrets.sh
```

**Option B: Manual di GitHub**

1. Buka **Settings → Secrets and variables → Actions**
2. Set secrets berikut:

| Secret Name | Value |
|-------------|-------|
| `ANDROID_KEYSTORE_BASE64` | Keystore file (base64 encoded) |
| `KEY_STORE_PASSWORD` | Keystore password |
| `KEY_PASSWORD` | Key password |
| `ALIAS_USERNAME` | upload |

Encode keystore ke base64:

```bash
cat android/app/upload-keystore.jks | base64 -w 0 | pbcopy
```

### 3. Test Build Locally

```bash
chmod +x scripts/build-locally.sh
./scripts/build-locally.sh
```

### 4. Push & Release

```bash
# Commit changes
git add .
git commit -m "chore: add CI/CD configuration"
git push origin main

# Create release tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## 🔄 Workflows Overview

### Workflow 1: build-apk.yml

**Trigger:** Push, PR, Manual dispatch  
**Output:** Debug APK, Release APK, Test reports

```yaml
Events:
├── Push to main/develop
├── Pull Request to main/develop
└── Manual workflow_dispatch

Jobs:
├── build      → Build APK + Run tests
├── lint       → Code analysis
├── security   → Dependency scan
└── notify     → Build status
```

**Artifacts:**
- APK builds (30 days retention)
- Test coverage report
- GitHub Release (for tags)

### Workflow 2: build-app-bundle.yml

**Trigger:** Push to main, Tags, Manual dispatch  
**Output:** App Bundle (AAB)

```yaml
Events:
├── Push to main
├── Tag v*.*.*
└── Manual workflow_dispatch

Jobs:
└── build-bundle → Build AAB + Upload to Play Store
```

**Artifacts:**
- App Bundle (30 days retention)
- Play Store upload (internal testing)

---

## 📊 Build Triggers & Outputs

### 1. Pull Request Build

```bash
git checkout -b feature/new-feature
git push origin feature/new-feature
# Create PR to main

# Automatically:
# - Run build-apk.yml
# - Build debug APK
# - Run tests & lint
# - Show results in PR
```

**Output:**
- Debug APK
- Test coverage
- Lint report
- Security scan

### 2. Push to Develop/Main

```bash
git push origin develop
# or
git push origin main

# Automatically:
# - Run build-apk.yml
# - Build release APK
```

### 3. Release with Tag

```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0

# Automatically:
# - Run build-apk.yml (release)
# - Run build-app-bundle.yml
# - Create GitHub Release
# - Upload APK + AAB
```

### 4. Manual Dispatch

GitHub UI → Actions → Workflow name → Run workflow

- Choose branch
- Choose build type (debug/release)
- Run

---

## 🔐 Secrets Management

### Required for Release Build

```
ANDROID_KEYSTORE_BASE64
KEY_STORE_PASSWORD
KEY_PASSWORD
ALIAS_USERNAME
```

### Optional for Play Store Upload

```
PLAY_STORE_SERVICE_ACCOUNT
```

### Update Secrets

```bash
# List secrets
gh secret list --repo owner/repo

# Remove secret
gh secret delete ANDROID_KEYSTORE_BASE64 --repo owner/repo

# Set new value
gh secret set ANDROID_KEYSTORE_BASE64 --repo owner/repo < keystore.b64
```

---

## 📦 Build Outputs

### Location in Repository

```
GitHub Actions Artifacts:
├── APK Builds (30 days)
│   ├── app-armeabi-v7a-release.apk
│   ├── app-arm64-v8a-release.apk
│   ├── app-x86-release.apk
│   └── app-x86_64-release.apk
├── App Bundle (30 days)
│   └── app-release.aab
└── Test Coverage
    └── coverage/lcov.info

GitHub Releases (Permanent):
├── v1.0.0
│   ├── app-*-release.apk
│   └── app-release.aab
```

### Download Artifacts

**Option 1: GitHub UI**

1. Go to Actions tab
2. Select workflow run
3. Download artifact section

**Option 2: GitHub CLI**

```bash
gh run list --workflow=build-apk.yml --limit 5
gh run download <RUN_ID>
```

---

## ✅ Verification Checklist

- [ ] Flutter 3.10.0+ installed
- [ ] Java 17 installed
- [ ] Keystore file generated
- [ ] GitHub secrets configured
- [ ] Workflows exist in `.github/workflows/`
- [ ] android/key.properties exists
- [ ] Local build successful
- [ ] Push to main triggers workflow
- [ ] Tag push creates release
- [ ] APK downloaded and tested

---

## 🐛 Troubleshooting

### Build Failed: "Keystore password incorrect"

```bash
# Verify keystore
keytool -list -v -keystore android/app/upload-keystore.jks

# Check base64 encoding
echo "ANDROID_KEYSTORE_BASE64_VALUE" | base64 -d | file -

# Re-encode if needed
cat android/app/upload-keystore.jks | base64 -w 0
```

### Workflow Doesn't Trigger

```bash
# Check workflow file syntax
- Verify YAML indentation
- Check trigger conditions
- Ensure branch names match

# Manual test
gh workflow run build-apk.yml -r main
```

### APK Not Generated

```bash
# Check Flutter version
flutter --version

# Run locally
flutter clean
flutter pub get
flutter build apk --release --verbose

# Check for lint errors
flutter analyze
```

### Play Store Upload Failed

```bash
# Verify service account JSON
cat service-account.json | python -m json.tool

# Check API enabled in Google Cloud Console
# Verify package name matches
```

---

## 🚀 Advanced Usage

### Custom Build Variants

Modify workflow untuk build multiple variants:

```yaml
strategy:
  matrix:
    flavor: [dev, staging, prod]

steps:
  - run: |
      flutter build apk --release \
        --flavor ${{ matrix.flavor }} \
        -t lib/main_${{ matrix.flavor }}.dart
```

### Conditional Deployments

```yaml
- name: Upload to Play Store
  if: startsWith(github.ref, 'refs/tags/v')
  # Upload logic
```

### Notifications

Tambah ke workflow untuk Slack/Discord:

```yaml
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 📚 References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter Build Documentation](https://flutter.dev/docs/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Flutter GitHub Actions](https://github.com/subosito/flutter-action)
- [Upload to Google Play](https://github.com/r0adkll/upload-google-play)

---

## 🆘 Support

### Debug Information to Provide

```bash
# Collect debug info
flutter doctor -v > debug.log
gh workflow list >> debug.log
gh run list --workflow=build-apk.yml >> debug.log

# Upload to issue
```

### Useful Commands

```bash
# Check workflow syntax
yamllint .github/workflows/

# Run workflow locally (optional)
act -j build --secret-file=.secrets

# List available runners
gh api repos/{owner}/{repo}/actions/runners
```

---

**Last Updated:** 2024  
**Version:** 1.0.0  
**Status:** ✅ Ready to use
