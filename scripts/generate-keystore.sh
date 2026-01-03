#!/bin/bash

# Generate Android Keystore Script
# Creates a new keystore for signing Android apps

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Android Keystore Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get absolute path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KEYSTORE_PATH="$PROJECT_ROOT/android/app/upload-keystore.jks"

echo "Project root: $PROJECT_ROOT"
echo "Keystore path: $KEYSTORE_PATH"
echo ""

# Check existing keystore
if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️  Keystore already exists at $KEYSTORE_PATH"
    read -p "Do you want to create a new one? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    
    # Backup existing
    cp "$KEYSTORE_PATH" "$KEYSTORE_PATH.backup"
    echo "✅ Backup created: $KEYSTORE_PATH.backup"
    rm "$KEYSTORE_PATH"
    echo "Removed old keystore"
fi

# Ensure directory exists
KEYSTORE_DIR="$(dirname "$KEYSTORE_PATH")"
mkdir -p "$KEYSTORE_DIR"
echo "✅ Directory ensured: $KEYSTORE_DIR"
echo ""

# Get input
echo "Enter keystore details:"
echo ""

read -p "Keystore password: " -s KEYSTORE_PASSWORD
echo
read -p "Confirm password: " -s KEYSTORE_PASSWORD_CONFIRM
echo

if [ "$KEYSTORE_PASSWORD" != "$KEYSTORE_PASSWORD_CONFIRM" ]; then
    echo "❌ Passwords don't match!"
    exit 1
fi

echo ""
read -p "Key password: " -s KEY_PASSWORD
echo
read -p "Confirm password: " -s KEY_PASSWORD_CONFIRM
echo

if [ "$KEY_PASSWORD" != "$KEY_PASSWORD_CONFIRM" ]; then
    echo "❌ Passwords don't match!"
    exit 1
fi

echo ""
read -p "Your name/Alias (default: upload): " ALIAS
ALIAS=${ALIAS:-upload}

read -p "Organization name (default: AI Agent): " ORG_NAME
ORG_NAME=${ORG_NAME:-AI Agent}

read -p "Organization unit (default: Development): " ORG_UNIT
ORG_UNIT=${ORG_UNIT:-Development}

read -p "City (default: Jakarta): " CITY
CITY=${CITY:-Jakarta}

read -p "State/Province (default: Jakarta): " STATE
STATE=${STATE:-Jakarta}

read -p "Country code (default: ID): " COUNTRY
COUNTRY=${COUNTRY:-ID}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Generating keystore..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

keytool -genkey -v -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10950 \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -alias "$ALIAS" \
    -dname "CN=$ALIAS,OU=$ORG_UNIT,O=$ORG_NAME,L=$CITY,ST=$STATE,C=$COUNTRY"

echo ""
echo "✅ Keystore generated successfully!"
echo ""

# Verify keystore
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Verifying keystore..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Encode to base64..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

KEYSTORE_B64=$(cat "$KEYSTORE_PATH" | base64 -w 0)
echo "Copy this value to ANDROID_KEYSTORE_BASE64 secret:"
echo ""
echo "$KEYSTORE_B64"
echo ""

# Save to file
BASE64_FILE="$KEYSTORE_PATH.b64"
echo "$KEYSTORE_B64" > "$BASE64_FILE"
echo "✅ Saved to: $BASE64_FILE"
echo ""

# Save passwords info
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Save these credentials somewhere safe:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cat > keystore-info.txt << EOF
Keystore Information
====================

File: $KEYSTORE_PATH
Alias: $ALIAS

Passwords:
- Keystore Password: $KEYSTORE_PASSWORD
- Key Password: $KEY_PASSWORD

GitHub Secrets to set:
- ANDROID_KEYSTORE_BASE64: [See above]
- KEY_STORE_PASSWORD: $KEYSTORE_PASSWORD
- KEY_PASSWORD: $KEY_PASSWORD
- ALIAS_USERNAME: $ALIAS

Base64 Encoded Keystore saved to: $BASE64_FILE

KEEP THIS FILE SECURE!
EOF

echo "✅ Credentials saved to: keystore-info.txt"
echo ""
echo "⚠️  IMPORTANT: Keep keystore-info.txt secure!"
echo "⚠️  Do not commit these files to git!"
echo ""

# Add to .gitignore
GITIGNORE_PATH="$PROJECT_ROOT/.gitignore"
if [ -f "$GITIGNORE_PATH" ]; then
    if ! grep -q "upload-keystore.jks" "$GITIGNORE_PATH" 2>/dev/null; then
        echo "Updating .gitignore..."
        echo "" >> "$GITIGNORE_PATH"
        echo "# Keystore files" >> "$GITIGNORE_PATH"
        echo "*.jks" >> "$GITIGNORE_PATH"
        echo "*.b64" >> "$GITIGNORE_PATH"
        echo "keystore-info.txt" >> "$GITIGNORE_PATH"
        echo "✅ Updated .gitignore"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo "1. Save keystore-info.txt securely (not in git)"
echo "2. Set GitHub Secrets:"
echo "   - ANDROID_KEYSTORE_BASE64"
echo "   - KEY_STORE_PASSWORD"
echo "   - KEY_PASSWORD"
echo "   - ALIAS_USERNAME"
echo "3. Delete keystore-info.txt after setting secrets"
echo "4. Run: git push && create tag for release"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
