# Build & Deployment Scripts

Koleksi script untuk memudahkan build dan deployment process.

## 📋 Scripts Available

### 1. generate-keystore.sh

**Purpose:** Generate Android keystore untuk signing APK

**Usage:**
```bash
chmod +x scripts/generate-keystore.sh
./scripts/generate-keystore.sh
```

**Features:**
- Interactive keystore generation
- Automatic base64 encoding
- Backup existing keystore
- Save credentials to secure file
- Auto-update .gitignore

**Output:**
- `android/app/upload-keystore.jks` - Keystore file
- `android/app/upload-keystore.jks.b64` - Base64 encoded
- `keystore-info.txt` - Credentials (⚠️ keep secure!)

---

### 2. setup-github-secrets.sh

**Purpose:** Setup GitHub Actions secrets otomatis

**Prerequisites:**
```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/install.sh | sh

# Login
gh auth login
```

**Usage:**
```bash
chmod +x scripts/setup-github-secrets.sh
./scripts/setup-github-secrets.sh
```

**Features:**
- Interactive secret setup
- Supports existing keystore
- Generate new keystore
- Play Store service account setup
- Verify secrets created

**Secrets Set:**
- `ANDROID_KEYSTORE_BASE64`
- `KEY_STORE_PASSWORD`
- `KEY_PASSWORD`
- `ALIAS_USERNAME`
- `PLAY_STORE_SERVICE_ACCOUNT` (optional)

---

### 3. build-locally.sh

**Purpose:** Build APK locally sebelum push ke GitHub

**Usage:**
```bash
chmod +x scripts/build-locally.sh
./scripts/build-locally.sh
```

**Steps:**
1. Clean project
2. Get dependencies
3. Generate build files
4. Analyze code
5. Check formatting
6. Run tests with coverage
7. Build APK/AAB (pilihan)

**Output:**
- Debug APK
- Release APK
- Split APK (per ABI)
- App Bundle (AAB)
- Test coverage report

---

## 🚀 Quick Start

### Step 1: Generate Keystore

```bash
./scripts/generate-keystore.sh

# Follow prompts:
# - Keystore password: [set secure password]
# - Key password: [set secure password]
# - Alias: upload
# - Company details: [fill as needed]
```

**Output:**
- Keystore file: `android/app/upload-keystore.jks`
- Credentials file: `keystore-info.txt` (keep safe!)

### Step 2: Setup GitHub Secrets

```bash
./scripts/setup-github-secrets.sh

# Follow prompts:
# 1. Use existing keystore? Yes
# 2. Set passwords? Yes
# 3. Setup Play Store? Optional
```

**Verifikasi:**
```bash
gh secret list --repo owner/repo | grep KEYSTORE
```

### Step 3: Build Locally

```bash
./scripts/build-locally.sh

# Select build type:
# 1) Debug APK
# 2) Release APK
# 3) Release APK (split per ABI)
# 4) Release App Bundle
# 5) All of the above
```

### Step 4: Test & Push

```bash
# Install debug APK
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Test on device
# If OK, push to GitHub

git add .
git commit -m "Add CI/CD configuration"
git push origin main
```

### Step 5: Create Release

```bash
# Create tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag
git push origin v1.0.0

# GitHub Actions automatically:
# - Builds APK + AAB
# - Creates GitHub Release
# - Uploads files
```

---

## 📝 Script Details

### generate-keystore.sh

```bash
# Creates:
├── android/app/upload-keystore.jks      # Binary keystore
├── android/app/upload-keystore.jks.b64  # Base64 encoded
├── android/app/upload-keystore.jks.backup
└── keystore-info.txt                    # Credentials

# Updates:
└── .gitignore (adds *.jks, *.b64, keystore-info.txt)
```

**Variables:**
```bash
KEYSTORE_PATH="android/app/upload-keystore.jks"
ALIAS="upload"
VALIDITY="10950 days" (30 years)
```

---

### setup-github-secrets.sh

```bash
# Requires:
├── GitHub CLI (gh)
├── Authentication (gh auth login)
└── Keystore files (from generate-keystore.sh)

# Sets Secrets:
├── ANDROID_KEYSTORE_BASE64 (base64 encoded keystore)
├── KEY_STORE_PASSWORD
├── KEY_PASSWORD
├── ALIAS_USERNAME
└── PLAY_STORE_SERVICE_ACCOUNT (optional)
```

**Dependencies:**
```bash
which gh  # GitHub CLI
gh auth status  # Verify logged in
```

---

### build-locally.sh

```bash
# Requires:
├── Flutter SDK 3.10.0+
├── Java 17+
├── Android SDK
└── All dependencies (flutter pub get)

# Performs:
├── flutter clean
├── flutter pub get
├── flutter pub run build_runner build
├── flutter analyze
├── dart format check
├── flutter test --coverage
└── flutter build [apk|appbundle]
```

