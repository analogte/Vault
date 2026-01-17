import 'dart:typed_data';
import 'package:flutter/foundation.dart' show compute;
import 'package:hashlib/hashlib.dart';
import '../utils/logger.dart';
import 'secure_crypto_service.dart';

/// Argon2id Key Derivation Service
/// Provides stronger key derivation than PBKDF2
/// Resistant to GPU/ASIC attacks due to memory-hard design
class Argon2Service {
  static const String _tag = 'Argon2Service';

  // Argon2id parameters
  // These are tuned for mobile devices balance of security and performance
  static const int memoryKB = 32768; // 32 MB (reduced for mobile performance)
  static const int iterations = 3;
  static const int parallelism = 2;
  static const int saltLength = 32;
  static const int hashLength = 32;

  // KDF version identifiers
  static const String kdfVersionPbkdf2 = 'pbkdf2';
  static const String kdfVersionArgon2id = 'argon2id';

  /// Derive key from password using Argon2id
  /// Memory-hard function resistant to brute force attacks
  static Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    AppLogger.log('Deriving key with Argon2id...', tag: _tag);

    // Run in isolate to prevent UI blocking
    final result = await compute(_deriveKeyIsolate, _Argon2Params(
      password: password,
      salt: salt,
      memory: memoryKB,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: hashLength,
    ));

    AppLogger.log('Key derived successfully', tag: _tag);
    return result;
  }

  /// Quick key derivation for testing (reduced parameters)
  /// NOT for production use
  static Future<Uint8List> deriveKeyFast(String password, Uint8List salt) async {
    final result = await compute(_deriveKeyIsolate, _Argon2Params(
      password: password,
      salt: salt,
      memory: 4096, // 4 MB
      iterations: 1,
      parallelism: 2,
      hashLength: hashLength,
    ));
    return result;
  }

  /// Encrypt master key using Argon2id-derived key
  static Future<Uint8List> encryptMasterKey(
    Uint8List masterKey,
    String password,
    Uint8List salt,
  ) async {
    final derivedKey = await deriveKey(password, salt);
    return SecureCryptoService.encrypt(masterKey, derivedKey);
  }

  /// Decrypt master key using Argon2id-derived key
  static Future<Uint8List> decryptMasterKey(
    Uint8List encryptedMasterKey,
    String password,
    Uint8List salt,
  ) async {
    final derivedKey = await deriveKey(password, salt);
    return SecureCryptoService.decrypt(encryptedMasterKey, derivedKey);
  }

  /// Verify password by attempting to decrypt
  static Future<bool> verifyPassword(
    String password,
    Uint8List encryptedMasterKey,
    Uint8List salt,
  ) async {
    try {
      await decryptMasterKey(encryptedMasterKey, password, salt);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate secure random salt
  static Uint8List generateSalt() {
    return SecureCryptoService.generateSalt();
  }

  /// Get KDF version string for storage
  static String get kdfVersion => kdfVersionArgon2id;

  /// Check if KDF version is Argon2id
  static bool isArgon2id(String? version) {
    return version == kdfVersionArgon2id;
  }

  /// Check if KDF version is PBKDF2
  static bool isPbkdf2(String? version) {
    return version == null || version == kdfVersionPbkdf2;
  }

  /// Migrate vault from PBKDF2 to Argon2id
  /// Returns new encrypted master key and salt
  static Future<MigrationResult> migrateFromPbkdf2(
    String password,
    Uint8List oldEncryptedMasterKey,
    Uint8List oldSalt,
  ) async {
    AppLogger.log('Starting PBKDF2 to Argon2id migration...', tag: _tag);

    // Decrypt master key with old PBKDF2 derivation
    final masterKey = await SecureCryptoService.decryptMasterKey(
      oldEncryptedMasterKey,
      password,
      oldSalt,
    );

    // Generate new salt for Argon2id
    final newSalt = generateSalt();

    // Re-encrypt with Argon2id
    final newEncryptedMasterKey = await encryptMasterKey(
      masterKey,
      password,
      newSalt,
    );

    AppLogger.log('Migration complete', tag: _tag);

    return MigrationResult(
      encryptedMasterKey: newEncryptedMasterKey,
      salt: newSalt,
      kdfVersion: kdfVersionArgon2id,
    );
  }
}

/// Parameters for Argon2id key derivation
class _Argon2Params {
  final String password;
  final Uint8List salt;
  final int memory;
  final int iterations;
  final int parallelism;
  final int hashLength;

  _Argon2Params({
    required this.password,
    required this.salt,
    required this.memory,
    required this.iterations,
    required this.parallelism,
    required this.hashLength,
  });
}

/// Key derivation function to run in isolate
Uint8List _deriveKeyIsolate(_Argon2Params params) {
  // Use hashlib's Argon2 class with argon2id type
  final argon2 = Argon2(
    hashLength: params.hashLength,
    iterations: params.iterations,
    memorySizeKB: params.memory,
    parallelism: params.parallelism,
    salt: params.salt,
    type: Argon2Type.argon2id,
    version: Argon2Version.v13,
  );

  // Derive key from password
  final hash = argon2.convert(params.password.codeUnits);

  return Uint8List.fromList(hash.bytes);
}

/// Result of migration from PBKDF2 to Argon2id
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
