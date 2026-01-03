# CI/CD Setup Guide - GitHub Actions

Panduan lengkap untuk setup GitHub Actions CI/CD pipeline untuk build APK dan App Bundle secara otomatis.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [GitHub Secrets Setup](#github-secrets-setup)
4. [Workflow Files](#workflow-files)
5. [Android Signing](#android-signing)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)

---

## 📌 Overview

Project ini memiliki dua GitHub Actions workflow:

### 1. **build-apk.yml** - Main Build Pipeline
- Trigger: Push ke main/develop, Pull Request, Manual dispatch
- Output: Debug & Release APK, Test reports, Code coverage
- Jobs: Build, Lint, Security Scan, Notify

### 2. **build-app-bundle.yml** - Play Store Pipeline
- Trigger: Push ke main, Tags v*.*.*, Manual dispatch
- Output: Signed App Bundle (AAB)
- Upload: Google Play Store (Internal Testing)

---

## 🔧 Prerequisites

### Local Setup

```bash
# Install Flutter
flutter --version  # Should be 3.10.0+

# Install dependencies
flutter pub get

# Generate build files
flutter pub run build_runner build
```

### GitHub Repository

- Repository dengan read/write permissions
- Branch protection rules (optional)
- Secrets management enabled

---

## 🔐 GitHub Secrets Setup

### Required Secrets untuk Release Build

Buka: **Settings → Secrets and variables → Actions**

#### 1. Android Keystore

**Name:** `ANDROID_KEYSTORE_BASE64`

```bash
# Generate keystore jika belum ada
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10950 \
  -alias upload

# Encode ke base64
cat upload-keystore.jks | base64 -w 0 > keystore.txt

# Copy isi keystore.txt ke GitHub Secret
```

#### 2. Keystore Password

**Name:** `KEY_STORE_PASSWORD`

```
Value: [password yang Anda gunakan saat membuat keystore]
```

#### 3. Key Password

**Name:** `KEY_PASSWORD`

```
Value: [password untuk key alias]
```

#### 4. Alias Username

**Name:** `ALIAS_USERNAME`

```
Value: upload
```

#### 5. Play Store Service Account (Optional)

**Name:** `PLAY_STORE_SERVICE_ACCOUNT`

Untuk auto-upload ke Play Store:

1. Buka [Google Play Console](https://play.google.com/console)
2. Settings → API access
3. Create Service Account
4. Download JSON key file
5. Encode ke base64 dan set sebagai secret

```bash
cat service-account.json | base64 -w 0 > sa.txt
```

---

## 📁 Workflow Files

### File 1: `.github/workflows/build-apk.yml`

**Location:** `/home/tiar/Projects/ai_agent_app/.github/workflows/build-apk.yml`

**Features:**

```yaml
on:
  push:
    branches: [main, develop]
    tags: [v*.*.*]
  pull_request:
    branches: [main, develop]
  workflow_dispatch:
    inputs:
      build_type: [debug, release]

jobs:
  build:      # Build APK
  lint:       # Code analysis
  security:   # Dependency scan
  notify:     # Build status notification
```

### File 2: `.github/workflows/build-app-bundle.yml`

**Location:** `/home/tiar/Projects/ai_agent_app/.github/workflows/build-app-bundle.yml`

**Features:**

```yaml
on:
  push:
    branches: [main]
    tags: [v*.*.*]
  workflow_dispatch:

jobs:
  build-bundle:  # Build AAB + Upload to Play Store
```

---

## 🔑 Android Signing Configuration

### Setup Signing Config di Gradle

Update `android/app/build.gradle.kts`:

```kotlin
android {
    // ... existing config ...

    signingConfigs {
        release {
            keyAlias = System.getenv("KEY_ALIAS") ?: "upload"
            keyPassword = System.getenv("KEY_PASSWORD")
            storeFile = file("upload-keystore.jks")
            storePassword = System.getenv("KEY_STORE_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### Key Properties File

**File:** `android/key.properties`

```properties
storePassword=PLACEHOLDER_KEY_STORE_PASSWORD
keyPassword=PLACEHOLDER_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**Note:** Placeholder akan diganti oleh GitHub Actions saat build

---

## ⚙️ Configuration Details

### Build Environment

```yaml
env:
  FLUTTER_VERSION: '3.10.0'
  JAVA_VERSION: '17'
```

### Build Triggers

| Event | Branch | Output |
|-------|--------|--------|
| Push | main, develop | APK + Bundle |
| PR | main, develop | Debug APK, Tests |
| Tag | v*.*.* | Release APK + Bundle + GitHub Release |
| Manual | - | Debug atau Release (pilihan) |

### Build Output Paths

```
build/app/outputs/
├── flutter-apk/
│   └── app-*-debug.apk         # Debug builds
├── apk/release/
│   └── app-*-release.apk       # Release APK
└── bundle/release/
    └── app-release.aab          # Play Store Bundle
```

---

## 🚀 Usage Guide

### 1. Manual Build via GitHub UI

```
1. Go to Actions tab
2. Select "Build APK" workflow
3. Click "Run workflow"
4. Choose branch dan build type
5. Wait untuk completion
6. Download artifacts
```

### 2. Auto-build on Push

```bash
# Push ke main/develop
git push origin main

# Workflow otomatis trigger
# Check Actions tab untuk progress
```

### 3. Release Build with Tags

```bash
# Create dan push tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Workflow trigger otomatis
# Build release APK + AAB
# Create GitHub Release
# Upload ke Play Store (jika configured)
```

### 4. Pull Request Builds

```bash
# Push ke branch
git push origin feature-branch

# Create PR ke main/develop
# Workflow trigger otomatis
# Run tests, lint, security scan
```

---

## 📊 Workflow Details

### Build Job

```yaml
build:
  - Checkout code
  - Setup Java 17
  - Setup Flutter 3.10.0
  - Get dependencies (flutter pub get)
  - Generate build files (build_runner)
  - Run tests + coverage
  - Build APK (debug/release)
  - Upload artifacts (30 days retention)
  - Create GitHub Release (for tags)
```

### Lint Job

```yaml
lint:
  - Checkout code
  - Setup Flutter
  - Get dependencies
  - Run analyzer (flutter analyze)
  - Check formatting (dart format)
```

### Security Scan Job

```yaml
security:
  - Checkout code
  - Setup Flutter
  - Get dependencies
  - Run pub audit
```

---

## 📦 Artifact Retention

- **APK Artifacts:** 30 days
- **App Bundle:** 30 days
- **GitHub Release:** Permanent

**Cleanup otomatis setelah retention period.**

---

## 🐛 Troubleshooting

### Issue 1: Secrets Not Recognized

**Problem:** `KEY_STORE_PASSWORD` atau secrets lain tidak terdeteksi

**Solution:**

```bash
# 1. Verify secrets ada di Settings
# 2. Gunakan exact name (case-sensitive)
# 3. Check base64 encoding valid
echo "ANDROID_KEYSTORE_BASE64_VALUE" | base64 -d | file -

# 4. Verify keystore file
keytool -list -v -keystore upload-keystore.jks
```

### Issue 2: Build Fails - Dependencies

**Problem:** `flutter pub get` timeout atau error

**Solution:**

```yaml
# Add retry logic di workflow
- name: Get dependencies
  run: |
    for i in {1..3}; do
      flutter pub get && break
      sleep 10
    done
```

### Issue 3: APK Not Generated

**Problem:** Build success tapi APK tidak ada

**Solution:**

```bash
# Check log untuk error
# Verify pubspec.yaml valid
flutter analyze

# Clean dan rebuild
flutter clean
flutter pub get
flutter pub run build_runner build
flutter build apk --release
```

### Issue 4: Signing Error

**Problem:** `Keystore was tampered with, or password was incorrect`

**Solution:**

```bash
# Verify keystore valid
keytool -list -keystore upload-keystore.jks

# Check password correct
keytool -list -keystore upload-keystore.jks \
  -storepass YOUR_PASSWORD

# Re-encode base64
cat upload-keystore.jks | base64 -w 0 | pbcopy
```

### Issue 5: Upload to Play Store Failed

**Problem:** Upload error atau unauthorized

**Solution:**

```bash
# Verify service account JSON valid
cat service-account.json | python -m json.tool

# Check API enabled di Google Cloud
# Verify package name matches app

# Re-encode service account
cat service-account.json | base64 -w 0 > sa.txt
```

---

## 🔍 Monitoring & Debugging

### Check Workflow Logs

```
GitHub → Actions → Workflow name → Run → Job → Step logs
```

### Enable Debug Logging

Tambah ke workflow step:

```yaml
- name: Enable debug logging
  run: |
    export FLUTTER_VERBOSE=true
    flutter build apk --verbose --release
```

### View Test Coverage

```
1. Complete workflow run
2. Download artifacts
3. Find coverage/lcov-report/index.html
4. Open di browser
```

---

## 📈 Performance Optimization

### Reduce Build Time

```yaml
# Cache Flutter dependencies
- uses: subosito/flutter-action@v2
  with:
    cache: true
    cache-key: flutter-${{ env.FLUTTER_VERSION }}

# Parallel jobs
jobs:
  build:
    runs-on: ubuntu-latest
  lint:
    runs-on: ubuntu-latest  # Runs in parallel
  security:
    runs-on: ubuntu-latest  # Runs in parallel
```

### Split APK per ABI

```bash
# Reduce APK size untuk setiap architecture
flutter build apk --release --split-per-abi

# Output:
# app-armeabi-v7a-release.apk   (~15MB)
# app-arm64-v8a-release.apk     (~17MB)
# app-x86-release-release.apk   (~17MB)
# app-x86_64-release-release.apk (~19MB)
```

---

## ✅ Verification Checklist

- [ ] Java 17 installed
- [ ] Flutter 3.10.0+ installed
- [ ] All secrets configured di GitHub
- [ ] Keystore file generated & encoded
- [ ] build-apk.yml exists di `.github/workflows/`
- [ ] build-app-bundle.yml exists di `.github/workflows/`
- [ ] android/key.properties created
- [ ] Manual workflow_dispatch test passed
- [ ] Tag push test passed
- [ ] Artifacts uploaded successfully

---

## 📚 References

- [Flutter Build Documentation](https://flutter.dev/docs/deployment/android)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console](https://play.google.com/console)
- [Flutter GitHub Actions](https://github.com/subosito/flutter-action)

---

## 🆘 Support

### Debugging Commands

```bash
# Check Flutter setup
flutter doctor -v

# Verify keystore
keytool -list -v -keystore android/app/upload-keystore.jks

# Build locally
flutter build apk --release --verbose

# Check gradle
cd android && ./gradlew assembleRelease --stacktrace
```

### Generate New Keystore

```bash
# Backup existing
cp android/app/upload-keystore.jks android/app/upload-keystore.jks.backup

# Generate new
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10950 \
  -alias upload

# Update secrets
cat android/app/upload-keystore.jks | base64 -w 0
```

---

**Last Updated:** 2024  
**Version:** 1.0.0  
**Status:** ✅ Ready to use

