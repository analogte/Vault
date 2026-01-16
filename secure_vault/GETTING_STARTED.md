# คู่มือการเริ่มต้นใช้งาน Secure Vault

## สิ่งที่สร้างเสร็จแล้ว

### ✅ Core Features
1. **ระบบเข้ารหัส (Encryption)**
   - AES-256-GCM encryption
   - PBKDF2 key derivation
   - File name encryption
   - Secure random number generation

2. **Vault Management**
   - สร้าง Vault ใหม่
   - เปิด Vault ด้วยรหัสผ่าน
   - ลบ Vault
   - เปลี่ยนรหัสผ่าน (พร้อมใช้งาน)

3. **File Management**
   - อัปโหลดไฟล์/รูปภาพ
   - ดูไฟล์ทั้งหมด
   - แกลเลอรีรูปภาพ
   - ลบไฟล์
   - Thumbnail generation

4. **Database**
   - SQLite database
   - Vault metadata storage
   - File metadata storage
   - Thumbnail storage

### ✅ UI/UX
- Material Design 3
- Dark mode support
- Responsive layout
- Gallery view with masonry grid
- Image viewer with zoom

## การรันแอป

### 1. ติดตั้ง Dependencies
```bash
cd secure_vault
flutter pub get
```

### 2. รันแอป
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# หรือเลือก device
flutter devices
flutter run -d <device-id>
```

## โครงสร้างโปรเจกต์

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── encryption/
│   │   ├── crypto_service.dart       # Encryption/Decryption
│   │   └── key_manager.dart          # Key management
│   ├── models/
│   │   ├── vault.dart                # Vault model
│   │   └── encrypted_file.dart       # File model
│   └── storage/
│       └── database_helper.dart      # SQLite helper
├── services/
│   ├── vault_service.dart            # Vault operations
│   └── file_service.dart             # File operations
├── features/
│   ├── vault/
│   │   └── screens/
│   │       ├── vault_list_screen.dart
│   │       ├── create_vault_screen.dart
│   │       └── open_vault_screen.dart
│   └── file_manager/
│       ├── screens/
│       │   └── file_manager_screen.dart
│       └── widgets/
│           ├── file_list_widget.dart
│           ├── gallery_view_widget.dart
│           └── image_viewer_dialog.dart
└── utils/
    └── file_utils.dart                # Utility functions
```

## Security Features

### Encryption
- **Algorithm**: AES-256-GCM
- **Key Size**: 256 bits
- **IV**: Random 96-bit per file
- **Authentication**: GCM tag

### Key Derivation
- **Function**: PBKDF2
- **Iterations**: 200,000
- **Salt**: Random 256-bit per vault

### Best Practices
- ✅ Never store passwords in plaintext
- ✅ Secure random number generation
- ✅ Constant-time comparison
- ✅ File name encryption
- ✅ Directory structure obfuscation

## การใช้งาน

### 1. สร้าง Vault
1. เปิดแอป
2. กดปุ่ม "สร้าง Vault"
3. ใส่ชื่อ Vault
4. ตั้งรหัสผ่าน (อย่างน้อย 8 ตัวอักษร)
5. ยืนยันรหัสผ่าน

### 2. เปิด Vault
1. เลือก Vault จากรายการ
2. กรอกรหัสผ่าน
3. กด "เปิด Vault"

### 3. อัปโหลดไฟล์
1. เปิด Vault
2. กดปุ่ม + (เลือกรูปภาพ) หรือ 📎 (เลือกไฟล์)
3. เลือกไฟล์ที่ต้องการ
4. ไฟล์จะถูกเข้ารหัสอัตโนมัติ

### 4. ดูไฟล์
- **Tab "ไฟล์ทั้งหมด"**: ดูไฟล์ทั้งหมดในรูปแบบรายการ
- **Tab "แกลเลอรี"**: ดูรูปภาพในรูปแบบแกลเลอรี

### 5. ลบไฟล์
1. กดที่ไฟล์
2. เลือก "ลบ" จากเมนู
3. ยืนยันการลบ

## ข้อควรระวัง

⚠️ **สำคัญ**: หากลืมรหัสผ่าน จะไม่สามารถกู้คืนไฟล์ได้
- ระบบใช้ client-side encryption
- ไม่มี backdoor หรือ recovery mechanism
- เก็บรหัสผ่านให้ปลอดภัย

## การพัฒนาต่อยอด

### Features ที่สามารถเพิ่มได้
1. **Biometric Authentication**
   - ใช้ local_auth package ที่ติดตั้งแล้ว
   - Face ID / Touch ID / Fingerprint

2. **Cloud Sync**
   - Google Drive
   - iCloud
   - Dropbox

3. **File Sharing**
   - แชร์ไฟล์ที่เข้ารหัส
   - Temporary download links

4. **Search**
   - ค้นหาไฟล์ด้วยชื่อ
   - Filter by file type

5. **File Preview**
   - PDF viewer
   - Video player
   - Text viewer

6. **Backup/Restore**
   - Export vault
   - Import vault

### การปรับปรุง Security
1. **ใช้ scrypt แทน PBKDF2**
   - ติดตั้ง package: `scrypt`
   - ปรับ key derivation ใน `key_manager.dart`

2. **เพิ่ม Key Stretching**
   - เพิ่ม iterations
   - ใช้ Argon2

3. **Secure Deletion**
   - Overwrite files before deletion
   - Multiple passes

## License

MIT License - สามารถใช้เชิงพาณิชย์ได้โดยไม่ต้องเปิด source code

## Support

หากมีปัญหาหรือคำถาม:
1. ตรวจสอบ logs ใน console
2. ตรวจสอบ permissions ของแอป
3. ตรวจสอบ storage space

## Notes

- โค้ดทั้งหมดเขียนใหม่ ไม่ได้ใช้โค้ดจาก Cryptomator โดยตรง
- ใช้แนวคิดจาก Cryptomator แต่ implementation เป็นของเราเอง
- สามารถขายใน App Store / Play Store ได้โดยไม่ต้องเปิด source code
