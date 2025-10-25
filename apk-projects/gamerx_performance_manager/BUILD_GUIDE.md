# 🚀 GamerX Performance Manager - Build & Install Guide

## ✅ Status: Ready to Build

All dependencies installed successfully! The app has been completely redesigned with:
- ✨ Modern drawer navigation
- 🎬 60fps animations throughout
- 📊 Real-time hardware monitoring
- 📱 Professional UI/UX
- 🎨 Glassmorphism effects

---

## 📋 Prerequisites

✅ Flutter SDK installed at: `/home/gamerx/android-dev/flutter/`
✅ Android SDK configured
✅ All dependencies downloaded
✅ Icon asset ready

---

## 🔨 Build Commands

### 1. Get Dependencies (Already Done ✓)
```bash
cd /home/gamerx/magisk-development/apk-projects/gamerx_performance_manager
/home/gamerx/android-dev/flutter/bin/flutter pub get
```

### 2. Analyze Code (Check for issues)
```bash
/home/gamerx/android-dev/flutter/bin/flutter analyze
```

### 3. Build Debug APK (For Testing)
```bash
/home/gamerx/android-dev/flutter/bin/flutter build apk --debug
```
**Output:** `build/app/outputs/flutter-apk/app-debug.apk`

### 4. Build Release APK (For Production)
```bash
/home/gamerx/android-dev/flutter/bin/flutter build apk --release
```
**Output:** `build/app/outputs/flutter-apk/app-release.apk`

### 5. Build App Bundle (For Play Store)
```bash
/home/gamerx/android-dev/flutter/bin/flutter build appbundle --release
```
**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## 📱 Install on Device

### Via ADB (Recommended)
```bash
# Install debug build
adb install build/app/outputs/flutter-apk/app-debug.apk

# Install release build
adb install build/app/outputs/flutter-apk/app-release.apk

# Install and replace existing
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Via File Manager
1. Build the APK
2. Copy to device
3. Install manually

---

## 🧪 Testing Checklist

### Before Building:
- [x] All screen files created
- [x] Theme system configured
- [x] Dependencies installed
- [x] Icon asset in place

### After Building:
- [ ] APK installs successfully
- [ ] App opens without crash
- [ ] Drawer menu opens smoothly
- [ ] All 4 screens load correctly
- [ ] Profile switching works
- [ ] Monitor screen updates (every 2s)
- [ ] System info displays correctly
- [ ] Animations are smooth (60fps)
- [ ] No permission errors

---

## 🐛 Troubleshooting

### Issue: Flutter command not found
**Solution:**
```bash
# Add to PATH or use full path
export PATH="$PATH:/home/gamerx/android-dev/flutter/bin"
# Or use full path directly
/home/gamerx/android-dev/flutter/bin/flutter [command]
```

### Issue: Build fails with dependency errors
**Solution:**
```bash
# Clean and rebuild
/home/gamerx/android-dev/flutter/bin/flutter clean
/home/gamerx/android-dev/flutter/bin/flutter pub get
/home/gamerx/android-dev/flutter/bin/flutter build apk --release
```

### Issue: "Execution failed for task ':app:mergeDebugResources'"
**Solution:**
```bash
# Clean build cache
cd android
./gradlew clean
cd ..
/home/gamerx/android-dev/flutter/bin/flutter build apk
```

### Issue: Icon asset not found
**Solution:**
```bash
# Ensure icon is at correct path
ls -la assets/icons/app_icon.png
# If missing, copy it:
cp /home/gamerx/icon.jpg assets/icons/app_icon.png
```

### Issue: Root commands don't work
**Solution:**
- Ensure device is rooted
- Grant root permission to app
- Check if gamerx_perf_engine is at `/system/bin/`

---

## 📊 Performance Optimization

### Release Build Optimizations (Already Configured)
```yaml
# In android/app/build.gradle:
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### APK Size Optimization
```bash
# Build with --split-per-abi for smaller APKs
/home/gamerx/android-dev/flutter/bin/flutter build apk --release --split-per-abi

# Outputs:
# - app-armeabi-v7a-release.apk (ARM 32-bit)
# - app-arm64-v8a-release.apk (ARM 64-bit)
# - app-x86_64-release.apk (x86 64-bit)
```

---

## 🔐 Signing (Optional - For Distribution)

### Generate Keystore (One-time)
```bash
keytool -genkey -v -keystore ~/gamerx-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias gamerx
```

### Configure Signing
Create `android/key.properties`:
```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=gamerx
storeFile=/home/gamerx/gamerx-release-key.jks
```

Update `android/app/build.gradle`:
```gradle
// Add above android { }
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... existing config ...
        }
    }
}
```

---

## 📦 Distribution

### 1. Manual Distribution
- Build release APK
- Share via web/file transfer
- Users install manually

### 2. GitHub Releases
```bash
# Tag version
git tag -a v2.1.0 -m "GamerX Performance Manager v2.1 Enhanced"
git push origin v2.1.0

# Upload APK to GitHub Releases
```

### 3. F-Droid (Open Source)
- Submit to F-Droid repository
- Automated builds and updates

### 4. Google Play Store
- Build app bundle (AAB)
- Upload to Play Console
- Fill out store listing

---

## 🎯 Quick Build Script

Create `build.sh`:
```bash
#!/bin/bash
cd /home/gamerx/magisk-development/apk-projects/gamerx_performance_manager

echo "🧹 Cleaning..."
/home/gamerx/android-dev/flutter/bin/flutter clean

echo "📦 Getting dependencies..."
/home/gamerx/android-dev/flutter/bin/flutter pub get

echo "🔍 Analyzing code..."
/home/gamerx/android-dev/flutter/bin/flutter analyze

echo "🔨 Building release APK..."
/home/gamerx/android-dev/flutter/bin/flutter build apk --release

echo "✅ Build complete!"
echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"

# Get APK size
APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
echo "📊 APK Size: $APK_SIZE"

# Optional: Install to device
read -p "Install to connected device? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    adb install -r build/app/outputs/flutter-apk/app-release.apk
    echo "✅ Installed!"
fi
```

Make executable:
```bash
chmod +x build.sh
./build.sh
```

---

## 📈 Expected APK Size

- **Debug APK:** ~40-50 MB
- **Release APK:** ~20-25 MB
- **Release APK (split-per-abi):** ~15-18 MB each

---

## 🎨 App Features Summary

### 4 Main Screens:
1. **Profiles** - Performance mode selection with animations
2. **Monitor** - Real-time CPU/GPU/RAM/Temp monitoring
3. **System Info** - Complete device specifications
4. **About** - App information and credits

### Animations:
- Drawer slide-in with staggered menu items
- Page transitions (fade + slide)
- Profile card pulse effects
- Monitor stat updates
- Shimmer loading skeletons
- Button press feedback

### Design:
- Pure black theme (#0a0a0a)
- Neon green accent (#00ff41)
- Glassmorphism effects
- Material Design 3
- 60fps animations

---

## 🚀 Ready to Build!

All files are in place. Run:

```bash
cd /home/gamerx/magisk-development/apk-projects/gamerx_performance_manager
/home/gamerx/android-dev/flutter/bin/flutter build apk --release
```

Then install:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Enjoy your advanced GamerX Performance Manager!** 🎉

---

**Build Date:** 2025-10-24  
**Version:** v2.1 Enhanced  
**Framework:** Flutter 3.x  
**Min Android:** 7.0 (API 24)  
**Target Android:** 16 (API 35)
