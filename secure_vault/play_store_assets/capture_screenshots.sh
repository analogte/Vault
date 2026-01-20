#!/bin/bash

# Automated screenshot capture for Play Store
# This script captures various screens from the running emulator

ADB=~/Library/Android/sdk/platform-tools/adb
SCREENSHOT_DIR="/Users/natthakornballa/project เก็บรูปไฟล์ นิรภัย/secure_vault/play_store_assets/screenshots"

echo "📸 Starting automated screenshot capture..."
echo ""

# Function to capture screenshot
capture_screen() {
    local name=$1
    local filename="${SCREENSHOT_DIR}/${name}.png"

    echo "Capturing: $name"
    $ADB shell screencap -p /sdcard/temp_screen.png
    $ADB pull /sdcard/temp_screen.png "$filename" > /dev/null 2>&1
    $ADB shell rm /sdcard/temp_screen.png

    # Resize to 1080x1920 (crop top/bottom status bars)
    if command -v convert &> /dev/null; then
        convert "$filename" -resize 1080x1920^ -gravity center -extent 1080x1920 "$filename"
        echo "✅ Saved and resized: $filename"
    else
        echo "✅ Saved: $filename (ImageMagick not installed, skipping resize)"
    fi

    sleep 1
}

# Function to tap screen at coordinates
tap() {
    local x=$1
    local y=$2
    echo "Tapping at ($x, $y)"
    $ADB shell input tap $x $y
    sleep 2
}

# Function to swipe
swipe() {
    local x1=$1
    local y1=$2
    local x2=$3
    local y2=$4
    echo "Swiping..."
    $ADB shell input swipe $x1 $y1 $x2 $y2 500
    sleep 1
}

# Function to press back
press_back() {
    echo "Pressing back..."
    $ADB shell input keyevent 4
    sleep 1
}

# Function to press home
press_home() {
    echo "Pressing home..."
    $ADB shell input keyevent 3
    sleep 1
}

echo "🎯 Instructions:"
echo "1. Make sure the emulator is running"
echo "2. Make sure Secure Vault app is open"
echo "3. Make sure you have at least one vault with some files"
echo ""
read -p "Ready? Press Enter to continue..."

# Screenshot 1: Current screen (usually Vault List or File Manager)
capture_screen "01-vault-list"

# Screenshot 2: Try to open menu/drawer
echo ""
echo "Opening menu..."
tap 100 150  # Top-left corner (hamburger menu)
capture_screen "02-menu-drawer"

# Back
press_back

# Screenshot 3: Try to open settings
echo ""
echo "Opening settings..."
tap 100 150  # Menu
sleep 1
tap 540 1500  # Settings option (approximate)
capture_screen "03-settings"

# Back
press_back
press_back

# Screenshot 4: Try to tap on a vault/file
echo ""
echo "Tapping first item..."
tap 540 600  # Center-ish area where first item might be
capture_screen "04-file-manager"

# Screenshot 5: Try to open file viewer
echo ""
echo "Tapping file..."
tap 540 600  # Tap first file
sleep 2
capture_screen "05-file-viewer"

# Back
press_back

# Screenshot 6: Try grid/list view toggle
echo ""
echo "Toggling view..."
tap 960 150  # Top-right area (view toggle)
capture_screen "06-grid-view"

echo ""
echo "✅ Screenshot capture complete!"
echo ""
echo "📁 Screenshots saved to: $SCREENSHOT_DIR"
echo ""
echo "Next steps:"
echo "1. Review screenshots and delete unwanted ones"
echo "2. Manually capture any missing screens"
echo "3. Ensure you have at least 2 high-quality screenshots"
echo ""
echo "To manually capture a screenshot:"
echo "$ADB shell screencap -p /sdcard/screenshot.png"
echo "$ADB pull /sdcard/screenshot.png ~/Desktop/screenshot.png"
