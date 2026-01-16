# วิธีรันแอป Secure Vault

## 🚀 วิธีรันแอป

### 1. รันบน macOS (Desktop)
```bash
cd secure_vault
flutter run -d macos
```
หรือ
```bash
flutter run -d macos
```

### 2. รันบน Chrome (Web)
```bash
cd secure_vault
flutter run -d chrome
```
หรือ
```bash
flutter run -d chrome
```

### 3. รันบน iOS Simulator (ถ้ามี)
```bash
# ดู iOS simulators ที่มี
flutter emulators

# เปิด iOS simulator
open -a Simulator

# รันแอป
flutter run -d ios
```

### 4. รันบน Android Emulator (ถ้ามี)
```bash
# ดู Android emulators ที่มี
flutter emulators

# เปิด Android emulator
flutter emulators --launch <emulator_id>

# รันแอป
flutter run -d android
```

### 5. รันบนอุปกรณ์จริง (iPhone/Android)
```bash
# เชื่อมต่ออุปกรณ์ผ่าน USB
# แล้วรัน
flutter run
```

## 📱 Devices ที่พร้อมใช้งานตอนนี้

จาก `flutter devices` พบ:
- ✅ **macOS (desktop)** - พร้อมใช้งาน
- ✅ **Chrome (web)** - พร้อมใช้งาน

## 🎯 วิธีที่แนะนำ

### สำหรับทดสอบ UI/UX เร็วๆ:
```bash
flutter run -d chrome
```
- รันเร็ว
- เหมาะสำหรับทดสอบ UI
- ไม่ต้อง compile native code

### สำหรับทดสอบเต็มรูปแบบ:
```bash
flutter run -d macos
```
- รันบน macOS desktop
- เหมาะสำหรับทดสอบ file system
- Performance ดีกว่า web

## ⚠️ หมายเหตุ

### สำหรับ iOS:
- ต้องมี Xcode ติดตั้ง
- ต้องมี iOS Simulator หรือ iPhone จริง

### สำหรับ Android:
- ต้องมี Android Studio ติดตั้ง
- ต้องมี Android Emulator หรือ Android device จริง

## 🔧 Troubleshooting

### ถ้าไม่มี devices:
```bash
# ตรวจสอบ Flutter setup
flutter doctor

# ดู emulators ที่มี
flutter emulators

# เปิด iOS Simulator
open -a Simulator

# เปิด Android Studio และสร้าง AVD
```

### ถ้า build ล้มเหลว:
```bash
# Clean build
flutter clean
flutter pub get

# Build ใหม่
flutter run
```
