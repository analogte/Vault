import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'secure_crypto_service.dart';
import 'argon2_service.dart';
import '../utils/logger.dart';

/// Manages encryption keys for vaults
/// Supports both PBKDF2 (legacy) and Argon2id (preferred)
class KeyManager {
  static const String _tag = 'KeyManager';

  // KDF version constants
  static const String kdfPbkdf2 = 'pbkdf2';
  static const String kdfArgon2id = 'argon2id';

  /// Derive master key from password and salt using specified KDF
  /// kdfVersion: 'pbkdf2' or 'argon2id'
  static Future<Uint8List> deriveMasterKey(
    String password,
    Uint8List salt, {
    String kdfVersion = kdfArgon2id,
  }) {
    if (kdfVersion == kdfArgon2id) {
      AppLogger.log('Using Argon2id for key derivation', tag: _tag);
      return Argon2Service.deriveKey(password, salt);
    } else {
      AppLogger.log('Using PBKDF2 for key derivation', tag: _tag);
      return SecureCryptoService.deriveKey(password, salt);
    }
  }

  /// Encrypt master key with password-derived key
  /// New vaults should use Argon2id
  static Future<Uint8List> encryptMasterKey(
    Uint8List masterKey,
    String password,
    Uint8List salt, {
    String kdfVersion = kdfArgon2id,
  }) {
    if (kdfVersion == kdfArgon2id) {
      return Argon2Service.encryptMasterKey(masterKey, password, salt);
    } else {
      return SecureCryptoService.encryptMasterKey(masterKey, password, salt);
    }
  }

  /// Decrypt master key with password
  /// Automatically uses correct KDF based on version
  static Future<Uint8List> decryptMasterKey(
    Uint8List encryptedMasterKey,
    String password,
    Uint8List salt, {
    String kdfVersion = kdfPbkdf2,
  }) {
    if (kdfVersion == kdfArgon2id) {
      return Argon2Service.decryptMasterKey(
        encryptedMasterKey,
        password,
        salt,
      );
    } else {
      return SecureCryptoService.decryptMasterKey(
        encryptedMasterKey,
        password,
        salt,
      );
    }
  }

  /// Generate a new random master key
  static Uint8List generateMasterKey() {
    return SecureCryptoService.generateMasterKey();
  }

  /// Generate a new random salt
  static Uint8List generateSalt() {
    return SecureCryptoService.generateSalt();
  }

  /// Verify password by attempting to decrypt master key
  static Future<bool> verifyPassword(
    String password,
    Uint8List encryptedMasterKey,
    Uint8List salt, {
    String kdfVersion = kdfPbkdf2,
  }) async {
    try {
      await decryptMasterKey(
        encryptedMasterKey,
        password,
        salt,
        kdfVersion: kdfVersion,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Hash password for storage (not used for encryption, just for quick verification)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Migrate vault from PBKDF2 to Argon2id
  /// Returns migration result with new encrypted key and salt
  static Future<MigrationResult> migrateToArgon2id(
    String password,
    Uint8List encryptedMasterKey,
    Uint8List salt,
  ) async {
    AppLogger.log('Starting KDF migration to Argon2id', tag: _tag);

    // Decrypt with old PBKDF2
    final masterKey = await SecureCryptoService.decryptMasterKey(
      encryptedMasterKey,
      password,
      salt,
    );

    // Generate new salt for Argon2id
    final newSalt = generateSalt();

    // Re-encrypt with Argon2id
    final newEncryptedMasterKey = await Argon2Service.encryptMasterKey(
      masterKey,
      password,
      newSalt,
    );

    AppLogger.log('KDF migration complete', tag: _tag);

    return MigrationResult(
      encryptedMasterKey: newEncryptedMasterKey,
      salt: newSalt,
      kdfVersion: kdfArgon2id,
    );
  }

  /// Check if vault should be migrated to Argon2id
  static bool shouldMigrate(String? kdfVersion) {
    return kdfVersion == null || kdfVersion == kdfPbkdf2;
  }

  /// Get recommended KDF for new vaults
  static String get recommendedKdf => kdfArgon2id;
}

/// Result of KDF migration
class MigrationResult {
  final Uint8List encryptedMasterKey;
  final Uint8List salt;
  final String kdfVersion;

  MigrationResult({
    required this.encryptedMasterKey,
    required this.salt,
    required this.kdfVersion,
  });
}
