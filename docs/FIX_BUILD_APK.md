# 🔧 Fix Build APK - Panduan Lengkap

**Status:** Build APK sedang gagal karena masalah signing configuration  
**Solusi:** Ikuti langkah-langkah di bawah (total 10 menit)

---

## ✅ Step 1: Generate Keystore (Local)

```bash
cd android/app

# Generate keystore baru (interactive)
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias upload

# Atau gunakan script jika tersedia:
../../scripts/generate-keystore.sh
```

**Output yang diharapkan:**
```
Keystore dibuat di: android/app/upload-keystore.jks
Alias: upload
Validity: 30 years
```

---

## ✅ Step 2: Encode Keystore untuk GitHub

```bash
cd android/app

# Encode keystore ke base64
base64 upload-keystore.jks > keystore-base64.txt

# Buka file dan copy seluruh isinya
cat keystore-base64.txt
```

**JANGAN commit `upload-keystore.jks` ke git!**

---

## ✅ Step 3: Setup GitHub Secrets

1. Buka GitHub repository: https://github.com/tiarinsan7-max/flutter-agent
2. Pergi ke **Settings** → **Secrets and variables** → **Actions**
3. Buat 5 secrets berikut:

### Secret 1: `ANDROID_KEYSTORE_BASE64`
- **Value:** Paste hasil dari `keystore-base64.txt`
- **Deskripsi:** Base64 encoded keystore

### Secret 2: `KEY_STORE_PASSWORD`
- **Value:** Password keystore Anda (contoh: `MyPassword123`)
- **Deskripsi:** Password untuk upload-keystore.jks

### Secret 3: `KEY_PASSWORD`
- **Value:** Password untuk key alias (biasanya sama dengan keystore password)
- **Deskripsi:** Password untuk key upload

### Secret 4: `ALIAS_USERNAME`
- **Value:** `upload` (default)
- **Deskripsi:** Alias yang digunakan saat generate keystore

### Secret 5: `GITHUB_TOKEN` (biasanya sudah ada)
- **Value:** Auto-generated oleh GitHub
- **Deskripsi:** Untuk create releases

---

## ✅ Step 4: Verify Secrets

Jalankan command untuk verify (atau cek di GitHub UI):

```bash
# Via GitHub CLI (jika terinstall)
gh secret list
```

Harus terlihat seperti ini:
```
ALIAS_USERNAME            Defined
ANDROID_KEYSTORE_BASE64   Defined
GITHUB_TOKEN              Defined
KEY_PASSWORD              Defined
KEY_STORE_PASSWORD        Defined
```

---

## ✅ Step 5: Add .gitignore Entry

Pastikan `upload-keystore.jks` tidak di-track:

```bash
# Check status
git status

# Jika keystore sudah tracked, hapus:
git rm --cached android/app/upload-keystore.jks
git add android/.gitignore

# Verify
git status
```

**File `android/.gitignore` harus contain:**
```
upload-keystore.jks
*.keystore
*.jks
keystore-base64.txt
```

---

## ✅ Step 6: Commit & Push Changes

```bash
# Stage perubahan
git add android/app/build.gradle.kts
git add android/app/proguard-rules.pro
git add .github/workflows/build-apk.yml

# Commit
git commit -m "fix: Update gradle signing config and workflow for APK build"

# Push
git push origin main
```

---

## ✅ Step 7: Trigger Build & Monitor

1. Pergi ke GitHub repository
2. Klik tab **Actions**
3. Pilih workflow **Build APK**
4. Klik **Run workflow** → Pilih branch → **Run workflow**
5. Monitor progress (akan selesai dalam 10-15 menit)

**Expected output:**
```
✅ Build apk
✅ Run tests
✅ Upload APK artifacts
✅ Build summary
```

---

## 🔍 Troubleshooting

### Error: "Keystore not found"
```
Solution:
1. Verify ANDROID_KEYSTORE_BASE64 secret ada di GitHub
2. Verify step "Setup signing for release APK" berhasil
3. Check workflow logs untuk error detail
```

### Error: "Invalid keystore password"
```
Solution:
1. Double-check KEY_STORE_PASSWORD secret
2. Pastikan password sesuai saat generate keystore
3. Re-create secret dengan password yang benar
```

### Error: "Build failed - missing proguard rules"
```
Solution:
1. Verify proguard-rules.pro ada di android/app/
2. File sudah di-commit? git status
3. Jika belum, add dan commit
```

### Error: "APK not created"
```
Solution:
1. Check Flutter version: flutter --version (harus 3.10.0+)
2. Check Java version: java -version (harus 17+)
3. Run locally: flutter build apk --release --split-per-abi
4. Check detailed build logs di GitHub Actions
```

### Local Build Fail
```bash
# Jika build gagal di local machine:

1. Clean build
   flutter clean
   rm -rf build/

2. Get dependencies
   flutter pub get

3. Generate build files
   flutter pub run build_runner build --delete-conflicting-outputs

4. Build APK
   flutter build apk --release --split-per-abi
```

---

## 📝 File Checklist

Pastikan semua file ini sudah di-update:

- ✅ `android/app/build.gradle.kts` - Signing config diperbaiki
- ✅ `android/app/proguard-rules.pro` - ProGuard rules ditambahkan
- ✅ `.github/workflows/build-apk.yml` - Workflow order diperbaiki
- ✅ `android/.gitignore` - Keystore di-ignore
- ✅ GitHub Secrets - 5 secrets dikonfigurasi

---

## 🚀 Success Indicators

Setelah semua langkah, Anda akan melihat:

1. **GitHub Actions** menunjukkan build ✅
2. **Artifacts** berisi APK files:
   - `app-armeabi-v7a-release.apk`
   - `app-arm64-v8a-release.apk`
   - `app-x86-release.apk`
   - `app-x86_64-release.apk`

3. **APK size** kurang lebih:
   - 15-20 MB per split APK
   - 25-30 MB bundle

---

## 📞 If Still Failing

1. **Check workflow logs:** GitHub → Actions → Build APK → [Latest run] → Click job
2. **Run locally first:** 
   ```bash
   flutter build apk --release --split-per-abi
   ```
3. **Verify keystore:**
   ```bash
   keytool -list -v -keystore android/app/upload-keystore.jks
   ```
4. **Check gradle cache:**
   ```bash
   ./gradlew clean
   flutter clean
   flutter pub get
   ```

---

## 📚 Related Documentation

- [CI_CD_SETUP.md](CI_CD_SETUP.md) - Detailed setup guide
- [QUICK_START_CI_CD.md](QUICK_START_CI_CD.md) - Quick reference
- [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md) - Advanced options

---

**Last Updated:** 2024  
**Status:** Ready to use
