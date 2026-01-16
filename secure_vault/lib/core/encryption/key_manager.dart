import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'crypto_service.dart';

/// Manages encryption keys for vaults
class KeyManager {
  /// Derive master key from password and salt
  static Uint8List deriveMasterKey(String password, Uint8List salt) {
    // Use PBKDF2 with iteration count
    // Reduced for web performance (20000 for web, 200000 for production mobile)
    // In production, consider using scrypt for better security
    return CryptoService.deriveKey(password, salt, iterations: 20000);
  }

  /// Encrypt master key with password-derived key
  static Uint8List encryptMasterKey(Uint8List masterKey, String password, Uint8List salt) {
    final key = deriveMasterKey(password, salt);
    final encrypted = CryptoService.encryptData(masterKey, key);
    return encrypted.toBytes();
  }

  /// Decrypt master key with password
  static Uint8List decryptMasterKey(Uint8List encryptedMasterKey, String password, Uint8List salt) {
    final key = deriveMasterKey(password, salt);
    final encryptedData = EncryptedData.fromBytes(encryptedMasterKey);
    return CryptoService.decryptData(encryptedData, key);
  }

  /// Generate a new random master key
  static Uint8List generateMasterKey() {
    return CryptoService.generateSalt(CryptoService.keyLength);
  }

  /// Verify password by attempting to decrypt master key
  static bool verifyPassword(String password, Uint8List encryptedMasterKey, Uint8List salt) {
    try {
      decryptMasterKey(encryptedMasterKey, password, salt);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Hash password for storage (not used for encryption, just for verification)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
