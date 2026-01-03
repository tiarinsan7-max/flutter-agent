#!/bin/bash

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Flutter APK Build Fix Script${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if keystore exists
if [ ! -f "android/app/upload-keystore.jks" ]; then
    echo -e "${YELLOW}[1/3] Keystore not found. Generating new one...${NC}"
    echo ""
    
    read -p "Enter keystore password: " -s KEYSTORE_PASSWORD
    echo ""
    read -p "Confirm password: " -s PASSWORD_CONFIRM
    echo ""
    
    if [ "$KEYSTORE_PASSWORD" != "$PASSWORD_CONFIRM" ]; then
        echo -e "${RED}Passwords don't match!${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Creating keystore (this will ask for additional info)...${NC}"
    keytool -genkey -v -keystore android/app/upload-keystore.jks \
        -keyalg RSA -keysize 2048 -validity 10950 -alias upload \
        -storepass "$KEYSTORE_PASSWORD" \
        -keypass "$KEYSTORE_PASSWORD"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Keystore created successfully${NC}"
    else
        echo -e "${RED}✗ Failed to create keystore${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Keystore found at android/app/upload-keystore.jks${NC}"
fi

echo ""
echo -e "${YELLOW}[2/3] Encoding keystore to base64...${NC}"

if ! base64 android/app/upload-keystore.jks > android/app/keystore-base64.txt 2>/dev/null; then
    echo -e "${RED}✗ Failed to encode keystore${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Keystore encoded${NC}"
echo -e "${BLUE}Base64 output saved to: android/app/keystore-base64.txt${NC}"
echo ""

echo -e "${YELLOW}[3/3] Updating .gitignore...${NC}"

# Add to .gitignore if not already there
if ! grep -q "upload-keystore.jks" android/.gitignore; then
    echo "" >> android/.gitignore
    echo "# Android signing" >> android/.gitignore
    echo "upload-keystore.jks" >> android/.gitignore
    echo "keystore-base64.txt" >> android/.gitignore
    echo "*.keystore" >> android/.gitignore
    echo "*.jks" >> android/.gitignore
    echo -e "${GREEN}✓ Updated android/.gitignore${NC}"
else
    echo -e "${GREEN}✓ Keystore already in .gitignore${NC}"
fi

# Remove from git if tracked
if git ls-files --error-unmatch android/app/upload-keystore.jks 2>/dev/null; then
    echo -e "${YELLOW}Removing tracked keystore from git...${NC}"
    git rm --cached android/app/upload-keystore.jks
    echo -e "${GREEN}✓ Removed from git tracking${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build Fix Completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Copy the base64 content from:"
echo -e "   ${BLUE}cat android/app/keystore-base64.txt${NC}"
echo ""
echo "2. Add GitHub Secrets (Settings → Secrets):"
echo -e "   ${BLUE}ANDROID_KEYSTORE_BASE64${NC} = [paste base64 content]"
echo -e "   ${BLUE}KEY_STORE_PASSWORD${NC} = [your keystore password]"
echo -e "   ${BLUE}KEY_PASSWORD${NC} = [same as keystore password]"
echo -e "   ${BLUE}ALIAS_USERNAME${NC} = upload"
echo ""
echo "3. Commit changes:"
echo -e "   ${BLUE}git add android/.gitignore${NC}"
echo -e "   ${BLUE}git commit -m \"fix: setup android signing config\"${NC}"
echo -e "   ${BLUE}git push origin main${NC}"
echo ""
echo "4. Monitor build:"
echo "   GitHub → Actions → Build APK → Run workflow"
echo ""
echo "For detailed instructions, see: FIX_BUILD_APK.md"
