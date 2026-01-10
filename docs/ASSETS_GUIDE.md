# Assets Guide - Adding Images, Icons, Animations & Fonts

This guide explains how to properly add assets to your Flutter app.

## 📁 Asset Folders Structure

```
assets/
├── images/           → App images and illustrations
├── icons/            → App icons (SVG or PNG)
├── animations/       → Lottie JSON animations
└── fonts/            → Custom font files (TTF)
```

## 🖼️ Images (`assets/images/`)

### Recommended Image Assets

```
assets/images/
├── app_logo.png
├── app_icon.png
├── splash_screen.png
├── empty_state.png
├── error_illustration.png
├── loading_spinner.gif
├── onboarding_1.png
├── onboarding_2.png
└── onboarding_3.png
```

### Image Specifications

### Density Variants

Flutter supports multiple densities:

```
assets/images/
├── image.png          # 1x density (mdpi) - 100x100
├── image@2x.png       # 2x density (xhdpi) - 200x200
└── image@3x.png       # 3x density (xxhdpi) - 300x300
```

### Using Images in Code

```dart
// Simple image
Image.asset('assets/images/app_logo.png')

// With sizing
Image.asset(
  'assets/images/app_logo.png',
  width: 200,
  height: 200,
)

// In widgets
Container(
  child: Image.asset('assets/images/empty_state.png'),
)

// With fade in
FadeInImage(
  placeholder: AssetImage('assets/images/placeholder.png'),
  image: AssetImage('assets/images/full_image.png'),
)
```

## 🎨 Icons (`assets/icons/`)

### Recommended Icon Assets

```
assets/icons/
├── chat_icon.svg
├── task_icon.svg
├── camera_icon.svg
├── document_icon.svg
├── settings_icon.svg
├── home_icon.svg
├── back_icon.svg
├── menu_icon.svg
├── search_icon.svg
├── add_icon.svg
├── delete_icon.svg
├── edit_icon.svg
├── send_icon.svg
└── close_icon.svg
```

### SVG Icons (Recommended)

SVG icons are scalable and lightweight.

```dart
// Using flutter_svg package
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/icons/chat_icon.svg',
  width: 24,
  height: 24,
  color: Colors.blue,
)
```

**Add to pubspec.yaml:**

```yaml
dependencies:
  flutter_svg: ^2.0.0
```

### Built-in Material Icons

Flutter comes with Material Icons - no need to add!

```dart
Icon(Icons.chat)
Icon(Icons.task_alt)
Icon(Icons.camera)
Icon(Icons.settings)
```

### PNG Icons as Fallback

If SVG isn't available, use PNG icons:

```
assets/icons/
├── chat_icon.png
├── chat_icon@2x.png
├── chat_icon@3x.png
├── task_icon.png
├── task_icon@2x.png
└── task_icon@3x.png
```

## 🎬 Animations (`assets/animations/`)

### Recommended Animation Assets

```
assets/animations/
├── loading.json
├── success.json
├── error.json
├── empty_state.json
├── typing.json
├── thinking.json
├── processing.json
└── celebration.json
```

### Lottie Animations

Lottie animations are already configured in pubspec.yaml!

#### Getting Lottie Animations

