# Quick Start - CI/CD Setup

Panduan singkat untuk setup GitHub Actions build pipeline dalam 5 menit.

## ⚡ 5 Minute Setup

### 1. Generate Keystore (2 min)

```bash
chmod +x scripts/generate-keystore.sh
./scripts/generate-keystore.sh
```

**Jawab pertanyaan:**
- Keystore password: `[your-secure-password]`
- Key password: `[same-password]`
- Alias: `upload`
- Organization: `AI Agent Assistant`

**Output:** `android/app/upload-keystore.jks` + `keystore-info.txt`

---

### 2. Setup GitHub Secrets (2 min)

**Option A: Automated (Recommended)**

```bash
chmod +x scripts/setup-github-secrets.sh
gh auth login
./scripts/setup-github-secrets.sh
```

**Option B: Manual**

1. Open GitHub → Settings → Secrets and variables → Actions
2. Add these secrets:

```
ANDROID_KEYSTORE_BASE64 = cat android/app/upload-keystore.jks | base64 -w 0
KEY_STORE_PASSWORD = [from keystore-info.txt]
KEY_PASSWORD = [from keystore-info.txt]
ALIAS_USERNAME = upload
```

---

### 3. Test Build (1 min)

```bash
chmod +x scripts/build-locally.sh
./scripts/build-locally.sh

# Choose: 2 (Release APK)
```

---

## 🚀 Build & Deploy

### First Time Push

```bash
git add .
git commit -m "Add CI/CD configuration"
git push origin main

# Watch Actions tab for build
```

### Create Release

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Automatically:
# ✅ Build APK + AAB
# ✅ Create GitHub Release
# ✅ Upload files
```

---

## 📦 Files Added

```
.github/workflows/
├── build-apk.yml              # Main build pipeline
└── build-app-bundle.yml       # Play Store pipeline

android/
└── key.properties             # Signing config

scripts/
├── generate-keystore.sh       # Create keystore
├── setup-github-secrets.sh    # Setup secrets
└── build-locally.sh           # Local build

Documentation:
├── CI_CD_SETUP.md             # Detailed guide
├── GITHUB_ACTIONS_GUIDE.md    # Full reference
└── QUICK_START_CI_CD.md       # This file
```

---

## ✅ Verify Setup

### Check Workflows Running

1. Go to GitHub → Actions
2. See "Build APK" workflow
3. Latest run status should show green ✅

### Check Secrets

```bash
gh secret list --repo owner/repo | grep KEYSTORE
```

### Download APK

1. Actions → Latest run
2. Artifacts section
3. Download `apk-builds`

---

## 🔄 Build Triggers

| Trigger | Output |
|---------|--------|
| Push to main | Release APK |
| Pull Request | Debug APK + Tests |
| Tag v*.*.* | Release APK + AAB + GitHub Release |
| Manual dispatch | Choose debug/release |

---

## 🐛 Quick Troubleshooting

**"Secrets not found"**
```bash
# Re-run setup script
./scripts/setup-github-secrets.sh
```

**"Build failed"**
```bash
# Test locally first
./scripts/build-locally.sh
```

**"APK not generated"**
```bash
# Check Flutter version
flutter --version  # Should be 3.10.0+

# Clean and rebuild
flutter clean
./scripts/build-locally.sh
```

---

## 📝 Next Steps

1. ✅ Generate keystore
2. ✅ Setup secrets
3. ✅ Test locally
4. ✅ Push to GitHub
5. 📤 Create release tag
6. 🎉 Done!

---

## 📚 Learn More

- [CI_CD_SETUP.md](CI_CD_SETUP.md) - Full setup guide
- [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md) - Complete reference
- [scripts/README.md](scripts/README.md) - Scripts documentation

---

**Time to setup:** ~5 minutes  
**Complexity:** ⭐ Easy  
**Status:** ✅ Ready to use
