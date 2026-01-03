# Setup Guide - AI Agent Assistant

Comprehensive setup guide for the AI Agent Assistant mobile application.

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Flutter Setup](#flutter-setup)
3. [Ollama Setup](#ollama-setup)
4. [Project Setup](#project-setup)
5. [Build & Run](#build--run)
6. [Troubleshooting](#troubleshooting)

## System Requirements

### Minimum Requirements

**Development Machine:**

- OS: Windows 10+, macOS 10.15+, or Linux (Ubuntu 18.04+)
- RAM: 8GB (16GB recommended)
- Disk Space: 20GB minimum (for Flutter SDK, Android SDK, Xcode, and Ollama)
- Internet Connection: Required for downloading dependencies

**Target Device:**

- Android: 5.1 (API 22) or higher
- iOS: 11.0 or higher

### Recommended Setup

- **Android Development:**
  - Android Studio 2022.1 or higher
  - Android SDK API level 34
  - Android NDK (for native libraries if needed)
- **iOS Development (macOS only):**
  - Xcode 14 or higher
  - iOS SDK 16 or higher
- **Ollama:**
  - System with at least 4GB RAM for running models
  - 8GB+ recommended for better performance
  - SSD for faster model loading

## Flutter Setup

### 1. Install Flutter SDK

#### Windows

```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to a location (e.g., C:\flutter)
# Add Flutter to PATH environment variable

# Verify installation
flutter doctor
```

#### macOS

```bash
# Using Homebrew (recommended)
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install/macos
# Extract and add to PATH

# Verify installation
flutter doctor
```

#### Linux

```bash
# Download from https://flutter.dev/docs/get-started/install/linux
# Extract to ~/development/flutter

# Add to PATH in ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/development/flutter/bin"

# Reload shell
source ~/.bashrc

# Verify installation
flutter doctor
```

### 2. Install Android Studio (for Android development)

```bash
# Windows/macOS/Linux - Download from:
# https://developer.android.com/studio

# After installation, run flutter doctor
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses

# Install Android dependencies
flutter pub global activate fvm  # (optional - for Flutter Version Management)
```

### 3. Install Xcode (for iOS development - macOS only)

```bash
# Via App Store or command line
xcode-select --install

# Install additional components
sudo xcode-select --switch /Applications/Xcode.app/xcode-select

# Accept Xcode license
sudo xcodebuild -license accept

# Install iOS CocoaPods
sudo gem install cocoapods
```

### 4. Verify Flutter Setup

```bash
flutter doctor -v

# Expected output should show:
# ✓ Flutter (version X.X.X)
# ✓ Android toolchain
# ✓ Xcode (if on macOS)
# ✓ Chrome (for web development)
```

## Ollama Setup

### 1. Install Ollama

#### Windows

```bash
# Download from https://ollama.ai/download/windows
# Run the installer
# Ollama will start automatically
```

#### macOS

```bash
# Download from https://ollama.ai/download/mac
# Open the .dmg file and drag Ollama to Applications
# Launch Ollama from Applications
```

#### Linux

```bash
# Install using package manager or download
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama service
systemctl start ollama

# Enable auto-start
systemctl enable ollama
```

### 2. Verify Ollama Installation

```bash
# In a new terminal
ollama --version

# Should output something like: ollama version X.X.X
```

### 3. Download AI Models

```bash
# Download a model (takes time based on model size)
ollama pull mistral

# Available models:
# - mistral: 7B parameters (recommended for mobile)
# - llama2: 7B, 13B, 70B variants
# - neural-chat: Optimized for chat
# - dolphin-mixtral: 8x7B mixture of experts
# - orca-mini: Smaller, faster model

# List downloaded models
ollama list

# Run a model locally
ollama run mistral
# Type your prompt and press Enter
```

### 4. Configure Ollama for Remote Access

By default, Ollama runs on `http://localhost:11434`

To allow remote connections:

```bash
# Set environment variable before starting
export OLLAMA_HOST=0.0.0.0:11434

# macOS - Edit LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.ollama.OllamaServer.plist
# Edit the plist to set OLLAMA_HOST environment variable
launchctl load ~/Library/LaunchAgents/com.ollama.OllamaServer.plist

# Linux - Edit service
sudo systemctl edit ollama
# Add: Environment="OLLAMA_HOST=0.0.0.0:11434"
sudo systemctl restart ollama
```

## Project Setup

### 1. Clone or Extract Project

```bash
# Option 1: Clone repository
git clone <repository-url>
cd flutter_ai_agent_app

# Option 2: If already extracted
cd /path/to/flutter_ai_agent_app
```

### 2. Get Dependencies

```bash
# Clean previous builds
flutter clean

# Get all pub dependencies
flutter pub get

# (Optional) Upgrade to latest compatible versions
flutter pub upgrade
```

### 3. Generate Hive Adapters

```bash
# This generates database adapter files
flutter pub run build_runner build

# If you encounter errors, clean and try again
flutter pub run build_runner clean
flutter pub run build_runner build
```

### 4. Configure Project

#### Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34          // Adjust if needed
    
    defaultConfig {
        applicationId "com.example.ai_agent_assistant"
        minSdkVersion 24
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

Create `android/local.properties`:

```properties
sdk.dir=/path/to/android/sdk
flutter.sdk=/path/to/flutter
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1
```

#### iOS Configuration

```bash
# Navigate to iOS directory
cd ios

# Install CocoaPods dependencies
pod install

# Or update existing pods
pod update

# Return to project root
cd ..
```

## Build & Run

### Android

```bash
# Run on connected Android device
flutter run

# Run with verbose logging
flutter run -v

# Build APK for distribution
flutter build apk

# Build App Bundle for Google Play
flutter build appbundle

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Run on connected iOS device or simulator
flutter run

# Build for iOS
flutter build ios

# Generate IPA for distribution
flutter build ipa

# Output location:
# IPA: build/ios/ipa/ai_agent_assistant.ipa
```

### Web (Development only)

```bash
# Run on web
flutter run -d web-javascript

# Build web
flutter build web

# Output location:
# build/web/
```

## Development Workflow

### Hot Reload

During development, use hot reload for fast iteration:

```bash
# Press 'r' in terminal to hot reload
# Press 'R' to hot restart
# Press 'h' for help
```

### Debugging

```bash
# Enable debugging output
flutter run --verbose

# Attach debugger to running app
flutter attach

# View device logs
flutter logs

# View specific device logs
adb logcat  # Android
log stream --predicate 'eventMessage contains[c] "Flutter"'  # iOS
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/specific_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report
open coverage/lcov-report/index.html  # macOS
xdg-open coverage/lcov-report/index.html  # Linux
```

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues

```bash
# Run to see all issues
flutter doctor

# Fix specific issues:
# - Accept Android licenses: flutter doctor --android-licenses
# - Update Xcode: sudo xcode-select --reset
# - Install Chrome: brew install google-chrome
```

#### 2. Ollama Connection Issues

**Problem:** App cannot connect to Ollama

**Solutions:**

```bash
# 1. Check if Ollama is running
curl http://localhost:11434/api/tags

# 2. Check firewall settings
# - Windows: Allow Ollama through firewall
# - macOS: System Preferences > Security & Privacy > Firewall

# 3. Check if port 11434 is in use
# Windows: netstat -ano | findstr 11434
# macOS/Linux: lsof -i :11434

# 4. Configure custom Ollama URL in app settings
```

#### 3. Build Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build

# For Android
cd android && gradlew clean && cd ..
flutter build apk

# For iOS
cd ios && rm -rf Pods && rm Podfile.lock && pod install && cd ..
flutter build ios
```

#### 4. Permission Issues

**Android:**

```bash
# Grant permissions in Settings app or programmatically
adb shell pm grant com.example.ai_agent_assistant android.permission.CAMERA
adb shell pm grant com.example.ai_agent_assistant android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.example.ai_agent_assistant android.permission.WRITE_EXTERNAL_STORAGE
```

**iOS:**

- Settings > [App Name] > Permissions
- Grant Camera, Photos, and Microphone access

#### 5. Storage Issues

```bash
# Check available storage
# Android: Settings > Storage
# iOS: Settings > General > iPhone Storage

# Clear app cache
# Android: Settings > Apps > [App] > Storage > Clear Cache
# iOS: Settings > General > iPhone Storage > [App] > Offload App
```

#### 6. Performance Issues

```bash
# Profile app performance
flutter run --profile

# Generate profile report
flutter run --profile --no-publish-port

# Trace performance
flutter trace
```

### Model-Specific Issues

#### Out of Memory

```bash
# Use smaller models
ollama pull mistral  # 7B - lightweight
ollama pull neural-chat  # Optimized for chat
ollama pull orca-mini  # Even smaller

# Configure model in app settings
```

#### Slow Response Time

```bash
# Ensure Ollama has dedicated resources
# Close other applications
# Check system RAM usage

# Run Ollama on high-performance cores
# Linux: taskset -c 0-7 ollama serve
```

#### No Models Available

```bash
# List and download models
ollama list
ollama pull llama2
ollama pull mistral
```

## Verification

### Test Setup

```bash
# 1. Check Flutter environment
flutter doctor -v

# 2. Check Ollama
curl http://localhost:11434/api/tags

# 3. Run app
flutter run -v

# 4. Test AI response in app
# - Create new conversation
# - Send test message
# - Verify response from Ollama
```

### Performance Baseline

## Next Steps

1. Read [README.md](README.md) for feature overview
2. Review [API Documentation](API.md)
3. Check [Development Guidelines](DEVELOPMENT.md)
4. Explore example conversations and tasks

## Support

For issues:

1. Check this guide's troubleshooting section
2. Review Flutter documentation: [https://flutter.dev/docs](https://flutter.dev/docs)
3. Check Ollama documentation: [https://ollama.ai](https://ollama.ai)
4. Open GitHub issue with detailed logs

---

**Happy Development! 🚀**
