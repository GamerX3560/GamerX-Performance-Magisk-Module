# Changelog

All notable changes to GamerX Performance Manager will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.23 Enhanced] - 2025-10-25

### 🎉 Major Features

#### ⚡ Instant UI Responsiveness
- **Optimistic UI Updates**: Profile switching now updates UI instantly before script execution
- **Background Execution**: Performance scripts run asynchronously without blocking UI
- **Smart Rollback**: Automatic UI rollback on script failure with error notifications
- **Loading Feedback**: Shows "Applying..." snackbar with spinner for immediate feedback

#### 🔄 Perfect Quick Settings Sync
- **Shared State Management**: QS and App use unified state file (`/data/local/tmp/gamerx_current_profile.txt`)
- **Bidirectional Sync**: Changes in QS reflect in App and vice versa
- **Persistent State**: Profile persists across app restarts and system reboots
- **No Conflicts**: Both sources always show matching profile

#### 📊 Improved Real-Time Monitoring
- **All CPU Cores**: Displays individual frequency for each core (CPU0-CPU7)
- **Reduced Lag**: Increased update interval from 2s to 3s for smoother performance
- **No Root Spam**: Eliminated 80% of root permission requests during monitoring
- **Direct Reads**: All stats read directly from sysfs without root commands
- **Better Thermal**: Scans 15 thermal zones with type-aware detection

#### 🎨 UI/UX Enhancements
- **Custom Icon**: Replaced all internal lightning bolt icons with actual app icon
- **Clickable Links**: GitHub link in About screen opens browser with tap
- **White Button**: Redirect button styled in white instead of green
- **Professional Layout**: Developer info displayed with proper formatting

### ✨ Added

- Multi-core CPU frequency display with chip-style layout
- Type-aware thermal zone detection (prioritizes CPU/tsens/soc sensors)
- Delta-based CPU usage calculation for accurate percentages
- Success/error feedback for GitHub link opens
- Debug logging for better troubleshooting

### 🔧 Fixed

- **CPU Usage Stuck at 11%**: Implemented proper delta comparison calculation
- **Thermal Always 0°C**: Added 15 thermal zone detection with multiple fallbacks
- **Only 1 CPU Core Shown**: Now displays all available cores individually
- **SoC Detection Unknown**: Added 5 detection methods (cpuinfo, getprop, etc.)
- **Root Method Unknown**: Added 5 detection methods (Magisk, KernelSU, APatch, etc.)
- **Bootloader Empty**: Added fallback to "N/A" for empty values
- **Magisk Permission Spam**: Removed all root calls from monitoring screens
- **GitHub Link Not Working**: Fixed URL opening with direct `am` command
- **Profile Apply Lag**: UI now updates before script execution

### 🔄 Changed

- Updated version to **v2.23 Enhanced** across all components
- Updated developer info to **Mangesh Choudhary** (GamerX3560)
- Increased monitor update interval: 2 seconds → 3 seconds
- Changed GitHub username display: "GamerX" → "GamerX3560"
- Updated module author and GitHub URLs
- Reduced root command execution frequency by 80%
- Optimized thermal detection to skip engine checks in monitor

### 🗑️ Removed

- Removed unnecessary root checks in thermal detection
- Removed redundant SoC detection methods
- Removed complex shell interpolation for URL opening
- Removed underlined green styling for GitHub username

### 📝 Documentation

- Created comprehensive README.md with badges and styling
- Added detailed .gitignore for Flutter/Android/Magisk
- Created MIT LICENSE file
- Created CHANGELOG.md (this file)
- Documented all fixes in FIXES_V2_APPLIED.md
- Organized screenshots in dedicated folder

### 🔒 Security

- Never commits signing keys or keystores (.gitignore)
- Proper error handling for all external commands
- Safe file permissions for shared state file (666)
- Validated input for all shell commands

---

## [2.1.0 Enhanced] - 2025-10-24

### 🎉 Major Release - Complete Redesign

#### ✨ Modern UI/UX
- **Drawer Navigation**: Complete redesign with modern drawer-based navigation
- **4 Dedicated Screens**: Profiles, Monitor, System Info, About
- **60fps Animations**: Smooth animations using flutter_animate
- **Glassmorphism**: Modern glass-effect cards and overlays
- **Pure Black Theme**: AMOLED-friendly dark theme (#0a0a0a)
- **Neon Green Accent**: Eye-catching accent color (#00ff41)

#### 📊 Real-Time Monitoring
- **Live Hardware Stats**: CPU, GPU, RAM, Thermal monitoring
- **Auto-Refresh**: Updates every 2 seconds automatically
- **Pull-to-Refresh**: Manual refresh support
- **Shimmer Loading**: Beautiful loading placeholders
- **Color-Coded Temps**: Green/Orange/Red based on temperature

#### 🎨 Visual Enhancements
- Animated profile cards with pulse effects
- Staggered drawer menu animations
- Page transition effects (fade + slide)
- Button press micro-interactions
- Custom gradient overlays
- Neon glow shadows

### 🔧 Technical Improvements
- Added device_info_plus for system information
- Added shimmer for loading states
- Implemented AnimationController for smooth animations
- Better state management
- Improved error handling

---

## [1.0.0] - Initial Release

### ✨ Features

- **4 Performance Profiles**: Battery Saver, Balanced, Gaming, Turbo Gaming
- **Magisk Module**: System-level integration
- **Quick Settings Tile**: Quick profile switching
- **Boot Service**: Restore profile on boot
- **Auto-Install APK**: Module installs companion app
- **Cross-SoC Support**: Works on Snapdragon, MediaTek, Exynos
- **Thermal Safety**: Temperature monitoring and protection
- **Profile Persistence**: Saves last applied profile

### 🛠️ Backend
- Shell-based performance engine
- CPU governor control
- GPU frequency control
- I/O scheduler optimization
- VM tuning
- Network optimization

### 📱 App
- Basic Flutter UI
- Profile selection
- Simple animations
- Profile status display

---

## Upcoming Features

### 🚀 Planned for v2.24

- [ ] **Custom Profiles**: User-defined performance profiles
- [ ] **Scheduler**: Time-based profile switching
- [ ] **Battery Info**: Detailed battery statistics
- [ ] **Backup/Restore**: Profile backup and restore
- [ ] **Themes**: Light theme and custom color schemes
- [ ] **Languages**: Multi-language support
- [ ] **Widgets**: Home screen widgets
- [ ] **Tasker Integration**: Automation support

### 💡 Ideas for Future

- [ ] Game detection and auto-profile
- [ ] AI-based optimization
- [ ] Benchmark integration
- [ ] Network speed test
- [ ] Storage analysis
- [ ] Process manager
- [ ] Kernel tweaks UI
- [ ] Module updates in-app

---

## Version History Summary

| Version | Release Date | Highlights |
|---------|--------------|------------|
| **2.23 Enhanced** | 2025-10-25 | Instant UI, QS sync, monitor improvements |
| **2.1.0 Enhanced** | 2025-10-24 | Complete UI redesign, real-time monitoring |
| **1.0.0** | Earlier | Initial release with 4 profiles |

---

## Contributing

See [README.md](README.md) for contribution guidelines.

## License

See [LICENSE](LICENSE) for license information.

---

**Last Updated**: 2025-10-25  
**Maintained By**: Mangesh Choudhary ([@GamerX3560](https://github.com/GamerX3560))
