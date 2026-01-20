# Privacy Policy for Secure Vault

**Last updated: January 20, 2026**

## Introduction

Secure Vault ("we," "our," or "the app") is committed to protecting your privacy. This Privacy Policy explains how we handle your data when you use our mobile application.

**TL;DR: We don't collect, store, or transmit any of your data. Everything stays on your device.**

---

## Data Collection

**We collect ZERO data.**

Secure Vault is designed with privacy as the core principle:

- ✅ **No data collection** - We don't collect any personal information
- ✅ **No analytics** - We don't track your usage
- ✅ **No advertisements** - We don't show ads or use ad networks
- ✅ **No third-party services** - We don't use any external services
- ✅ **No cloud storage** - Your files never leave your device
- ✅ **No internet connection required** - The app works completely offline

---

## How Your Data is Stored

### Local Storage Only

All your data is stored locally on your device:

1. **Encrypted Files**: Your files and images are encrypted using AES-256-GCM encryption and stored in your device's local storage
2. **Vault Database**: Vault metadata is stored in a local SQLite database on your device
3. **Encryption Keys**: Derived from your password using PBKDF2 (200,000 iterations) and never stored anywhere

### Client-Side Encryption

- All encryption and decryption happen on your device
- Your password never leaves your device
- No encryption keys are stored - they are derived from your password each time you open a vault

---

## Data We Don't Collect

We explicitly do NOT collect:

- ❌ Personal information (name, email, phone number, etc.)
- ❌ Device information (device ID, OS version, etc.)
- ❌ Location data
- ❌ Usage analytics
- ❌ Crash reports
- ❌ File contents or metadata
- ❌ Passwords or encryption keys
- ❌ IP addresses
- ❌ Cookies or tracking data

---

## Permissions

The app requests the following permissions:

### Android
- **Storage Permission** - To read and write encrypted files to your device's storage
- **Camera Permission** (optional) - To take photos directly for encryption

### iOS
- **Photo Library Access** - To select photos/videos for encryption
- **Camera Access** (optional) - To take photos directly for encryption

**These permissions are used solely for the app's core functionality and do not transmit any data.**

---

## Data Security

Your data security is our top priority:

1. **AES-256-GCM Encryption** - Military-grade encryption for all files
2. **PBKDF2 Key Derivation** - 200,000 iterations for strong password protection
3. **File Name Encryption** - Even file names are encrypted
4. **No Backdoors** - We cannot access your files even if we wanted to
5. **Open Source** - You can verify our security claims by reviewing the source code

---

## Data Retention

Since all data is stored locally on your device:

- Data is retained as long as you keep the app installed
- You can delete individual files or entire vaults at any time
- Uninstalling the app will delete all data

**Important**: If you forget your vault password, we cannot help you recover your files. Make sure to remember your password!

---

## Children's Privacy

Secure Vault does not knowingly collect any information from anyone, including children under 13 years of age. Since we don't collect any data, the app is safe for users of all ages.

---

## Changes to This Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by:
- Updating the "Last updated" date at the top of this policy
- Posting the new policy in our GitHub repository
- (For significant changes) Notifying users within the app

---

## Third-Party Services

Secure Vault does NOT use any third-party services, including:

- ❌ Analytics services (Google Analytics, Firebase Analytics, etc.)
- ❌ Advertising networks
- ❌ Cloud storage providers
- ❌ Crash reporting services
- ❌ Authentication services

The app works completely offline and independently.

---

## Your Rights

Since we don't collect any data, there is no data to:
- Access
- Correct
- Delete
- Export
- Restrict processing of

All your data is already in your control on your device.

---

## Open Source

Secure Vault is open source under the MIT License. You can:
- Review the source code at: https://github.com/analogte/Vault
- Verify that we don't collect any data
- Build the app yourself from source
- Contribute to the project

---

## Contact Us

If you have any questions about this Privacy Policy, please contact us:

- **Email**: [Your Email]
- **GitHub Issues**: https://github.com/analogte/Vault/issues

---

## Legal

### Governing Law
This Privacy Policy is governed by the laws of Thailand.

### Disclaimer
Secure Vault is provided "as is" without any warranties. We are not responsible for:
- Lost data due to forgotten passwords
- Data loss due to device failure
- Any damages arising from the use of this app

**Remember**: Your encrypted files are only as secure as your password. Choose a strong password and keep it safe!

---

## Summary

**What we collect**: Nothing
**What we store**: Nothing (your data stays on your device)
**What we share**: Nothing
**What we sell**: Nothing

Your privacy is 100% protected because we simply don't have access to your data.

---

**Secure Vault - Your Files, Your Device, Your Privacy**

© 2026 Analog TE. All rights reserved.
