# Privacy Policy for Secure Vault

**Last Updated:** January 18, 2026

## Introduction

Secure Vault ("we," "our," or "the app") is committed to protecting your privacy. This Privacy Policy explains how we handle your data when you use our mobile application.

## Data Collection and Storage

### Local-Only Storage
**Secure Vault operates entirely on your device.** We do NOT collect, transmit, or store any of your personal data on our servers. All your files, photos, videos, and documents are:
- Encrypted using AES-256-GCM encryption
- Stored locally on your device only
- Never uploaded to any external servers (unless you explicitly use cloud backup features)

### Data We DO NOT Collect
- Personal information (name, email, phone number)
- File contents or metadata
- Usage analytics or statistics
- Device information or identifiers
- Location data
- Any other personally identifiable information

## Features and Data Handling

### 1. File Encryption
- All files are encrypted with industry-standard AES-256-GCM encryption
- Your master password/PIN is never stored in plain text
- Encryption keys are derived using Argon2id key derivation function
- All encryption happens locally on your device

### 2. Biometric Authentication (Optional)
- If you enable fingerprint/face unlock, biometric data is handled by your device's operating system
- We do not access or store your biometric data
- Biometric authentication is managed by Android/iOS secure APIs

### 3. Cloud Backup (Optional)
- If you choose to enable Google Drive backup, you control what data is uploaded
- Backup files remain encrypted before upload
- We use Google Sign-In for authentication (handled by Google)
- Your Google account credentials are managed by Google, not by us
- You can disable cloud backup at any time

### 4. Camera and Photo Access
- When you take photos/videos or import files, we request camera/storage permissions
- These permissions are used solely to access files you choose to encrypt
- We do not access any files without your explicit action

## Third-Party Services

### Google Sign-In (Optional)
- Used only if you enable Google Drive backup
- Handled entirely by Google's authentication system
- We receive only basic profile information needed for authentication
- Google's Privacy Policy applies: https://policies.google.com/privacy

### Google Drive API (Optional)
- Used only if you enable cloud backup
- Backup files are stored in your personal Google Drive
- We do not access any other files in your Google Drive
- You can revoke access at any time through Google Account settings

## Data Security

We implement multiple security measures:
- AES-256-GCM encryption for all stored files
- Argon2id for secure password hashing
- Screenshot prevention when viewing sensitive content
- App integrity checks to detect tampering
- Root/jailbreak detection
- Secure key storage using platform-specific secure storage

## Children's Privacy

Secure Vault does not knowingly collect any data from children under 13. Our app is not directed at children, and we do not knowingly collect personal information from anyone under 13.

## Your Rights

Since all data is stored locally on your device, you have complete control:
- **Access**: All your data is stored on your device
- **Delete**: Uninstalling the app removes all encrypted data
- **Control**: You can delete individual files or entire vaults at any time
- **Export**: You can export files from the app whenever you want

## Changes to Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by:
- Updating the "Last Updated" date
- Posting the new Privacy Policy in the app
- Notifying you through app updates

## Contact Us

If you have questions about this Privacy Policy, please contact us:
- **Email**: contact@securevault.app
- **GitHub**: https://github.com/analogte/Vault

## Open Source

Secure Vault is open source. You can review our code at:
https://github.com/analogte/Vault

## Consent

By using Secure Vault, you agree to this Privacy Policy. If you do not agree, please do not use the app.

---

**Summary:**
- ✅ No data collection or tracking
- ✅ Everything stored locally on your device
- ✅ End-to-end encryption
- ✅ Optional cloud backup (you control)
- ✅ No ads or third-party analytics
- ✅ Open source and transparent
