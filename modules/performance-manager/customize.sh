#!/system/bin/sh

#####################################
# GamerX Performance Manager Installer
# Advanced Performance Module with APK
# Author: GamerXECO
# Version: 1.0.0
#####################################

# Module info
MODULE_NAME="GamerX Performance Manager"
MODULE_VERSION="v1.0.0"
APK_NAME="GamerXPerformanceManager.apk"

# Paths
MODPATH="$MODPATH"
APK_PATH="$MODPATH"
BIN_PATH="$MODPATH/system/bin"
CONFIG_DIR="$MODPATH/config"
PROFILE_DIR="$MODPATH/profiles"

ui_print "***************************************"
ui_print "    GamerX Performance Manager v1.0.0"
ui_print "    Advanced Gaming Performance Tweaks"
ui_print "    Author: GamerXECO"
ui_print "***************************************"
ui_print ""

# Detect device info
DEVICE_SOC=$(getprop ro.hardware.chipset 2>/dev/null || getprop ro.board.platform 2>/dev/null || getprop ro.hardware 2>/dev/null)
ANDROID_VERSION=$(getprop ro.build.version.release)
DEVICE_MODEL=$(getprop ro.product.model)

ui_print "📱 Device: $DEVICE_MODEL"
ui_print "🤖 Android: $ANDROID_VERSION"
ui_print "🔧 SoC: $DEVICE_SOC"
ui_print ""

# Check Android version compatibility
if [ "$(echo "$ANDROID_VERSION" | cut -d. -f1)" -lt 13 ]; then
    ui_print "❌ ERROR: Android 13+ required!"
    ui_print "   Current version: Android $ANDROID_VERSION"
    abort "Unsupported Android version"
fi

# Detect root method
if [ -d "/data/adb/magisk" ]; then
    ROOT_METHOD="Magisk"
elif [ -d "/data/adb/ksu" ] || [ -f "/data/adb/ksu/bin/ksud" ]; then
    ROOT_METHOD="KernelSU"
elif [ -d "/data/adb/ap" ] || [ -f "/data/adb/ap/bin/apd" ]; then
    ROOT_METHOD="APatch"
else
    ROOT_METHOD="Unknown"
fi

ui_print "🔐 Root Method: $ROOT_METHOD"
ui_print ""

# Create directories
ui_print "📁 Creating module structure..."
mkdir -p "$APK_PATH"
mkdir -p "$BIN_PATH"
mkdir -p "$CONFIG_DIR"
mkdir -p "$PROFILE_DIR"

set_perm "$BIN_PATH/gamerx_perf_engine" 0 0 0755

