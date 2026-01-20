#!/usr/bin/env python3
"""
Generate Feature Graphic for Google Play Store
Size: 1024 x 500 pixels
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Configuration
WIDTH = 1024
HEIGHT = 500
OUTPUT_FILE = "feature-graphic.png"

# Colors
GRADIENT_START = (21, 101, 192)    # #1565C0
GRADIENT_END = (66, 165, 245)       # #42A5F5
WHITE = (255, 255, 255)
WHITE_TRANSPARENT = (255, 255, 255, 200)

def create_gradient(draw, width, height, start_color, end_color):
    """Create vertical gradient background"""
    for y in range(height):
        # Calculate color for this line
        ratio = y / height
        r = int(start_color[0] + (end_color[0] - start_color[0]) * ratio)
        g = int(start_color[1] + (end_color[1] - start_color[1]) * ratio)
        b = int(start_color[2] + (end_color[2] - start_color[2]) * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

def main():
    # Create image
    img = Image.new('RGB', (WIDTH, HEIGHT))
    draw = ImageDraw.Draw(img)

    # Draw gradient background
    create_gradient(draw, WIDTH, HEIGHT, GRADIENT_START, GRADIENT_END)

    # Try to load fonts (fallback to default if not available)
    try:
        # macOS fonts
        title_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 80)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 40)
        emoji_font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", 120)
    except:
        try:
            # Alternative fonts
            title_font = ImageFont.truetype("/Library/Fonts/Arial Bold.ttf", 80)
            subtitle_font = ImageFont.truetype("/Library/Fonts/Arial.ttf", 40)
            emoji_font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", 120)
        except:
            print("Warning: Custom fonts not found, using default")
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
            emoji_font = ImageFont.load_default()

    # Draw lock icon (left side)
    lock_emoji = "🔒"
    lock_x = 180
    lock_y = 180

    # Draw semi-transparent circle behind lock
    circle_radius = 90
    draw.ellipse(
        [lock_x - circle_radius, lock_y - circle_radius,
         lock_x + circle_radius, lock_y + circle_radius],
        fill=(255, 255, 255, 30)
    )

    # Draw lock emoji
    try:
        bbox = draw.textbbox((lock_x, lock_y), lock_emoji, font=emoji_font, anchor="mm")
        draw.text((lock_x, lock_y), lock_emoji, font=emoji_font, anchor="mm")
    except:
        # Fallback: draw lock icon as text
        draw.text((lock_x - 40, lock_y - 60), "LOCK", fill=WHITE, font=title_font)

    # Draw title
    title_text = "SECURE VAULT"
    title_x = 580
    title_y = 180
    draw.text((title_x, title_y), title_text, fill=WHITE, font=title_font, anchor="lm")

    # Draw subtitle
    subtitle_text = "Military-Grade File Encryption"
    subtitle_x = 580
    subtitle_y = 280
    draw.text((subtitle_x, subtitle_y), subtitle_text, fill=WHITE_TRANSPARENT, font=subtitle_font, anchor="lm")

    # Draw feature badges (bottom right)
    badge_font = ImageFont.load_default()
    try:
        badge_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 24)
    except:
        pass

    badges = ["✓ AES-256", "✓ Zero Knowledge", "✓ Open Source"]
    badge_x = 580
    badge_y = 350

    for i, badge in enumerate(badges):
        draw.text((badge_x + (i * 170), badge_y), badge, fill=WHITE, font=badge_font)

    # Save image
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, OUTPUT_FILE)
    img.save(output_path, 'PNG', quality=95)
    print(f"✅ Feature graphic created: {output_path}")
    print(f"   Size: {WIDTH}x{HEIGHT}px")
    print(f"   Ready for Google Play Console!")

    return output_path

if __name__ == "__main__":
    main()