1. Visit: [lottie.com](https://lottie.com)
2. Search for animation you want
3. Download as JSON
4. Place in `assets/animations/`

#### Using Lottie Animations

```dart
import 'package:lottie/lottie.dart';

// Simple animation
Lottie.asset('assets/animations/loading.json')

// Looping
Lottie.asset(
  'assets/animations/loading.json',
  repeat: true,
)

// With size
Lottie.asset(
  'assets/animations/loading.json',
  width: 200,
  height: 200,
)

// One time play
Lottie.asset(
  'assets/animations/success.json',
  repeat: false,
)

// As a loading indicator
Lottie.asset(
  'assets/animations/loading.json',
  repeat: true,
  width: 100,
  height: 100,
)
```

### Example Usage in App

```dart
// Loading screen with animation
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset('assets/animations/loading.json'),
    );
  }
}

// Success dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    content: Lottie.asset('assets/animations/success.json'),
  ),
);
```

## 🔤 Fonts (`assets/fonts/`)

### Recommended Font Files

```
assets/fonts/
├── Roboto-Regular.ttf
├── Roboto-Bold.ttf
├── Roboto-Light.ttf
├── Roboto-Medium.ttf
├── Roboto-SemiBold.ttf
├── Roboto-Italic.ttf
└── Roboto-BoldItalic.ttf
```

### Font Configuration (Already Done!)

In `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
        - asset: assets/fonts/Roboto-Light.ttf
          weight: 300
        - asset: assets/fonts/Roboto-Medium.ttf
          weight: 500
```

### Adding More Fonts

1. Download .ttf font file
2. Place in `assets/fonts/`
3. Update `pubspec.yaml`
4. Run `flutter pub get`
5. Use in code

### Using Custom Fonts

```dart
// Using Roboto (configured)
Text(
  'Hello World',
  style: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
)

// Light weight
Text(
  'Light Text',
  style: TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w300,
  ),
)

// Custom Google Font
import 'package:google_fonts/google_fonts.dart';

Text(
  'Beautiful Text',
  style: GoogleFonts.poppins(fontSize: 20),
)
```

## 📝 Steps to Add Assets

### 1. Place Asset Files

```bash
# Example: Adding an image
cp /path/to/image.png flutter_ai_agent_app/assets/images/
cp /path/to/image@2x.png flutter_ai_agent_app/assets/images/
cp /path/to/image@3x.png flutter_ai_agent_app/assets/images/
```

### 2. Update pubspec.yaml

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - assets/fonts/
```

### 3. Run Pub Get

```bash
flutter pub get
```

### 4. Run/Build App

```bash
flutter run
```

## 🎯 Best Practices

### Image Best Practices

✅ **DO:**

- Use PNG for images (lossless)
- Create @2x and @3x variants
- Compress images before adding
- Organize by feature or type

❌ **DON'T:**

- Use huge image files
- Mix scaled versions
- Add unnecessary formats
- Skip density variants

### Icon Best Practices

✅ **DO:**

- Use SVG for icons (scalable)
- Use Material Icons when possible
- Keep consistent style
- Use proper colors

❌ **DON'T:**

- Create oversized icons
- Mix icon styles
- Use raster formats unnecessarily
- Ignore accessibility

### Animation Best Practices

✅ **DO:**

- Use Lottie for complex animations
- Optimize JSON files
- Test performance
- Use appropriate sizes

❌ **DON'T:**

- Create very large animations
- Loop unnecessary animations
- Use animations on old devices
- Ignore loading times

### Font Best Practices

✅ **DO:**

- Use standard weights (300, 400, 500, 700)
- Include italic variants if needed
- Test on different devices
- Use appropriate sizes

❌ **DON'T:**

- Use too many different fonts
- Use fonts that don't match design
- Ignore system fonts
- Create custom fonts unnecessarily

## 📊 Asset File Size Guidelines

## 🔗 Useful Resources

- **Lottie Animations:** [https://lottie.com](https://lottie.com)
- **SVG Icons:** [https://www.flaticon.com](https://www.flaticon.com)
- **Free Images:** [https://unsplash.com](https://unsplash.com)
- **Google Fonts:** [https://fonts.google.com](https://fonts.google.com)
- **Material Design:** [https://material.io/design](https://material.io/design)

## 🚀 Next Steps

1. **Collect Assets:**
  - Download icons from design tools
  - Get Lottie animations from lottie.com
  - Prepare images
2. **Optimize:**
  - Compress images
  - Check file sizes
  - Create density variants
3. **Organize:**
  - Place in correct folders
  - Name consistently
  - Update pubspec.yaml
4. **Test:**
  - Run app
  - Check display
  - Verify sizing
  - Test on devices
5. **Use in Code:**
  - Import assets
  - Add to widgets
  - Style appropriately
  - Test performance

## 📞 Troubleshooting

### Assets not loading?

1. Check pubspec.yaml has correct paths
2. Ensure files are in correct folders
3. Run `flutter pub get`
4. Clean and rebuild: `flutter clean && flutter run`

### Images look blurry?

1. Provide @2x and @3x variants
2. Use correct device density
3. Check image quality
4. Verify sizing

### Animations slow?

1. Optimize JSON file size
2. Reduce animation complexity
3. Test on actual device
4. Check performance with DevTools

### Fonts not applying?

1. Check spelling in fontFamily
2. Verify pubspec.yaml configuration
3. Ensure .ttf file is in assets/fonts/
4. Run `flutter pub get`

---

**Happy Designing! 🎨**