# Install APK as privileged system app with proper native library support
if [ -f "$MODPATH/GamerXPerformanceManager.apk" ]; then
    ui_print "📱 Installing GamerX Performance Manager as privileged system app..."
    
    # Create proper system app directory structure
    APP_DIR="$MODPATH/system/priv-app/GamerXPerformanceManager"
    mkdir -p "$APP_DIR"
    mkdir -p "$APP_DIR/lib"
    
    # Copy APK to privileged system app location
    cp "$MODPATH/GamerXPerformanceManager.apk" "$APP_DIR/GamerXPerformanceManager.apk"
    ui_print "  ✅ APK copied to privileged system location"
    
    # Extract and properly place native libraries
    ui_print "  → Extracting native libraries..."
    cd /tmp
    rm -rf gamerx_lib_extract 2>/dev/null
    mkdir -p gamerx_lib_extract
    cd gamerx_lib_extract
    
    # Extract lib folder from APK
    if unzip -q "$MODPATH/GamerXPerformanceManager.apk" "lib/*" 2>/dev/null; then
        if [ -d "lib" ]; then
            # Copy all architecture libraries to system app
            cp -r lib/* "$APP_DIR/lib/"
            
            ui_print "  ✅ Native libraries extracted:"
            
            # List and set permissions for each architecture
            for arch_dir in "$APP_DIR/lib"/*; do
                if [ -d "$arch_dir" ]; then
                    arch_name=$(basename "$arch_dir")
                    lib_count=$(find "$arch_dir" -name "*.so" | wc -l)
                    ui_print "    → $arch_name: $lib_count libraries"
                    
                    # Set proper permissions for .so files
                    find "$arch_dir" -name "*.so" -exec chmod 0644 {} \;
                    find "$arch_dir" -name "*.so" -exec chown 0:0 {} \;
                fi
            done
            
            # Also create symlinks in /system/lib64 for system-wide access
            if [ -d "$APP_DIR/lib/arm64-v8a" ]; then
                mkdir -p "$MODPATH/system/lib64"
                for so_file in "$APP_DIR/lib/arm64-v8a"/*.so; do
                    if [ -f "$so_file" ]; then
                        so_name=$(basename "$so_file")
                        ln -sf "/system/priv-app/GamerXPerformanceManager/lib/arm64-v8a/$so_name" "$MODPATH/system/lib64/$so_name"
                        ui_print "    → Linked $so_name to system lib64"
                    fi
                done
            fi
            
        else
            ui_print "  ⚠️  No lib directory found in APK"
        fi
    else
        ui_print "  ❌ Failed to extract libraries from APK"
        exit 1
    fi
    
    # Clean up temp files
    cd "$MODPATH"
    rm -rf /tmp/gamerx_lib_extract 2>/dev/null
    
    # Set comprehensive permissions for privileged system app
    set_perm_recursive "$APP_DIR" 0 0 0755 0644
    
    # Set specific permissions for APK
    set_perm "$APP_DIR/GamerXPerformanceManager.apk" 0 0 0644
    
    # Create proper privileged app configuration
    mkdir -p "$MODPATH/system/etc/permissions"
    cat > "$MODPATH/system/etc/permissions/com.gamerxeco.gamerx_performance_manager.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.gamerxeco.gamerx_performance_manager">
        <permission name="android.permission.WRITE_SECURE_SETTINGS"/>
        <permission name="android.permission.MODIFY_PHONE_STATE"/>
        <permission name="android.permission.DEVICE_POWER"/>
        <permission name="android.permission.REBOOT"/>
        <permission name="android.permission.WRITE_SETTINGS"/>
        <permission name="android.permission.SYSTEM_ALERT_WINDOW"/>
        <permission name="android.permission.EXPAND_STATUS_BAR"/>
        <permission name="android.permission.BIND_QUICK_SETTINGS_TILE"/>
        <permission name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    </privapp-permissions>
</permissions>
EOF
    
    # Set permissions for the XML file
    set_perm "$MODPATH/system/etc/permissions/com.gamerxeco.gamerx_performance_manager.xml" 0 0 0644
    
    # Create Android.mk for proper system integration
    cat > "$APP_DIR/Android.mk" << 'EOF'
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := GamerXPerformanceManager
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional
LOCAL_BUILT_MODULE_STEM := package.apk
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_PRIVILEGED_MODULE := true
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_SRC_FILES := GamerXPerformanceManager.apk
LOCAL_PREBUILT_JNI_LIBS := \
    lib/arm64-v8a/libapp.so \
    lib/arm64-v8a/libflutter.so
include $(BUILD_PREBUILT)
EOF
    
    # Set permissions for Android.mk
    set_perm "$APP_DIR/Android.mk" 0 0 0644
    
    ui_print "  ✅ APK installed as privileged system app"
    ui_print "  ✅ Native libraries properly configured with symlinks"
    ui_print "  ✅ Advanced system permissions granted"
    
else
    ui_print "❌ APK not found, installation failed"
    exit 1
fi

# Create default configuration
ui_print "⚙️  Creating default configuration..."
cat > "$CONFIG_DIR/default_profile" << EOF
balanced
EOF

cat > "$CONFIG_DIR/thermal_config" << EOF
warning_temp=70000
throttle_temp=80000
emergency_temp=90000
EOF

# Create profile definitions
ui_print "🎮 Setting up performance profiles..."

# Battery Saver Profile
cat > "$PROFILE_DIR/battery_saver.conf" << EOF
# Battery Saver Profile - Maximum Battery Life
name=Battery Saver
description=Optimized for maximum battery life
cpu_governor=powersave
cpu_max_freq_percent=60
gpu_governor=powersave
ram_management=aggressive
io_scheduler=noop
EOF

# Balanced Profile  
cat > "$PROFILE_DIR/balanced.conf" << EOF
# Balanced Profile - Stock Performance with Optimizations
name=Balanced
description=Stock-like performance with minor optimizations
cpu_governor=schedutil
cpu_max_freq_percent=100
gpu_governor=default
ram_management=normal
io_scheduler=cfq
EOF

# Gaming Profile
cat > "$PROFILE_DIR/gaming.conf" << EOF
# Gaming Profile - Performance Focused
name=Gaming
description=Optimized for gaming performance
cpu_governor=performance
cpu_max_freq_percent=100
cpu_min_freq_percent=80
gpu_governor=performance
ram_management=performance
io_scheduler=deadline
EOF

# Turbo Gaming Profile
cat > "$PROFILE_DIR/turbo_gaming.conf" << EOF
# Turbo Gaming Profile - Maximum Performance
name=Turbo Gaming
description=Maximum performance with thermal protection
cpu_governor=performance
cpu_max_freq_percent=100
cpu_min_freq_percent=90
gpu_governor=performance
ram_management=performance
io_scheduler=deadline
thermal_monitoring=strict
EOF

# Set default profile
cp "$CONFIG_DIR/default_profile" "$CONFIG_DIR/current_profile"

ui_print "🚀 Installation completed successfully!"
ui_print ""
ui_print "📋 Features installed:"
ui_print "   • Cross-SoC compatibility (Snapdragon/MediaTek/Exynos)"
ui_print "   • 4 Performance profiles"
ui_print "   • Thermal safety protection"
ui_print "   • Advanced memory management"
ui_print "   • Gaming-optimized I/O scheduling"
ui_print ""
ui_print "🎮 Performance Profiles:"
ui_print "   • Battery Saver - Maximum battery life"
ui_print "   • Balanced - Stock with optimizations"
ui_print "   • Gaming - Performance focused"
ui_print "   • Turbo Gaming - Maximum performance"
ui_print ""
ui_print "📱 Open GamerX Performance Manager app to get started!"
ui_print "🔧 Or use: su -c 'gamerx_perf_engine apply gaming'"
ui_print ""
