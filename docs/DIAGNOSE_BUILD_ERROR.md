# 🔍 Diagnose Build Error - Troubleshooting Guide

Karena build masih gagal walaupun keystore dan secrets sudah ditambahkan, kita perlu identify error spesifiknya.

---

## Step 1: Check GitHub Actions Logs

1. **Go to:** https://github.com/tiarinsan7-max/flutter-agent/actions
2. **Select:** Build APK workflow (most recent run)
3. **Look for error messages** in these sections:
   - "Setup signing for release APK" step
   - "Build release APK" step
   - "List build outputs" step
4. **Copy the error message** dan share dengan saya

---

## Step 2: Common Error Messages & Solutions

### Error 1: "Keystore file not found"
```
Error: failed to stat: android/app/upload-keystore.jks
```

**Solution:**
```bash
# Verify keystore ada dan base64 decode berhasil
cd android/app
ls -lh upload-keystore.jks
file upload-keystore.jks
```

---

### Error 2: "Invalid keystore password"
```
Error: java.io.IOException: DerInputStream.getLength(): 
Exception when processing - Unknown PKCS12 attribute
```

**Possible causes:**
- PASSWORD di GitHub Secrets TIDAK SESUAI dengan actual keystore password
- Password contains special characters yang tidak di-escape
- Base64 decode corrupt

**Solution:**
```bash
# Verify keystore password
keytool -list -keystore android/app/upload-keystore.jks

# Enter your actual keystore password when prompted
```

**Kemudian** update GitHub Secrets dengan password yang BENAR

---

### Error 3: "Keystore was tampered with"
```
Error: java.security.cert.CertificateException: 
Keystore was tampered with, or password was incorrect
```

**Solution:**
- Delete base64 file:
  ```bash
  rm android/app/keystore-base64.txt
  ```
- Re-encode:
  ```bash
  base64 android/app/upload-keystore.jks > android/app/keystore-base64.txt
  ```
- Update GitHub Secret `ANDROID_KEYSTORE_BASE64` dengan isi file baru

---

### Error 4: "Environment variable not set"
```
KeyPassword cannot be null
StorePassword cannot be null
```

**Cause:** GitHub Secrets tidak ter-export ke gradle build

**Solution:**
1. Verify semua 4 secrets ada:
   ```
   GitHub → Settings → Secrets → Actions
   
   ✓ ANDROID_KEYSTORE_BASE64 (harus ada)
   ✓ KEY_STORE_PASSWORD (harus ada)
   ✓ KEY_PASSWORD (harus ada)
   ✓ ALIAS_USERNAME (harus ada)
   ```

2. Verify workflow syntax benar di `.github/workflows/build-apk.yml`:
   ```yaml
   - name: Build release APK
     env:
       KEY_STORE_PASSWORD: ${{ secrets.KEY_STORE_PASSWORD }}
       KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
       ALIAS_USERNAME: ${{ secrets.ALIAS_USERNAME }}
   ```

---

### Error 5: "ProGuard failed"
```
Error: proguard rules are failing
No rules found at android/app/proguard-rules.pro
```

**Solution:**
```bash
# Verify file exists
ls -l android/app/proguard-rules.pro

# If missing, create it
touch android/app/proguard-rules.pro
```

---

### Error 6: "Build failed - resource issue"
```
Error: Could not create task ':app:minifyReleaseWithProguard'
```

**Solution:**
Kurangi optimization di gradle. Edit `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false  // Disable ProGuard temporarily
        isShrinkResources = false
    }
}
```

Commit dan push, coba build lagi.

---

## Step 3: Verify GitHub Secrets Format

**JANGAN:**
```
❌ ANDROID_KEYSTORE_BASE64 = android/app/keystore-base64.txt
❌ ANDROID_KEYSTORE_BASE64 = @android/app/keystore-base64.txt
```

**HARUS:**
```
✓ ANDROID_KEYSTORE_BASE64 = MIIKxAIBAzCCCm4GCSqGSIb3DQEHAaCCCl8EggpbMIIKVzCCBa4... (actual base64 content)
```

**Cara benar update secret:**
1. Get base64 content:
   ```bash
   cat android/app/keystore-base64.txt
   ```

2. Copy seluruh output (bisa panjang)

3. Go to GitHub: Settings → Secrets → ANDROID_KEYSTORE_BASE64

4. Edit dan paste seluruh content

---

## Step 4: Test Signing Configuration Locally

```bash
# Set environment variables
export KEY_STORE_PASSWORD="your_password"
export KEY_PASSWORD="your_password"
export ALIAS_USERNAME="upload"

# Verify keystore works
keytool -list -v -keystore android/app/upload-keystore.jks -storepass "$KEY_STORE_PASSWORD"

# Test gradle signing config (dry run)
cd android
./gradlew app:signingReport
```

---

## Step 5: Simplified Build Configuration

Jika masih error, coba simplified config (disable minification dulu):

**Edit `android/app/build.gradle.kts`:**

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
        isShrinkResources = false
        proguardFiles(
            getDefaultProguardFile("proguard-android.txt")
        )
    }
}
```

---

## Step 6: Check Workflow YAML Syntax

Verify `.github/workflows/build-apk.yml` syntax:

```yaml
# CORRECT - this is what we need:
- name: Setup signing for release APK
  if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/'))
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
    echo "Keystore setup completed"
  env:
    ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}

- name: Build release APK
  if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/'))
  run: flutter build apk --release --split-per-abi
  env:
    KEY_STORE_PASSWORD: ${{ secrets.KEY_STORE_PASSWORD }}
    KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
    ALIAS_USERNAME: ${{ secrets.ALIAS_USERNAME }}
```

---

## Step 7: Manual GitHub Actions Workflow Trigger

1. Go to: https://github.com/tiarinsan7-max/flutter-agent
2. Click: **Actions** tab
3. Select: **Build APK** workflow
4. Click: **Run workflow** button
5. Choose branch: **main**
6. Click: **Run workflow**
7. Wait dan monitor logs

---

## Debugging Checklist

```
□ Keystore file exists: android/app/upload-keystore.jks
□ Keystore is valid: keytool -list -keystore ...
□ Base64 encoding valid: file android/app/keystore-base64.txt
□ 4 secrets exist in GitHub
□ Secrets tidak empty
□ Secrets format benar (base64 string, not path)
□ Workflow YAML syntax valid
□ Environment variables di workflow ada
□ proguard-rules.pro exists
□ Build gradle valid Kotlin syntax
□ Java 17 available
□ Flutter 3.10.0+ installed
□ Gradle cache clean
```

---

## Next Action

**Please provide:**

1. **Error message dari GitHub Actions logs** (full error, tidak partial)
2. **Screenshot atau text dari** "Build release APK" step failure
3. **Confirm ini sudah di-cek:**
   - [ ] All 4 secrets created in GitHub
   - [ ] Secrets have non-empty values
   - [ ] Keystore file exists locally
   - [ ] Base64 file created
   - [ ] Files committed to git

---

## Quick Fix Checklist (Try These First)

```bash
# 1. Ensure keystore password diset di GitHub Secrets dengan benar
# Go to GitHub UI dan double-check setiap secret value

# 2. Force re-push workflow
git add .github/workflows/build-apk.yml
git commit -m "fix: trigger workflow"
git push origin main

# 3. Wait 1 minute, then manually trigger
# GitHub → Actions → Build APK → Run workflow

# 4. If still error, check logs untuk error message spesifik
```

---

**Created:** Jan 4, 2024  
**Purpose:** Diagnose build failures  
**Next Step:** Share error logs untuk specific solution
