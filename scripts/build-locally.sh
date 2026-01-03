#!/bin/bash

# Local Build Script
# Build APK locally untuk testing sebelum push ke GitHub

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "AI Agent Assistant - Local Build Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found! Install from https://flutter.dev"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Clean
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  CLEAN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
flutter clean
echo "✅ Cleaned"
echo ""

# Get dependencies
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  GET DEPENDENCIES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
flutter pub get
echo "✅ Dependencies installed"
echo ""

# Generate build files
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  GENERATE BUILD FILES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
flutter pub run build_runner build --delete-conflicting-outputs
echo "✅ Build files generated"
echo ""

# Analyze
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  ANALYZE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
flutter analyze
echo "✅ Analysis complete"
echo ""

# Format check
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  FORMAT CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
dart format --output=none --set-exit-if-changed . || echo "⚠️  Format issues found (non-critical)"
echo ""

# Run tests
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  RUN TESTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
flutter test --coverage || echo "⚠️  Tests failed (check details above)"
echo ""

# Build selection
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7️⃣  BUILD SELECTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Select build type:"
echo "1) Debug APK"
echo "2) Release APK"
echo "3) Release APK (split per ABI)"
echo "4) Release App Bundle"
echo "5) All of the above"
read -p "Choice (1-5): " BUILD_CHOICE

case $BUILD_CHOICE in
    1)
        echo ""
        echo "Building Debug APK..."
        flutter build apk --debug
        echo "✅ Debug APK built"
        ;;
    2)
        echo ""
        echo "Building Release APK..."
        flutter build apk --release
        echo "✅ Release APK built"
        ;;
    3)
        echo ""
        echo "Building Release APK (split per ABI)..."
        flutter build apk --release --split-per-abi
        echo "✅ Release APK (split) built"
        ;;
    4)
        echo ""
        echo "Building Release App Bundle..."
        flutter build appbundle --release
        echo "✅ Release App Bundle built"
        ;;
    5)
        echo ""
        echo "Building all..."
        flutter build apk --debug
        flutter build apk --release --split-per-abi
        flutter build appbundle --release
        echo "✅ All builds complete"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "BUILD OUTPUT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📁 Debug APK:"
ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || echo "  (not found)"

echo ""
echo "📁 Release APK:"
ls -lh build/app/outputs/apk/release/*.apk 2>/dev/null || echo "  (not found)"

echo ""
echo "📁 App Bundle:"
ls -lh build/app/outputs/bundle/release/*.aab 2>/dev/null || echo "  (not found)"

echo ""
echo "📁 Test Coverage:"
ls -lh coverage/lcov.info 2>/dev/null && echo "  ✅ Available" || echo "  (not found)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Build process complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Test APK on device: adb install -r build/app/outputs/..."
echo "2. If successful, commit and push: git push origin"
echo "3. Create release tag: git tag -a v1.0.0 -m 'Release'"
echo "4. Push tag: git push origin v1.0.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
