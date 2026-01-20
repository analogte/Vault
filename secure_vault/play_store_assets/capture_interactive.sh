#!/bin/bash

# Interactive screenshot capture
# You navigate manually, script captures when you press Enter

ADB=~/Library/Android/sdk/platform-tools/adb
SCREENSHOT_DIR="/Users/natthakornballa/project เก็บรูปไฟล์ นิรภัย/secure_vault/play_store_assets/screenshots"
CONVERT_CMD="/opt/homebrew/bin/convert"

# Check if ImageMagick is available
if ! command -v convert &> /dev/null; then
    if [ -f "$CONVERT_CMD" ]; then
        alias convert="$CONVERT_CMD"
    fi
fi

mkdir -p "$SCREENSHOT_DIR"

echo "📸 Interactive Screenshot Capture Tool"
echo "======================================"
echo ""
echo "How this works:"
echo "1. Navigate to the screen you want to capture in the emulator"
echo "2. Press Enter when ready to capture"
echo "3. Repeat for all screens"
echo "4. Type 'done' when finished"
echo ""
echo "Screenshots will be saved to:"
echo "$SCREENSHOT_DIR"
echo ""

counter=1

while true; do
    echo ""
    echo "---"
    echo "Screenshot #$counter"
    echo ""
    echo "Screens you should capture:"
    echo "  1. Vault List (homepage)"
    echo "  2. File Manager (inside a vault)"
    echo "  3. Grid View (files in grid layout)"
    echo "  4. Settings screen"
    echo "  5. Create Vault screen"
    echo "  6. Image viewer (optional)"
    echo "  7. Dark mode (optional)"
    echo "  8. Any other feature screens"
    echo ""

    read -p "Navigate to the screen, then press Enter to capture (or type 'done' to finish): " input

    if [ "$input" = "done" ] || [ "$input" = "exit" ] || [ "$input" = "q" ]; then
        echo ""
        echo "✅ Finished capturing!"
        break
    fi

    # Ask for screen name
    read -p "Name for this screenshot (e.g., 'vault-list'): " screen_name

    if [ -z "$screen_name" ]; then
        screen_name="screenshot-$(printf "%02d" $counter)"
    fi

    filename="${SCREENSHOT_DIR}/${screen_name}.png"

    echo "📸 Capturing..."
    $ADB shell screencap -p /sdcard/temp_screen.png
    $ADB pull /sdcard/temp_screen.png "$filename" > /dev/null 2>&1
    $ADB shell rm /sdcard/temp_screen.png

    # Get original dimensions
    if command -v file &> /dev/null; then
        dimensions=$(file "$filename" | grep -oP '\d+ x \d+' | head -1)
        echo "   Original size: $dimensions"
    fi

    # Resize to 1080x1920 if ImageMagick is available
    if command -v convert &> /dev/null; then
        echo "   Resizing to 1080x1920..."
        convert "$filename" -resize 1080x1920^ -gravity center -extent 1080x1920 "$filename"
        echo "✅ Saved: $filename (1080x1920)"
    else
        echo "✅ Saved: $filename"
        echo "   (Install ImageMagick to auto-resize: brew install imagemagick)"
    fi

    counter=$((counter + 1))
done

echo ""
echo "📁 All screenshots saved to:"
echo "$SCREENSHOT_DIR"
echo ""
echo "Total captured: $((counter - 1)) screenshots"
echo ""

# List all screenshots
echo "Screenshots:"
ls -lh "$SCREENSHOT_DIR"/*.png 2>/dev/null || echo "No screenshots found"

echo ""
echo "Next: Review screenshots and upload to Google Play Console"
