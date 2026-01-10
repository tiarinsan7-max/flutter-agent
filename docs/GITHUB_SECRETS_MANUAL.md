# Manual GitHub Secrets Setup

Setup GitHub Actions secrets manually through the GitHub web interface.

---

## 📋 Required Secrets

You need to create **4 secrets** in your GitHub repository.

---

## 🚀 Setup Steps

### Step 1: Get Base64 Keystore Value

Run this command in your terminal:

```bash
cat android/app/upload-keystore.jks.b64
```

**Copy the entire output** (one long line of text). This is your keystore in base64 format.

### Step 2: Go to GitHub Settings

1. Open your repository on GitHub
2. Click **Settings** tab
3. Click **Secrets and variables** (left sidebar)
4. Click **Actions** tab

### Step 3: Add Secret 1 - ANDROID_KEYSTORE_BASE64

1. Click **New repository secret** button
2. **Name:** `ANDROID_KEYSTORE_BASE64`
3. **Secret:** Paste the output from Step 1
4. Click **Add secret**

### Step 4: Add Secret 2 - KEY_STORE_PASSWORD

1. Click **New repository secret** button
2. **Name:** `KEY_STORE_PASSWORD`
3. **Secret:** `MySecurePass123`
4. Click **Add secret**

### Step 5: Add Secret 3 - KEY_PASSWORD

1. Click **New repository secret** button
2. **Name:** `KEY_PASSWORD`
3. **Secret:** `MySecurePass123`
4. Click **Add secret**

### Step 6: Add Secret 4 - ALIAS_USERNAME

1. Click **New repository secret** button
2. **Name:** `ALIAS_USERNAME`
3. **Secret:** `upload`
4. Click **Add secret**

---

## ✅ Verify Secrets

After adding all 4 secrets:

1. Go to **Settings → Secrets and variables → Actions**
2. You should see 4 secrets listed:
   - ✅ ANDROID_KEYSTORE_BASE64
   - ✅ KEY_STORE_PASSWORD
   - ✅ KEY_PASSWORD
   - ✅ ALIAS_USERNAME

Each secret will show the last 4 characters (masked).

---

## 🎯 Quick Summary

| Secret Name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Output of `cat android/app/upload-keystore.jks.b64` |
| `KEY_STORE_PASSWORD` | `MySecurePass123` |
| `KEY_PASSWORD` | `MySecurePass123` |
| `ALIAS_USERNAME` | `upload` |

---

## 📸 Visual Guide

```
GitHub Repository
  ↓
Settings tab
  ↓
Secrets and variables (left sidebar)
  ↓
Actions tab
  ↓
New repository secret (button)
  ↓
Enter Name & Secret
  ↓
Add secret
  ↓
Repeat 4 times
```

---

## 🚀 Next Steps

After adding all 4 secrets:

1. Commit your CI/CD configuration:
   ```bash
   git add .
   git commit -m "Add CI/CD configuration and keystore"
   git push origin main
   ```

2. Go to **Actions** tab in GitHub

3. Watch your workflow run automatically

4. APK ready in ~12 minutes

---

## ❌ Common Mistakes

### Mistake 1: Wrong secret name
❌ `ANDROID_KEYSTORE_B64` (missing part of name)  
✅ `ANDROID_KEYSTORE_BASE64` (correct)

### Mistake 2: Secret is empty
❌ Copy-paste failed, got empty string  
✅ Make sure to select ALL output from base64 command

### Mistake 3: Wrong password
❌ `mysecurepass123` (wrong case)  
✅ `MySecurePass123` (correct, case-sensitive)

### Mistake 4: Forgot a secret
❌ Only added 3 secrets  
✅ Make sure all 4 are added

---

## ✨ Troubleshooting

### Problem: Can't find Secrets settings
**Solution:** 
- Make sure you're in the repository, not user settings
- Click **Settings** at top of repo page
- Look for **Secrets and variables** in left sidebar

### Problem: Can't copy base64 value
**Solution:**
```bash
# Try this instead
cat android/app/upload-keystore.jks.b64 | xclip -selection clipboard
# Then paste with Ctrl+V
```

### Problem: Secret is showing in build logs
**Solution:** GitHub automatically masks secrets in logs. Check that the secret name matches exactly.

---

## 📞 Support

If you have issues:

1. Check secret names (case-sensitive)
2. Verify all 4 secrets exist
3. Verify secret values are correct
4. Check GitHub Actions logs for errors

---

## 🎉 Done!

Once all 4 secrets are added, your CI/CD pipeline is ready!

**Next:** Push to GitHub and watch Actions tab.

---

**Status:** Ready for GitHub Actions  
**Time to complete:** 5 minutes  
**Difficulty:** ⭐ Easy