**Output Locations:**
```
build/app/outputs/
├── flutter-apk/app-debug.apk
├── apk/release/app-*-release.apk
├── bundle/release/app-release.aab
└── ../../../coverage/lcov.info
```

---

## 🔧 Troubleshooting Scripts

### generate-keystore.sh Issues

**Problem:** "keytool: command not found"
```bash
# keytool is part of Java
which keytool
# If not found, install Java 17+
```

**Problem:** "Permission denied"
```bash
chmod +x scripts/generate-keystore.sh
```

**Problem:** "Passwords don't match"
```bash
# Script will prompt again
# Carefully re-enter matching passwords
```

---

### setup-github-secrets.sh Issues

**Problem:** "GitHub CLI not found"
```bash
# Install from https://cli.github.com
curl -fsSL https://cli.github.com/install.sh | sh
```

**Problem:** "Not authenticated"
```bash
gh auth login
# Follow browser prompt
gh auth status  # Verify
```

**Problem:** "Secret already exists"
```bash
# Script updates existing secrets
# If issue, delete manually:
gh secret delete ANDROID_KEYSTORE_BASE64 --repo owner/repo
```

---

### build-locally.sh Issues

**Problem:** "Flutter not found"
```bash
flutter --version
# If not found, install from flutter.dev
```

**Problem:** "Tests failed"
```bash
# Script continues even if tests fail
# Check output for error details
flutter test --verbose
```

**Problem:** "Build size too large"
```bash
# Use split APK per ABI
flutter build apk --release --split-per-abi
```

---

## 🔐 Security Best Practices

### Keystore Protection

```bash
# 1. Generate keystore with strong password
./scripts/generate-keystore.sh
# Use 16+ character passwords

# 2. Keep keystore-info.txt secure
rm keystore-info.txt  # After setting secrets
# Or encrypt: gpg --encrypt keystore-info.txt

# 3. Add to .gitignore
git status  # Verify keystore not tracked
```

### GitHub Secrets

```bash
# 1. Verify secrets set correctly
gh secret list --repo owner/repo

# 2. Use masked output
# GitHub hides secret values in logs

# 3. Rotate regularly
# Regenerate keystore yearly
./scripts/generate-keystore.sh
```

### Safe Credential Handling

```bash
# 1. Never commit keystore files
git status

# 2. Use environment variables
export KEY_STORE_PASSWORD="..."
export KEY_PASSWORD="..."

# 3. Unset after use
unset KEY_STORE_PASSWORD
unset KEY_PASSWORD
```

---

## 📊 Workflow Integration

### Automated Build Pipeline

```
Git Push → GitHub Actions → build-apk.yml → APK
                ↓
             build-app-bundle.yml → AAB
                ↓
          GitHub Release + Play Store
```

### Manual Builds

```
Local Machine → build-locally.sh → APK/AAB → Test → Push
```

---

## 📚 Environment Requirements

### System Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.10.0+ | Build framework |
| Java | 17+ | Android compilation |
| Android SDK | 34+ | Build tools |
| Dart | Latest | Code language |

### For Scripts

| Tool | Usage |
|------|-------|
| keytool | Generate keystore |
| base64 | Encode keystore |
| gh (GitHub CLI) | Setup secrets |
| bash | Script execution |

---

## ✅ Verification

### After generate-keystore.sh

```bash
# Verify files created
ls -la android/app/upload-keystore.jks*

# Verify content
keytool -list -v -keystore android/app/upload-keystore.jks

# Verify base64
base64 -d < android/app/upload-keystore.jks.b64 | file -
```

### After setup-github-secrets.sh

```bash
# List secrets
gh secret list --repo owner/repo | grep -E "KEYSTORE|PASSWORD"

# Verify secret value (masked in UI)
# - Go to Settings → Secrets
# - Each secret shows last 4 characters
```

### After build-locally.sh

```bash
# Check APK exists
ls -lh build/app/outputs/

# Install on device
adb devices
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Verify app launches
adb shell am start -n com.example.ai_agent_assistant/.MainActivity
```

---

## 🎯 Next Steps

1. **Generate Keystore**
   ```bash
   ./scripts/generate-keystore.sh
   ```

2. **Setup GitHub Secrets**
   ```bash
   ./scripts/setup-github-secrets.sh
   ```

3. **Build Locally**
   ```bash
   ./scripts/build-locally.sh
   ```

4. **Test on Device**
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

5. **Commit & Push**
   ```bash
   git push origin main
   git tag -a v1.0.0 -m "Release"
   git push origin v1.0.0
   ```

---

## 📞 Support

For issues:

1. Check troubleshooting section above
2. Run command with `--verbose` flag
3. Check CI_CD_SETUP.md for more details
4. Review GitHub Actions logs

---

**Last Updated:** 2024  
**Version:** 1.0.0  
**Status:** ✅ Ready to use
