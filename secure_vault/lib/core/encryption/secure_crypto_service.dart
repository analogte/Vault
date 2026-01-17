import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, compute;
import 'crypto_service.dart';

/// High-performance cryptography service using PointyCastle
/// AES-256-GCM encryption with PBKDF2 key derivation
class SecureCryptoService {
  // Security parameters
  static const int keyLengthBits = 256;
  static const int keyLengthBytes = 32;
  static const int saltLength = 32;
  static const int ivLength = 12;

  // Platform-appropriate iterations
  // Fewer iterations on web for better performance
  static int get pbkdf2Iterations => kIsWeb ? 10000 : 100000;

  /// Generate cryptographically secure random bytes
  static Uint8List generateSecureRandom(int length) {
    return CryptoService.generateSalt(length);
  }

  /// Generate a random salt
  static Uint8List generateSalt() {
    return generateSecureRandom(saltLength);
  }

  /// Generate a random IV
  static Uint8List generateIV() {
    return generateSecureRandom(ivLength);
  }

  /// Generate a new random master key
  static Uint8List generateMasterKey() {
    return generateSecureRandom(keyLengthBytes);
  }

  /// Derive a key from password using PBKDF2
  static Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    // Use compute for heavy computation to not block UI
    final result = await compute(_deriveKeyIsolate, _DeriveKeyParams(
      password: password,
      salt: salt,
      iterations: pbkdf2Iterations,
    ));
    return result;
  }

  /// Encrypt data using AES-256-GCM
  static Future<Uint8List> encrypt(Uint8List plaintext, Uint8List key) async {
    // Validate key size
    if (key.length != keyLengthBytes) {
      throw ArgumentError('Key must be $keyLengthBytes bytes');
    }

    final encrypted = CryptoService.encryptData(plaintext, key);
    return encrypted.toBytes();
  }

  /// Decrypt data using AES-256-GCM
  static Future<Uint8List> decrypt(Uint8List encrypted, Uint8List key) async {
    if (encrypted.length < ivLength + 16) {
      throw ArgumentError('Encrypted data too short');
    }

    final encryptedData = EncryptedData.fromBytes(encrypted);
    return CryptoService.decryptData(encryptedData, key);
  }

  /// Encrypt master key
  static Future<Uint8List> encryptMasterKey(
    Uint8List masterKey,
    String password,
    Uint8List salt,
  ) async {
    final derivedKey = await deriveKey(password, salt);
    return encrypt(masterKey, derivedKey);
  }

  /// Decrypt master key
  static Future<Uint8List> decryptMasterKey(
    Uint8List encryptedMasterKey,
    String password,
    Uint8List salt,
  ) async {
    final derivedKey = await deriveKey(password, salt);
    return decrypt(encryptedMasterKey, derivedKey);
  }

  /// Verify password
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
}

/// Parameters for key derivation in isolate
class _DeriveKeyParams {
  final String password;
  final Uint8List salt;
  final int iterations;

  _DeriveKeyParams({
    required this.password,
    required this.salt,
    required this.iterations,
  });
}

/// Key derivation function to run in isolate
Uint8List _deriveKeyIsolate(_DeriveKeyParams params) {
  return CryptoService.deriveKey(
    params.password,
    params.salt,
    iterations: params.iterations,
  );
}
