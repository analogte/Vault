import 'package:flutter/foundation.dart';
import 'crypto_service.dart';

/// Isolate-based encryption/decryption to prevent UI blocking
/// Uses compute() to run heavy operations in a separate isolate

/// Parameters for encryption in isolate
class _EncryptParams {
  final Uint8List data;
  final Uint8List key;

  _EncryptParams(this.data, this.key);
}

/// Parameters for decryption in isolate
class _DecryptParams {
  final Uint8List encryptedBytes;
  final Uint8List key;

  _DecryptParams(this.encryptedBytes, this.key);
}

/// Parameters for key derivation in isolate
class _DeriveKeyParams {
  final String password;
  final Uint8List salt;
  final int iterations;

  _DeriveKeyParams(this.password, this.salt, this.iterations);
}

/// Top-level function for encryption (required for compute)
Uint8List _encryptInIsolate(_EncryptParams params) {
  final encryptedData = CryptoService.encryptData(params.data, params.key);
  return encryptedData.toBytes();
}

/// Top-level function for decryption (required for compute)
Uint8List _decryptInIsolate(_DecryptParams params) {
  final encryptedData = EncryptedData.fromBytes(params.encryptedBytes);
  return CryptoService.decryptData(encryptedData, params.key);
}

/// Top-level function for key derivation (required for compute)
Uint8List _deriveKeyInIsolate(_DeriveKeyParams params) {
  return CryptoService.deriveKey(
    params.password,
    params.salt,
    iterations: params.iterations,
  );
}

/// Crypto operations that run in background isolate
class CryptoIsolate {
  /// Encrypt data in background isolate
  /// Returns encrypted bytes (IV + Tag + Ciphertext)
  static Future<Uint8List> encryptData(Uint8List data, Uint8List key) async {
    // For web platform, run synchronously (no isolate support)
    if (kIsWeb) {
      final result = CryptoService.encryptData(data, key);
      return result.toBytes();
    }

    // For mobile/desktop, use compute() for background processing
    return await compute(_encryptInIsolate, _EncryptParams(data, key));
  }

  /// Decrypt data in background isolate
  /// Takes encrypted bytes (IV + Tag + Ciphertext) and returns decrypted data
  static Future<Uint8List> decryptData(Uint8List encryptedBytes, Uint8List key) async {
    // For web platform, run synchronously
    if (kIsWeb) {
      final encryptedData = EncryptedData.fromBytes(encryptedBytes);
      return CryptoService.decryptData(encryptedData, key);
    }

    // For mobile/desktop, use compute() for background processing
    return await compute(_decryptInIsolate, _DecryptParams(encryptedBytes, key));
  }

  /// Derive key from password in background isolate
  static Future<Uint8List> deriveKey(
    String password,
    Uint8List salt, {
    int iterations = 100000,
  }) async {
    // For web platform, use lower iterations to avoid blocking
    if (kIsWeb) {
      return CryptoService.deriveKey(password, salt, iterations: 10000);
    }

    // For mobile/desktop, use compute() for background processing
    return await compute(
      _deriveKeyInIsolate,
      _DeriveKeyParams(password, salt, iterations),
    );
  }

  /// Encrypt file name (small data, sync is fine)
  static String encryptFileName(String fileName, Uint8List key) {
    return CryptoService.encryptFileName(fileName, key);
  }

  /// Decrypt file name (small data, sync is fine)
  static String decryptFileName(String encryptedFileName, Uint8List key) {
    return CryptoService.decryptFileName(encryptedFileName, key);
  }
}
