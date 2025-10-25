#!/system/bin/sh

#####################################
# GamerX Performance Manager Service
# Boot-time Performance Optimization
# Author: GamerXECO
# Version: 1.0.0
#####################################

MODDIR="${0%/*}"
CONFIG_DIR="$MODDIR/config"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Wait additional time for system stability
sleep 10

log_message "GamerX Performance Manager service starting..."

# Verify system app installation
if ! pm list packages | grep -q "com.gamerxeco.gamerx_performance_manager"; then
    echo "$(date): WARNING: GamerX Performance Manager not found in system" >> "$LOG_FILE"
    echo "$(date): Please ensure module was flashed correctly" >> "$LOG_FILE"
else
    echo "$(date): GamerX Performance Manager system app verified" >> "$LOG_FILE"
fi

# Apply default profile on boot
if [ -f "$CONFIG_DIR/current_profile" ]; then
    PROFILE=$(cat "$CONFIG_DIR/current_profile")
    log_message "Applying boot profile: $PROFILE"
    /system/bin/gamerx_perf_engine apply "$PROFILE"
else
    log_message "No profile found, applying balanced profile"
    /system/bin/gamerx_perf_engine apply "balanced"
fi

# Start thermal monitoring daemon
(
    while true; do
        TEMP=$(/system/bin/gamerx_perf_engine thermal)
        if [ "$TEMP" -gt 85000 ]; then  # 85°C threshold for logging
            log_message "High temperature detected: ${TEMP}°C"
        fi
        sleep 30
    done
) &

log_message "GamerX Performance Manager service started successfully"
