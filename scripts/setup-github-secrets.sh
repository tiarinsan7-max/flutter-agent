#!/bin/bash

# Setup GitHub Secrets Script
# Script ini membantu setup secrets untuk GitHub Actions

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "GitHub Secrets Setup for AI Agent Assistant"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not found!"
    echo "Install from: https://cli.github.com"
    exit 1
fi

# Get repository info
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || echo "owner/repo")
if [ "$REPO" = "owner/repo" ]; then
    echo "⚠️  Could not auto-detect repository. Using default."
    read -p "Enter repository (owner/repo): " REPO
fi
echo "📦 Repository: $REPO"
echo ""

# Function to set secret
set_secret() {
    local secret_name=$1
    local secret_value=$2
    
    if [ -z "$secret_value" ]; then
        echo "⚠️  Skipping $secret_name (empty value)"
        return
    fi
    
    echo "$secret_value" | gh secret set "$secret_name" --repo "$REPO"
    echo "✅ Secret '$secret_name' set successfully"
}

# Get absolute path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KEYSTORE_PATH="$PROJECT_ROOT/android/app/upload-keystore.jks"

# 1. Keystore Setup
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  ANDROID KEYSTORE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Do you want to setup keystore? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Check if keystore exists
    if [ -f "$KEYSTORE_PATH" ]; then
        echo "Found existing keystore at $KEYSTORE_PATH"
        read -p "Use existing keystore? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            KEYSTORE_B64=$(cat "$KEYSTORE_PATH" | base64 -w 0)
            set_secret "ANDROID_KEYSTORE_BASE64" "$KEYSTORE_B64"
        fi
    else
        echo "Generate new keystore..."
        read -p "Keystore password: " -s STORE_PASSWORD
        echo
        read -p "Key password: " -s KEY_PASSWORD
        echo
        
        # Ensure directory exists
        mkdir -p "$(dirname "$KEYSTORE_PATH")"
        
        keytool -genkey -v -keystore "$KEYSTORE_PATH" \
            -keyalg RSA \
            -keysize 2048 \
            -validity 10950 \
            -storepass "$STORE_PASSWORD" \
            -keypass "$KEY_PASSWORD" \
            -alias upload \
            -dname "CN=AI Agent Assistant,O=Company,L=City,ST=State,C=ID"
        
        KEYSTORE_B64=$(cat "$KEYSTORE_PATH" | base64 -w 0)
        set_secret "ANDROID_KEYSTORE_BASE64" "$KEYSTORE_B64"
    fi
fi

echo ""

# 2. Keystore Passwords
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  KEYSTORE PASSWORDS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Do you want to set passwords? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Keystore password: " -s KEY_STORE_PASSWORD
    echo
    set_secret "KEY_STORE_PASSWORD" "$KEY_STORE_PASSWORD"
    echo ""
    
    read -p "Key password: " -s KEY_PASSWORD
    echo
    set_secret "KEY_PASSWORD" "$KEY_PASSWORD"
    echo ""
    
    set_secret "ALIAS_USERNAME" "upload"
fi

echo ""

# 3. Play Store Setup (Optional)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  GOOGLE PLAY STORE (OPTIONAL)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Do you want to setup Play Store upload? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Path to service account JSON: " SERVICE_ACCOUNT_PATH
    
    if [ -f "$SERVICE_ACCOUNT_PATH" ]; then
        SA_B64=$(cat "$SERVICE_ACCOUNT_PATH" | base64 -w 0)
        set_secret "PLAY_STORE_SERVICE_ACCOUNT" "$SA_B64"
        echo ""
        echo "✅ Play Store setup complete"
    else
        echo "❌ File not found: $SERVICE_ACCOUNT_PATH"
    fi
fi

echo ""

# 4. Verify Secrets
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  VERIFY SECRETS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Current secrets:"
gh secret list --repo "$REPO" | grep -E "KEYSTORE|PASSWORD|ALIAS|PLAY" || echo "No secrets found"

echo ""
echo "✅ GitHub secrets setup complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo "1. Verify secrets in GitHub Settings → Secrets and variables"
echo "2. Commit and push changes"
echo "3. Create a tag: git tag -a v1.0.0 -m 'Release'"
echo "4. Push tag: git push origin v1.0.0"
echo "5. GitHub Actions will build and release automatically"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
