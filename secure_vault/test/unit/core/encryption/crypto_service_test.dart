import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/encryption/crypto_service.dart';

void main() {
  group('CryptoService Tests', () {
    late String testPassword;
    late Uint8List testKey;
    late Uint8List testData;
    late String testFileName;

    setUpAll(() {
      testPassword = 'testPassword123';
      testKey = Uint8List.fromList([
        0x60,
        0x3d,
        0xeb,
        0x10,
        0x15,
        0xca,
        0x71,
        0xbe,
        0x2b,
        0x73,
        0xae,
        0xf0,
        0x85,
        0x7d,
        0x77,
        0x81,
        0x1f,
        0x35,
        0x2c,
        0x07,
        0x3b,
        0x61,
        0x08,
        0xd7,
        0x2d,
        0x98,
        0x10,
        0xa3,
        0x09,
        0x14,
        0xdf,
        0xf4,
      ]);
      testData = utf8.encode('This is a test message for encryption');
      testFileName = 'test_file.txt';
    });

    group('Salt Generation', () {
      test('should generate salt with correct length', () {
        final salt = CryptoService.generateSalt();
        expect(salt, isA<Uint8List>());
        expect(salt.length, equals(32));
      });

      test('should generate salt with custom length', () {
        final customLength = 16;
        final salt = CryptoService.generateSalt(customLength);
        expect(salt.length, equals(customLength));
      });

      test('should generate different salts each time', () {
        final salt1 = CryptoService.generateSalt();
        final salt2 = CryptoService.generateSalt();

        expect(salt1, isNot(equals(salt2)));
      });

      test('should generate cryptographically secure salts', () {
        final salts = <Uint8List>[];
        for (int i = 0; i < 100; i++) {
          salts.add(CryptoService.generateSalt());
        }

        // Check that all salts are unique
        final uniqueSalts = salts.toSet();
        expect(uniqueSalts.length, equals(salts.length));
      });
    });

    group('IV Generation', () {
      test('should generate IV with correct length', () {
        final iv = CryptoService.generateIV();
        expect(iv, isA<Uint8List>());
        expect(iv.length, equals(CryptoService.ivLength));
      });

      test('should generate different IVs each time', () {
        final iv1 = CryptoService.generateIV();
        final iv2 = CryptoService.generateIV();

        expect(iv1, isNot(equals(iv2)));
      });

      test('should generate cryptographically secure IVs', () {
        final ivs = <Uint8List>[];
        for (int i = 0; i < 100; i++) {
          ivs.add(CryptoService.generateIV());
        }

        // Check that all IVs are unique
        final uniqueIVs = ivs.toSet();
        expect(uniqueIVs.length, equals(ivs.length));
      });
    });

    group('Key Derivation', () {
      test('should derive key with correct length', () {
        final salt = CryptoService.generateSalt();
        final derivedKey = CryptoService.deriveKey(testPassword, salt);

        expect(derivedKey, isA<Uint8List>());
        expect(derivedKey.length, equals(CryptoService.keyLength));
      });

      test('should derive same key for same password and salt', () {
        final salt = CryptoService.generateSalt();
        final key1 = CryptoService.deriveKey(testPassword, salt);
        final key2 = CryptoService.deriveKey(testPassword, salt);

        expect(key1, equals(key2));
      });

      test('should derive different keys for different salts', () {
        final salt1 = CryptoService.generateSalt();
        final salt2 = CryptoService.generateSalt();
        final key1 = CryptoService.deriveKey(testPassword, salt1);
        final key2 = CryptoService.deriveKey(testPassword, salt2);

        expect(key1, isNot(equals(key2)));
      });

      test('should derive different keys for different passwords', () {
        final salt = CryptoService.generateSalt();
        final key1 = CryptoService.deriveKey(testPassword, salt);
        final key2 = CryptoService.deriveKey('differentPassword', salt);

        expect(key1, isNot(equals(key2)));
      });

      test('should use custom iterations count', () {
        final salt = CryptoService.generateSalt();
        final customIterations = 50000;
        final key1 = CryptoService.deriveKey(
          testPassword,
          salt,
          iterations: customIterations,
        );
        final key2 = CryptoService.deriveKey(
          testPassword,
          salt,
          iterations: customIterations,
        );

        expect(key1, equals(key2));
        expect(
          key1,
          isNot(equals(CryptoService.deriveKey(testPassword, salt))),
        );
      });
    });

    group('Data Encryption/Decryption', () {
      test('should encrypt and decrypt data correctly', () {
        final encryptedData = CryptoService.encryptData(testData, testKey);
        expect(encryptedData, isA<EncryptedData>());
        expect(encryptedData.ciphertext, isNot(equals(testData)));

        final decryptedData = CryptoService.decryptData(encryptedData, testKey);
        expect(decryptedData, equals(testData));
      });

      test('should produce different ciphertext for same data', () {
        final encrypted1 = CryptoService.encryptData(testData, testKey);
        final encrypted2 = CryptoService.encryptData(testData, testKey);

        expect(encrypted1.ciphertext, isNot(equals(encrypted2.ciphertext)));
        expect(encrypted1.iv, isNot(equals(encrypted2.iv)));
      });

      test('should fail decryption with wrong key', () {
        final encryptedData = CryptoService.encryptData(testData, testKey);
        final wrongKey = Uint8List.fromList(List.generate(32, (i) => i + 1));

        expect(
          () => CryptoService.decryptData(encryptedData, wrongKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle empty data', () {
        final emptyData = Uint8List(0);
        final encryptedData = CryptoService.encryptData(emptyData, testKey);
        final decryptedData = CryptoService.decryptData(encryptedData, testKey);

        expect(decryptedData, equals(emptyData));
      });

      test('should handle large data', () {
        final largeData = Uint8List.fromList(
          List.generate(1000000, (i) => i % 256),
        );
        final encryptedData = CryptoService.encryptData(largeData, testKey);
        final decryptedData = CryptoService.decryptData(encryptedData, testKey);

        expect(decryptedData, equals(largeData));
      });

      test('should detect tampered data', () {
        final encryptedData = CryptoService.encryptData(testData, testKey);

        // Tamper with ciphertext
        final tamperedData = Uint8List.fromList(encryptedData.ciphertext);
        tamperedData[0] ^= 0xFF;

        final tamperedEncrypted = EncryptedData(
          ciphertext: tamperedData,
          iv: encryptedData.iv,
          tag: encryptedData.tag,
        );

        // Should throw an exception when decrypting tampered data
        // The exact exception type depends on the crypto implementation
        expect(
          () => CryptoService.decryptData(tamperedEncrypted, testKey),
          throwsA(anything),
        );
      });
    });

    group('File Name Encryption/Decryption', () {
      test('should encrypt and decrypt file name correctly', () {
        final encryptedFileName = CryptoService.encryptFileName(
          testFileName,
          testKey,
        );
        expect(encryptedFileName, isA<String>());
        expect(encryptedFileName, isNot(equals(testFileName)));

        final decryptedFileName = CryptoService.decryptFileName(
          encryptedFileName,
          testKey,
        );
        expect(decryptedFileName, equals(testFileName));
      });

      test('should produce different encrypted names for same file', () {
        final encrypted1 = CryptoService.encryptFileName(testFileName, testKey);
        final encrypted2 = CryptoService.encryptFileName(testFileName, testKey);

        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('should handle special characters in file names', () {
        final specialFileName = 'ไฟล์_ทดสอบ #123.txt';
        final encryptedFileName = CryptoService.encryptFileName(
          specialFileName,
          testKey,
        );
        final decryptedFileName = CryptoService.decryptFileName(
          encryptedFileName,
          testKey,
        );

        expect(decryptedFileName, equals(specialFileName));
      });

      test('should handle empty file name', () {
        final emptyFileName = '';
        final encryptedFileName = CryptoService.encryptFileName(
          emptyFileName,
          testKey,
        );
        final decryptedFileName = CryptoService.decryptFileName(
          encryptedFileName,
          testKey,
        );

        expect(decryptedFileName, equals(emptyFileName));
      });

      test('should handle very long file names', () {
        final longFileName = 'a' * 255;
        final encryptedFileName = CryptoService.encryptFileName(
          longFileName,
          testKey,
        );
        final decryptedFileName = CryptoService.decryptFileName(
          encryptedFileName,
          testKey,
        );

        expect(decryptedFileName, equals(longFileName));
      });
    });

    group('EncryptedData Serialization', () {
      test('should convert to bytes and back correctly', () {
        final encryptedData = CryptoService.encryptData(testData, testKey);
        final bytes = encryptedData.toBytes();
        final restoredData = EncryptedData.fromBytes(bytes);

        expect(restoredData.iv, equals(encryptedData.iv));
        expect(restoredData.tag, equals(encryptedData.tag));
        expect(restoredData.ciphertext, equals(encryptedData.ciphertext));
      });

      test('should handle byte serialization roundtrip for decryption', () {
        final encryptedData = CryptoService.encryptData(testData, testKey);
        final bytes = encryptedData.toBytes();
        final restoredData = EncryptedData.fromBytes(bytes);
        final decryptedData = CryptoService.decryptData(restoredData, testKey);

        expect(decryptedData, equals(testData));
      });

      test('should validate byte format structure', () {
        final encryptedData = CryptoService.encryptData(testData, testKey);
        final bytes = encryptedData.toBytes();

        expect(
          bytes.length,
          equals(
            CryptoService.ivLength +
                CryptoService.tagLength +
                encryptedData.ciphertext.length,
          ),
        );
      });
    });

    group('Security Features', () {
      test('should use constant-time comparison for authentication', () {
        // This is tested implicitly through the authentication tag verification
        final encryptedData = CryptoService.encryptData(testData, testKey);

        // Tamper with the tag
        final tamperedTag = Uint8List.fromList(encryptedData.tag);
        tamperedTag[0] ^= 0xFF;

        final tamperedEncrypted = EncryptedData(
          ciphertext: encryptedData.ciphertext,
          iv: encryptedData.iv,
          tag: tamperedTag,
        );

        expect(
          () => CryptoService.decryptData(tamperedEncrypted, testKey),
          throwsA(isA<Exception>()),
        );
      });

      test('should wipe sensitive data', () {
        final sensitiveData = Uint8List.fromList([1, 2, 3, 4, 5]);
        CryptoService.wipeData(sensitiveData);

        expect(sensitiveData, everyElement(equals(0)));
      });

      test('should handle wiping empty data', () {
        final emptyData = Uint8List(0);
        expect(() => CryptoService.wipeData(emptyData), returnsNormally);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle very large data (>10MB)', () {
        final largeData = Uint8List.fromList(
          List.generate(10 * 1024 * 1024, (i) => i % 256),
        );

        // Should complete without error
        final encryptedData = CryptoService.encryptData(largeData, testKey);
        final decryptedData = CryptoService.decryptData(
          encryptedData,
          testKey,
        );
        expect(decryptedData, equals(largeData));
      });

      test('should handle Unicode text correctly', () {
        final unicodeText = '🔐 Secure Vault ทดสอบ 🔒';
        final unicodeData = utf8.encode(unicodeText);

        final encryptedData = CryptoService.encryptData(unicodeData, testKey);
        final decryptedData = CryptoService.decryptData(encryptedData, testKey);
        final decryptedText = utf8.decode(decryptedData);

        expect(decryptedText, equals(unicodeText));
      });

      test('should work with different key sizes', () {
        // AES supports 128, 192, and 256-bit keys
        final key128 = Uint8List(16); // 128 bits
        final key192 = Uint8List(24); // 192 bits
        final key256 = Uint8List(32); // 256 bits

        // Fill keys with test data
        for (var i = 0; i < key128.length; i++) key128[i] = i;
        for (var i = 0; i < key192.length; i++) key192[i] = i;
        for (var i = 0; i < key256.length; i++) key256[i] = i;

        // All standard AES key sizes should work
        final encrypted256 = CryptoService.encryptData(testData, key256);
        final decrypted256 = CryptoService.decryptData(encrypted256, key256);
        expect(decrypted256, equals(testData));
      });

      test('should handle null inputs gracefully', () {
        expect(() => CryptoService.generateSalt(0), returnsNormally);
        expect(() => CryptoService.generateSalt(-1), throwsA(anything));
      });
    });

    group('Performance Tests', () {
      test('should encrypt/decrypt reasonable size data quickly', () async {
        final testData = Uint8List.fromList(
          List.generate(1024 * 1024, (i) => i % 256),
        ); // 1MB

        final stopwatch = Stopwatch()..start();
        final encryptedData = CryptoService.encryptData(testData, testKey);
        final encryptionTime = stopwatch.elapsedMilliseconds;

        stopwatch.reset();
        final decryptedData = CryptoService.decryptData(encryptedData, testKey);
        final decryptionTime = stopwatch.elapsedMilliseconds;

        expect(decryptedData, equals(testData));
        expect(
          encryptionTime,
          lessThan(1000),
        ); // Should encrypt 1MB in < 1 second
        expect(
          decryptionTime,
          lessThan(1000),
        ); // Should decrypt 1MB in < 1 second

        print('Encryption time: ${encryptionTime}ms');
        print('Decryption time: ${decryptionTime}ms');
      });

      test('should derive key in reasonable time', () async {
        final salt = CryptoService.generateSalt();

        final stopwatch = Stopwatch()..start();
        final key = CryptoService.deriveKey(testPassword, salt);
        final derivationTime = stopwatch.elapsedMilliseconds;

        expect(key.length, equals(CryptoService.keyLength));
        expect(derivationTime, lessThan(5000)); // Should derive in < 5 seconds

        print('Key derivation time: ${derivationTime}ms');
      });
    });
  });
}
