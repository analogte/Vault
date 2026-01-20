# Feature Graphic Guide for Google Play Store

## Requirements
- **Size:** 1024 x 500 pixels (exact)
- **Format:** PNG or JPEG (24-bit, no alpha)
- **File Size:** Max 1MB
- **Purpose:** Banner at the top of your Play Store listing

---

## Design Guidelines

### Visual Elements
1. **App Name:** "Secure Vault" (prominent)
2. **Key Visuals:** Lock icon, shield, encrypted files
3. **Tagline:** Short phrase describing the app
4. **Background:** Clean gradient or solid color
5. **No text cutoff:** Important text should be centered

### Color Scheme
- Primary: Blue (#1565C0)
- Accent: Light Blue (#42A5F5)
- Security Theme: Dark blue, white, silver
- Avoid: Red (warning), Yellow (caution)

### Typography
- **App Name:** Bold, 48-72pt
- **Tagline:** Regular, 24-36pt
- **Fonts:** Sans-serif (Roboto, Inter, Poppins)

---

## Design Options

### Option 1: Minimal Lock Icon
```
+----------------------------------------------------------+
|                                                          |
|      🔒                                                  |
|                                                          |
|        SECURE VAULT                                      |
|        Military-Grade File Encryption                    |
|                                                          |
+----------------------------------------------------------+
```

**Elements:**
- Large lock icon on left
- App name in center
- Tagline below
- Gradient blue background

---

### Option 2: File Protection Visual
```
+----------------------------------------------------------+
|                                                          |
|  📁 [Encrypted]     SECURE VAULT                        |
|  📷 [Encrypted]     Your Files. Fully Protected.        |
|  📄 [Encrypted]                                          |
|                                                          |
+----------------------------------------------------------+
```

**Elements:**
- File icons with "encrypted" badge
- Shield overlay
- App name and tagline on right

---

### Option 3: Device Mockup
```
+----------------------------------------------------------+
|                                                          |
|    [Phone Screen]      SECURE VAULT                     |
|    showing vault       Zero-Knowledge Encryption         |
|    interface                                             |
|                                                          |
+----------------------------------------------------------+
```

**Elements:**
- Phone mockup showing app UI
- App name on right
- Key features as bullets

---

## Quick Design Tools

### 1. **Canva** (Recommended - Easiest)
1. Go to https://www.canva.com
2. Create custom size: 1024 x 500px
3. Search templates: "app banner" or "mobile app"
4. Customize with:
   - Text: "Secure Vault"
   - Tagline: "Military-Grade File Encryption"
   - Lock icon from Canva library
   - Blue gradient background
5. Download as PNG

**Template Ideas:**
- Search "mobile security banner"
- Search "app store banner"
- Search "lock icon banner"

---

### 2. **Figma** (Professional)
1. Create frame 1024x500px
2. Add background (gradient blue)
3. Add lock icon (from Icons8 or Figma plugins)
4. Add text:
   - Title: "Secure Vault" (64pt, bold)
   - Subtitle: "Your Files. Fully Protected." (32pt)
5. Export as PNG @1x

**Resources:**
- Icons: Iconify plugin (free)
- Gradients: https://uigradients.com/
- Colors: Use #1565C0 → #42A5F5

---

### 3. **Online Generators**
- https://www.fotor.com/ (Banner maker)
- https://www.crello.com/ (Free templates)
- https://www.visme.co/ (Professional designs)

---

## Template Text Suggestions

### Taglines (Pick One)
1. "Your Files. Fully Protected."
2. "Military-Grade File Encryption"
3. "Zero-Knowledge Privacy"
4. "Bank-Level Security for Your Files"
5. "End-to-End Encrypted Vault"
6. "Privacy First. Always."
7. "Lock it. Encrypt it. Secure it."
8. "Your Digital Safe"

### Key Features (Optional Small Text)
- ✓ AES-256 Encryption
- ✓ Biometric Lock
- ✓ Zero Knowledge
- ✓ Offline First

---

## Simple DIY Method

### Using PowerPoint/Keynote
1. New slide → Custom size 1024x500px
2. Add gradient background (blue)
3. Insert lock icon (from free icon sites)
4. Add text boxes:
   ```
   SECURE VAULT
   Military-Grade File Encryption
   ```
5. Export as PNG (high quality)

### Free Icon Resources
- https://icons8.com/ (Search "lock", "shield")
- https://www.flaticon.com/
- https://iconmonstr.com/
- https://phosphoricons.com/

---

## Example Layout Code (HTML/CSS)

```html
<div style="
  width: 1024px;
  height: 500px;
  background: linear-gradient(135deg, #1565C0 0%, #42A5F5 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Roboto', sans-serif;
  color: white;
  text-align: center;
">
  <div>
    <div style="font-size: 48px; margin-bottom: 20px;">🔒</div>
    <h1 style="font-size: 64px; font-weight: bold; margin: 0;">SECURE VAULT</h1>
    <p style="font-size: 32px; margin-top: 10px;">Military-Grade File Encryption</p>
  </div>
</div>
```

Save as HTML → Open in browser → Screenshot → Crop to 1024x500px

---

## What to Avoid

❌ **Don't:**
- Use real user data/photos
- Include screenshots (too small)
- Use too much text (unreadable)
- Use trademarked icons (Google Drive, etc.)
- Cut off text at edges
- Use low-resolution images
- Include "Download" or "Free" badges

✅ **Do:**
- Keep it simple and clean
- Use high-contrast colors
- Make app name prominent
- Use professional icons
- Test on mobile to see if readable

---

## Pre-made Template (Ready to Customize)

ผมสร้าง SVG template ให้ด้านล่าง สามารถแก้ไขใน:
- https://www.figma.com (Import SVG)
- Inkscape (Free)
- Adobe Illustrator

```svg
<svg width="1024" height="500" xmlns="http://www.w3.org/2000/svg">
  <!-- Background Gradient -->
  <defs>
    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#1565C0;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#42A5F5;stop-opacity:1" />
    </linearGradient>
  </defs>

  <rect width="1024" height="500" fill="url(#gradient)"/>

  <!-- Lock Icon -->
  <circle cx="256" cy="250" r="80" fill="white" opacity="0.2"/>
  <text x="256" y="280" font-size="120" text-anchor="middle" fill="white">🔒</text>

  <!-- App Name -->
  <text x="600" y="220" font-size="72" font-weight="bold" fill="white" font-family="Arial">SECURE VAULT</text>

  <!-- Tagline -->
  <text x="600" y="280" font-size="36" fill="white" opacity="0.9" font-family="Arial">Military-Grade File Encryption</text>
</svg>
```

Save as `feature-graphic.svg` → Export as PNG 1024x500px

---

## Validation Checklist

Before uploading to Play Store:
- [ ] Size is exactly 1024 x 500px
- [ ] File format is PNG or JPEG
- [ ] File size < 1MB
- [ ] No transparency (if JPEG)
- [ ] Text is readable at small size
- [ ] No spelling errors
- [ ] Follows brand guidelines
- [ ] Looks good on mobile preview

---

## Need Help?

ถ้าต้องการให้ผมสร้าง Feature Graphic ให้ บอกผมได้เลยครับ! ผมจะใช้ Python + Pillow สร้างให้อัตโนมัติ

หรือถ้ามี design ที่ชอบ ส่งรูปตัวอย่างมาให้ดูได้ครับ!
