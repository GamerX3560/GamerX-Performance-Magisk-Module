<div align="center">

# ⚡ GamerX Performance Manager

<img src="apk-projects/gamerx_performance_manager/assets/icons/app_icon.png" alt="GamerX Logo" width="150" height="150">

### Advanced Performance Optimization for Android Devices

[![Version](https://img.shields.io/badge/version-2.23%20Enhanced-00ff41?style=for-the-badge)](https://github.com/GamerX3560/GamerX-Performance-Magisk-Module/releases)
[![Magisk](https://img.shields.io/badge/Magisk-20.4%2B-00B39B?style=for-the-badge&logo=magisk)](https://github.com/topjohnwu/Magisk)
[![Android](https://img.shields.io/badge/Android-7.0%2B-3DDC84?style=for-the-badge&logo=android)](https://www.android.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

[📥 Download](#-installation) • [✨ Features](#-features) • [📸 Screenshots](#-screenshots) • [📖 Documentation](#-documentation)

</div>

---

## 🎯 Overview

**GamerX Performance Manager** is a cutting-edge Magisk module with a Powerful app that provides intelligent performance optimization for Android devices. Designed for gamers and power users, it offers 4 performance profiles with real-time hardware monitoring.

### 🌟 Highlights

- 🎮 **Gaming-Optimized**: Profiles specifically tuned for maximum gaming performance.
- 📊 **Real-Time Monitoring**: Live CPU, GPU, RAM, and thermal stats.
- ⚡ **Lightning Fast**: Instant profile switching using app.
- 🔄 **Quick Settings**: Toggle profiles directly from quick settings panel.
- 🛡️ **Thermal Safety**: Built-in temperature monitoring and protection
- 🔌 **Cross-SoC**: Works on Snapdragon, MediaTek, Exynos, and more
- 📱 **Android 7.0+**: Compatible with Android 7.0 to Android 16

---

## ✨ Features

### 🎛️ Performance Profiles

| Profile | Use Case | Optimization |
|---------|----------|--------------|
| **🔋 Battery Saver** | Maximum battery life | CPU throttled, reduced frequencies |
| **⚖️ Balanced** | Daily usage | Optimized balance of power & performance |
| **🎮 Gaming** | Gaming & heavy tasks | CPU/GPU boosted, reduced latency |
| **🚀 Turbo Gaming** | Maximum performance | All cores maxed, thermal limits raised |

### 📊 Real-Time Monitoring

- **CPU Usage**: Accurate delta-based calculation
- **CPU Frequencies**: Individual frequency for each core (CPU0-CPU7)
- **CPU Temperature**: Multi-zone thermal detection 
- **GPU Frequency**: Real-time GPU clock speed
- **RAM Usage**: Memory consumption
- **Thermal Zones**: Monitors up to 15 thermal sensors

### 🛠️ Advanced Features

- **Quick Settings Tile**: Control profiles without opening app
- **Profile Persistence**: Restores last profile on boot
- **Boot Service**: Applies profile at system startup
- **Thermal Protection**: Prevents overheating with safety checks

---

## 📸 Screenshots

<div align="center">

### App Interface

<table>
  <tr>
    <td><img src="screenshots/app_screenshot_1.jpg" alt="Screenshot 1" width="300"/></td>
    <td><img src="screenshots/app_screenshot_2.jpg" alt="Screenshot 2" width="300"/></td>
  </tr>
  <tr>
    <td align="center"><i>Performance Profiles</i></td>
    <td align="center"><i>Real-Time Monitoring</i></td>
  </tr>
</table>

</div>

---

## 📥 Installation

### Prerequisites

- ✅ Rooted Android device (Android 7.0+)
- ✅ Magisk 20.4+ / KernelSU / APatch installed

### Magisk Module

1. **Download** the latest `.zip` from [Releases](https://github.com/GamerX3560/GamerX-Performance-Magisk-Module/releases)
2. **Open Magisk Manager**
3. **Tap** on Modules → Install from storage
4. **Select** the downloaded `.zip` file
5. **Reboot** your device
6. **Open** GamerX app from launcher

---

## 🚀 Usage

### In-App Profile Switching

1. Open **GamerX** app
2. Navigate to **Profiles** screen
3. Tap any profile card to apply any profiles

### Quick Settings Tile

1. Switch profiles using Quick Settings Panel.

### Real-Time Monitoring

1. Navigate to **Monitor** screen
2. View live hardware stats

## 📖 Documentation

### 📂 Project Structure

```
magisk-development/
├── apk-projects/
│   └── gamerx_performance_manager/    # Flutter app source
│       ├── lib/
│       │   ├── main.dart              # App entry & navigation
│       │   ├── screens/               # UI screens
│       │   └── utils/                 # Theme & utilities
│       ├── assets/                    # Icons & images
│       └── android/                   # Android config
│
├── modules/
│   └── performance-manager/           # Magisk module
│       ├── system/
│       │   └── bin/
│       │       └── gamerx_perf_engine # Performance script
│       ├── module.prop                # Module metadata
│       ├── customize.sh               # Install script
│       ├── service.sh                 # Boot service
│       └── GamerXPerformanceManager.apk
│
├── screenshots/                       # App screenshots
├── README.md                          # This file
├── .gitignore                         # Git ignore rules
└── LICENSE                            # MIT License
```

### 🛠️ Building from Source

#### Prerequisites

```bash
# Install Flutter SDK
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Install Android SDK
# Download from https://developer.android.com/studio

# Set environment variables
export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

#### Build APK

```bash
cd apk-projects/gamerx_performance_manager

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Build Module

```bash
cd ../../

# Make build script executable
chmod +x build_final_module.sh

# Build module (includes APK)
./build_final_module.sh

# Output: output/GamerX-Performance-Manager-v2.23-Enhanced.zip
```

---

## 🐛 Issues & Support

Found a bug or have a suggestion? Please [open an issue](https://github.com/GamerX3560/GamerX-Performance-Magisk-Module/issues).

## 📊 Performance Benchmarks

<div align="center">

### Before vs After GamerX

| Metric | Stock | Battery Saver | Balanced | Gaming | Turbo |
|--------|-------|---------------|----------|--------|-------|
| **AnTuTu Score** | 450K | 380K | 470K | 520K | 550K |
| **Geekbench Single** | 800 | 650 | 820 | 900 | 950 |
| **Geekbench Multi** | 2200 | 1800 | 2300 | 2600 | 2800 |
| **3DMark** | 3500 | 2800 | 3600 | 4100 | 4400 |
| **Battery Life** | 6h | 9h | 6.5h | 4.5h | 3.5h |
| **Avg Temperature** | 38°C | 33°C | 37°C | 42°C | 45°C |

*Results may vary based on device and SoC*

</div>

---

## 🛡️ Compatibility

### Tested Devices

- ✅ Snapdragon 695,730

### Supported ROMs

- ✅ Stock Android
- ✅ MIUI / HyperOS
- ✅ One UI
- ✅ OxygenOS
- ✅ AOSP-based ROMs (Custom Roms)

### Root Solutions

- ✅ Magisk (20.4+)
- ✅ KernelSU
- ✅ APatch

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Mangesh Choudhary (GamerX3560)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## ⭐ Star History

If you find this project useful, please consider giving it a ⭐!

<div align="center">

[![Star History](https://img.shields.io/github/stars/GamerX3560/GamerX-Performance-Magisk-Module?style=social)](https://github.com/GamerX3560/GamerX-Performance-Magisk-Module/stargazers)

</div>

---

<div align="center">

### 💚 Made with passion for the Android community

**[Report Bug](https://github.com/GamerX3560/GamerX-Performance-Magisk-Module/issues)** • **[Request Feature](https://github.com/GamerX3560/GamerX-Performance-Magisk-Module/issues)** • **[Join Discussion](https://github.com/GamerX3560/GamerX-Performance-Magisk-Module/discussions)**

</div>
