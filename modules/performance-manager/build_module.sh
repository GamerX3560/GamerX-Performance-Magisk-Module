#!/bin/bash

set -e

MODULE_DIR="/home/gamerx/magisk-development/modules/performance-manager"
APK_PROJECT_DIR="/home/gamerx/magisk-development/apk-projects/gamerx_performance_manager"
OUTPUT_DIR="/home/gamerx/magisk-development/output"

echo "🚀 Building GamerX Performance Manager Module..."
echo "=================================================="

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Build Flutter APK with Java 17
echo "📱 Building Flutter APK..."
cd "$APK_PROJECT_DIR"

# Use Java 17 for Android builds
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH="$JAVA_HOME/bin:$PATH"

echo "  → Using Java: $(java -version 2>&1 | head -n 1)"

# Build APK
fish -c "source ~/.config/fish/conf.d/android.fish; export JAVA_HOME=/usr/lib/jvm/java-17-openjdk; flutter build apk --release" || exit 1

# Copy APK
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    cp "build/app/outputs/flutter-apk/app-release.apk" "$MODULE_DIR/GamerXPerformanceManager.apk"
    echo "✅ APK built successfully"
else
    echo "❌ APK build failed"
    exit 1
fi

# Step 2: Set permissions
echo "🔧 Setting module permissions..."
cd "$MODULE_DIR"
chmod 755 customize.sh service.sh system/bin/gamerx_perf_engine
chmod 644 module.prop GamerXPerformanceManager.apk

# Step 3: Create module ZIP
echo "📦 Creating module ZIP..."
zip -r "$OUTPUT_DIR/GamerX-Performance-Manager-v1.0.0.zip" \
    module.prop customize.sh service.sh system/ META-INF/ GamerXPerformanceManager.apk \
    config/ profiles/

echo ""
echo "🎉 Build completed successfully!"
echo "=================================================="
echo "📁 Module location: $OUTPUT_DIR/GamerX-Performance-Manager-v1.0.0.zip"
echo "📱 APK location: $MODULE_DIR/GamerXPerformanceManager.apk"
echo ""
echo "📋 Installation Instructions:"
echo "1. Flash the ZIP file in Magisk Manager"
echo "2. Reboot your device"
echo "3. Open GamerX Performance Manager app"
echo "4. Add Quick Settings tile for easy access"
echo ""
echo "🎮 Supported Profiles:"
echo "   • Battery Saver - Maximum battery life"
echo "   • Balanced - Stock with optimizations"  
echo "   • Gaming - Performance focused"
echo "   • Turbo Gaming - Maximum performance"
echo ""
echo "🔧 Command Line Usage:"
echo "   su -c 'gamerx_perf_engine apply gaming'"
echo "   su -c 'gamerx_perf_engine info'"
echo ""
echo "🌡️ Features:"
echo "   • Cross-SoC compatibility (Snapdragon/MediaTek/Exynos)"
echo "   • Thermal safety protection (70°C/80°C/90°C thresholds)"
echo "   • Advanced memory management"
echo "   • Gaming-optimized I/O scheduling"
echo "   • Quick Settings tile integration"
echo "   • Modern Flutter UI with animations"
