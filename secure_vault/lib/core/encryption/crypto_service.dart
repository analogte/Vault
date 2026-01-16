import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

/// Service for handling encryption and decryption operations
class CryptoService {
  static const int keyLength = 32; // 256 bits
  static const int ivLength = 12; // 96 bits for GCM
  static const int tagLength = 16; // 128 bits for GCM tag

  /// Generate a random salt
  static Uint8List generateSalt([int length = 32]) {
    final random = SecureRandom('Fortuna');
    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    random.seed(KeyParameter(Uint8List.fromList(seeds)));
    return random.nextBytes(length);
  }

  /// Generate a random IV
  static Uint8List generateIV() {
    return generateSalt(ivLength);
  }

  /// Derive key using PBKDF2 (simpler alternative to scrypt for now)
  /// In production, consider using scrypt for better security
  static Uint8List deriveKey(String password, Uint8List salt, {int iterations = 100000}) {
    // PBKDF2 derivation - this is CPU intensive
    // On web, this may take a few seconds with high iterations
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(Pbkdf2Parameters(salt, iterations, keyLength * 8));
    final key = pbkdf2.process(utf8.encode(password));
    return key;
  }

  /// Encrypt data using AES-256-GCM
  static EncryptedData encryptData(Uint8List data, Uint8List key) {
    final iv = generateIV();
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(key);
    final params = AEADParameters(keyParam, 128, iv, Uint8List(0));
    cipher.init(true, params);

    final encrypted = cipher.process(data);
    final tag = cipher.mac;

    return EncryptedData(
      ciphertext: encrypted,
      iv: iv,
      tag: tag,
    );
  }

  /// Decrypt data using AES-256-GCM
  static Uint8List decryptData(EncryptedData encryptedData, Uint8List key) {
    final cipher = GCMBlockCipher(AESEngine());
    final keyParam = KeyParameter(key);
    final params = AEADParameters(keyParam, 128, encryptedData.iv, Uint8List(0));
    cipher.init(false, params);

    final decrypted = cipher.process(encryptedData.ciphertext);
    
    // Verify tag
    if (!_constantTimeEquals(cipher.mac, encryptedData.tag)) {
      throw Exception('Authentication failed: Invalid tag');
    }

    return decrypted;
  }

  /// Encrypt file name
  static String encryptFileName(String fileName, Uint8List key) {
    final data = utf8.encode(fileName);
    final encrypted = encryptData(Uint8List.fromList(data), key);
    return base64Encode(encrypted.toBytes());
  }

  /// Decrypt file name
  static String decryptFileName(String encryptedFileName, Uint8List key) {
    final encryptedBytes = base64Decode(encryptedFileName);
    final encryptedData = EncryptedData.fromBytes(encryptedBytes);
    final decrypted = decryptData(encryptedData, key);
    return utf8.decode(decrypted);
  }

  /// Constant-time comparison to prevent timing attacks
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Wipe sensitive data from memory (best effort)
  static void wipeData(Uint8List data) {
    // Note: In Dart, we can't guarantee memory wiping,
    // but we can try to overwrite the data
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}

/// Encrypted data container
class EncryptedData {
  final Uint8List ciphertext;
  final Uint8List iv;
  final Uint8List tag;

  EncryptedData({
    required this.ciphertext,
    required this.iv,
    required this.tag,
  });

  /// Convert to bytes format: IV + Tag + Ciphertext
  Uint8List toBytes() {
    final result = Uint8List(iv.length + tag.length + ciphertext.length);
    result.setRange(0, iv.length, iv);
    result.setRange(iv.length, iv.length + tag.length, tag);
    result.setRange(iv.length + tag.length, result.length, ciphertext);
    return result;
  }

  /// Create from bytes format: IV + Tag + Ciphertext
  factory EncryptedData.fromBytes(Uint8List bytes) {
    final iv = bytes.sublist(0, CryptoService.ivLength);
    final tag = bytes.sublist(
      CryptoService.ivLength,
      CryptoService.ivLength + CryptoService.tagLength,
    );
    final ciphertext = bytes.sublist(CryptoService.ivLength + CryptoService.tagLength);
    return EncryptedData(
      iv: iv,
      tag: tag,
      ciphertext: ciphertext,
    );
  }
}
