#!/usr/bin/env bash
set -e

REDMI_IP="${1:-192.168.1.50}"
PORT="${2:-5555}"
APK_PATH="${3:-build/deploy/maya-redmi-arm64-release.apk}"

echo "===================================================="
echo "🚀 Maya Xiaomi Redmi Wireless Deployer"
echo "Target Phone IP: ${REDMI_IP}:${PORT}"
echo "===================================================="

# 1. Connect via ADB Wi-Fi
echo "[1/5] Connecting to Xiaomi Redmi device over Wi-Fi..."
adb connect "${REDMI_IP}:${PORT}"

# Verify Connection
adb devices | grep "${REDMI_IP}"

# 2. Install / Upgrade APK
echo "[2/5] Installing Maya APK on Redmi phone..."
adb -s "${REDMI_IP}:${PORT}" install -r -g "${APK_PATH}"

# 3. Grant Essential System Permissions via ADB
echo "[3/5] Granting System & Background Permissions..."
adb -s "${REDMI_IP}:${PORT}" shell pm grant com.maya.app android.permission.RECORD_AUDIO
adb -s "${REDMI_IP}:${PORT}" shell pm grant com.maya.app android.permission.ACCESS_FINE_LOCATION
adb -s "${REDMI_IP}:${PORT}" shell pm grant com.maya.app android.permission.ACCESS_BACKGROUND_LOCATION
adb -s "${REDMI_IP}:${PORT}" shell pm grant com.maya.app android.permission.READ_SMS
adb -s "${REDMI_IP}:${PORT}" shell pm grant com.maya.app android.permission.RECEIVE_SMS
adb -s "${REDMI_IP}:${PORT}" shell pm grant com.maya.app android.permission.CALL_PHONE

# 4. Bypass Battery Optimizations via ADB Command
echo "[4/5] Disabling Battery Optimizations..."
adb -s "${REDMI_IP}:${PORT}" shell dumpsys deviceidle whitelist +com.maya.app

# 5. Start Persistent Background Service & Setup Activity
echo "[5/5] Launching Maya Setup & Service..."
adb -s "${REDMI_IP}:${PORT}" shell am start -n com.maya.app/.MainActivity
adb -s "${REDMI_IP}:${PORT}" shell am startforegroundservice -n com.maya.app/.MayaAlwaysOnService

echo "===================================================="
echo "✅ Maya successfully deployed and active on Redmi!"
echo "===================================================="