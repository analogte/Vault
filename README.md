# Secure File & Image Vault

แอปพลิเคชันสำหรับเก็บไฟล์และรูปภาพที่เข้ารหัสแบบ client-side encryption

## คุณสมบัติ

- 🔒 **Client-side Encryption**: เข้ารหัสไฟล์ในเครื่องก่อนเก็บ
- 📱 **Cross-platform**: รองรับ iOS และ Android
- 🖼️ **Gallery View**: ดูรูปภาพในรูปแบบแกลเลอรี
- 🔐 **AES-256 Encryption**: ใช้มาตรฐานเข้ารหัสระดับสูง
- 🔑 **Password Protection**: ป้องกันด้วยรหัสผ่าน
- 📁 **File Management**: จัดการไฟล์ได้ง่าย

## เทคโนโลยี

- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **SQLite** - Local database
- **pointycastle** - Cryptography library
- **scrypt** - Key derivation

## การติดตั้ง

```bash
# Clone repository
git clone <repository-url>

# Install dependencies
flutter pub get

# Run app
flutter run
```

## การใช้งาน

1. สร้าง Vault ใหม่ด้วยรหัสผ่าน
2. อัปโหลดไฟล์หรือรูปภาพ
3. ไฟล์จะถูกเข้ารหัสอัตโนมัติ
4. ดูไฟล์ได้โดยการถอดรหัสด้วยรหัสผ่าน

## Privacy Policy

We don't collect, store, or transmit any of your data. Everything stays on your device.

- 📄 [Privacy Policy (English)](PRIVACY_POLICY.md)
- 📄 [นโยบายความเป็นส่วนตัว (ภาษาไทย)](PRIVACY_POLICY_TH.md)
- 🌐 [Privacy Policy (Web)](privacy_policy.html)

## License

MIT License - สามารถใช้เชิงพาณิชย์ได้โดยไม่ต้องเปิด source code

## Security

- AES-256-GCM encryption
- PBKDF2 key derivation (200,000 iterations)
- Secure random number generation
- No data sent to external servers
- Client-side encryption only
- Open source for transparency
