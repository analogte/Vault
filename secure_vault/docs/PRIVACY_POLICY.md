# Privacy Policy

**Last updated: January 22, 2026**

## Overview

Secure Vault ("we", "our", or "the app") is designed with your privacy as the top priority. This privacy policy explains how we handle your data.

## Data Collection

### What We DON'T Collect
- **No personal information** - We don't collect names, emails, or any identifying information
- **No usage analytics** - We don't track how you use the app
- **No crash reports** - We don't automatically send crash data
- **No location data** - We don't access your location
- **No contacts** - We don't access your contact list
- **No advertising identifiers** - We don't use any ad tracking

### What Stays on Your Device
- **Your files** - All files are stored locally on your device
- **Your vault passwords** - Passwords are never stored; only derived keys are kept securely
- **Your settings** - App preferences are stored locally
- **Your biometric data** - Managed by your device's secure enclave, never by us

## Encryption

All your data is encrypted using:
- **AES-256-GCM** - Military-grade encryption standard
- **Argon2id / PBKDF2** - Secure key derivation from your password
- **Random IVs** - Each file uses a unique initialization vector

Your encryption keys are:
- Derived from your password
- Never transmitted anywhere
- Stored securely in your device's keychain/keystore

## Data Storage

- All data is stored **locally on your device only**
- No data is ever transmitted to external servers
- No cloud backup by default (optional local backup feature available)
- Deleting the app removes all stored data

## Permissions

The app may request the following permissions:

| Permission | Purpose | Required |
|------------|---------|----------|
| Storage/Photos | To import files into vaults | Yes |
| Biometrics | For Face ID / Touch ID unlock | No |
| Camera | For scanning documents (if enabled) | No |

## Third-Party Services

**We do not use any third-party services** that collect data, including:
- No analytics (Google Analytics, Firebase, etc.)
- No crash reporting (Crashlytics, Sentry, etc.)
- No advertising networks
- No social media SDKs

## Data Security

We implement multiple security measures:
- Client-side encryption (your data is encrypted before storage)
- Secure key storage using platform-native solutions
- Optional screenshot prevention
- Auto-lock functionality
- Clipboard auto-clear

## Children's Privacy

The app does not knowingly collect any data from children under 13 years of age. Since we don't collect any personal data from anyone, this includes children.

## Your Rights

Since all data stays on your device:
- **Access**: You have full access to all your data
- **Deletion**: Delete vaults or uninstall the app to remove all data
- **Portability**: Use the backup feature to export your data

## Important Warning

**If you forget your vault password, we cannot help you recover your data.** This is by design - we never have access to your passwords or decryption keys.

Please:
- Keep your passwords secure
- Consider enabling biometric authentication
- Regularly backup your important data

## Changes to This Policy

We may update this privacy policy from time to time. Any changes will be posted in this document with an updated revision date.

## Contact

If you have questions about this privacy policy:
- Open an issue on [GitHub](https://github.com/analogte/Vault/issues)

## Summary

**Your privacy is absolute with Secure Vault:**
- We collect nothing
- We track nothing
- We send nothing
- Your data never leaves your device

---

This privacy policy is effective as of January 22, 2026.
