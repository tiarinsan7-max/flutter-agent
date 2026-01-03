#!/bin/bash

# Script untuk mendapatkan info keystore dan setup GitHub secrets dengan benar

echo "╔════════════════════════════════════════════════════════════╗"
echo "║    Keystore Info & GitHub Secrets Setup                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verify keystore exists
if [ ! -f "android/app/upload-keystore.jks" ]; then
    echo "❌ ERROR: Keystore file not found at android/app/upload-keystore.jks"
    exit 1
fi

echo "✓ Keystore found"
echo ""

# Try to list keystore info (will prompt for password)
echo "Getting keystore information..."
echo "Please enter your keystore password:"
echo ""

keytool -list -v -keystore android/app/upload-keystore.jks

echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "NEXT STEPS:"
echo "1. Note the keystore password you just entered"
echo "2. Go to GitHub: Settings → Secrets and variables → Actions"
echo "3. Create/Update these secrets:"
echo ""
echo "   Secret Name: KEY_STORE_PASSWORD"
echo "   Value: [Your keystore password from above]"
echo ""
echo "   Secret Name: KEY_PASSWORD"
echo "   Value: [Same as KEY_STORE_PASSWORD - usually]"
echo ""
echo "   Secret Name: ALIAS_USERNAME"
echo "   Value: upload"
echo ""
echo "   Secret Name: ANDROID_KEYSTORE_BASE64"
echo "   Value: [Get from: cat android/app/keystore-base64.txt]"
echo ""
echo "4. Run: git commit -am 'fix: gradle signing config' && git push"
echo "5. Go to GitHub Actions and trigger build manually"
echo ""
