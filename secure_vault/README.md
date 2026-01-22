# Secure Vault

A privacy-focused mobile app for securely storing sensitive files and images with military-grade encryption. All data is encrypted locally on your device - nothing is ever sent to external servers.

## Features

### Security
- **AES-256-GCM Encryption** - Military-grade encryption for all files
- **Argon2id Key Derivation** - Modern, GPU-resistant key derivation (recommended)
- **PBKDF2 Support** - 100,000+ iterations for legacy vaults
- **Zero-Knowledge Architecture** - Your data never leaves your device
- **Biometric Authentication** - Face ID / Touch ID support
- **Auto-Lock** - Configurable automatic locking
- **Screenshot Prevention** - Blocks screenshots within the app
- **Clipboard Auto-Clear** - Automatically clears sensitive data from clipboard
- **Root/Jailbreak Detection** - Warns when running on compromised devices
- **Decoy Vault** - Create fake vaults with separate passwords

### File Management
- **Multiple Vaults** - Organize files into separate encrypted vaults
- **Folder Support** - Create folders within vaults
- **File Tagging** - Tag and categorize your files
- **Gallery View** - Beautiful masonry grid for images
- **Image Viewer** - Full-screen viewer with zoom support
- **Thumbnail Generation** - Encrypted thumbnails for quick browsing
- **Recently Opened** - Quick access to recent files
- **Trash/Recycle Bin** - Recover accidentally deleted files

### Backup & Sync
- **Local Backup** - Export encrypted backups
- **Backup Encryption** - Optional password protection for backups
- **Cross-Device Restore** - Restore backups on new devices

### User Experience
- **Multi-Language** - English, Thai, Japanese, Korean, Chinese, Indonesian
- **Dark Mode** - Full dark theme support
- **Responsive Design** - Works on phones and tablets

## Installation

### Requirements
- Flutter 3.32.0 or higher
- Dart 3.8.0 or higher
- iOS 12.0+ / Android 6.0+ (API 23+)

### Build from Source

```bash
# Clone the repository
git clone https://github.com/analogte/Vault.git
cd Vault/secure_vault

# Get dependencies
flutter pub get

# Run on device/simulator
flutter run

# Build release APK (Android)
flutter build apk --release

# Build release IPA (iOS)
flutter build ipa --release
```

## Security Architecture

### Encryption Flow
```
User Password
     |
     v
+-------------------------------------+
|  Key Derivation (Argon2id/PBKDF2)   |
|  - Salt: 32 bytes (random)          |
|  - Iterations: 100,000+ (PBKDF2)    |
|    or memory-hard (Argon2id)        |
+-------------------------------------+
     |
     v
  Derived Key (256-bit)
     |
     v
+-------------------------------------+
|  AES-256-GCM Encryption             |
|  - IV: 12 bytes (random per file)   |
|  - Tag: 16 bytes (authentication)   |
+-------------------------------------+
     |
     v
  Encrypted File + IV + Tag
```

### Security Features
- **Constant-time comparison** - Prevents timing attacks
- **Secure random generation** - Platform-native secure random
- **Memory wiping** - Sensitive data cleared from memory after use
- **Hardware Keystore** - Uses Android Keystore / iOS Keychain when available
- **Encrypted file names** - File names are also encrypted

## Tech Stack

- **Framework**: Flutter / Dart
- **Database**: SQLite (local only)
- **Encryption**: pointycastle (AES-GCM), hashlib (Argon2id)
- **Secure Storage**: flutter_secure_storage
- **State Management**: Provider
- **Localization**: Flutter Intl

## Project Structure

```
lib/
├── core/
│   ├── encryption/      # Crypto services, key management
│   ├── models/          # Data models
│   └── storage/         # Database helper
├── features/
│   ├── auth/           # PIN, biometric screens
│   ├── file_manager/   # File browsing, viewing
│   ├── settings/       # App settings, backup
│   └── vault/          # Vault management
├── services/           # Business logic services
├── l10n/               # Localization files
└── main.dart
```

## Privacy

- **100% Offline** - No internet connection required
- **No Analytics** - Zero tracking or telemetry
- **No Ads** - Ad-free experience
- **No Cloud** - Data stays on your device
- **Open Source** - Verify the code yourself

**Warning**: If you forget your vault password, your data cannot be recovered. Please keep your password safe and consider enabling biometric authentication as a backup.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with security in mind.
