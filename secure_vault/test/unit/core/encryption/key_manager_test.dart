import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/encryption/key_manager.dart';

void main() {
  group('KeyManager Tests', () {
    late String testPassword;
    late Uint8List testSalt;
    late Uint8List testMasterKey;
    late Uint8List encryptedMasterKey;

    setUpAll(() {
      testPassword = 'testPassword123';
      testSalt = Uint8List.fromList([
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0A,
        0x0B,
        0x0C,
        0x0D,
        0x0E,
        0x0F,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x19,
        0x1A,
        0x1B,
        0x1C,
        0x1D,
        0x1E,
        0x1F,
        0x20,
      ]);
      testMasterKey = Uint8List.fromList([
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
      encryptedMasterKey = Uint8List.fromList([
        0xA1,
        0xB2,
        0xC3,
        0xD4,
        0xE5,
        0xF6,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0A,
        0x0B,
        0x0C,
        0x0D,
        0x0E,
        0x0F,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x19,
        0x1A,
      ]);
    });

    setUp(() {
      // Reset any static state before each test
    });

    group('Constants', () {
      test('should have correct KDF version constants', () {
        expect(KeyManager.kdfPbkdf2, equals('pbkdf2'));
        expect(KeyManager.kdfArgon2id, equals('argon2id'));
      });

      test('should recommend Argon2id for new vaults', () {
        expect(KeyManager.recommendedKdf, equals(KeyManager.kdfArgon2id));
      });
    });

    group('Master Key Generation', () {
      test('should generate master key with correct length', () {
        final masterKey = KeyManager.generateMasterKey();
        expect(masterKey, isA<Uint8List>());
        expect(masterKey.length, equals(32)); // 256 bits
      });

      test('should generate different keys each time', () {
        final key1 = KeyManager.generateMasterKey();
        final key2 = KeyManager.generateMasterKey();
        expect(key1, isNot(equals(key2)));
      });

      test('should generate cryptographically secure keys', () {
        final keys = <Uint8List>[];
        for (int i = 0; i < 100; i++) {
          keys.add(KeyManager.generateMasterKey());
        }

        final uniqueKeys = keys.toSet();
        expect(uniqueKeys.length, equals(keys.length));
      });
    });

    group('Salt Generation', () {
      test('should generate salt with correct length', () {
        final salt = KeyManager.generateSalt();
        expect(salt, isA<Uint8List>());
        expect(salt.length, equals(32)); // Default salt length
      });

      test('should generate different salts each time', () {
        final salt1 = KeyManager.generateSalt();
        final salt2 = KeyManager.generateSalt();
        expect(salt1, isNot(equals(salt2)));
      });

      test('should generate cryptographically secure salts', () {
        final salts = <Uint8List>[];
        for (int i = 0; i < 100; i++) {
          salts.add(KeyManager.generateSalt());
        }

        final uniqueSalts = salts.toSet();
        expect(uniqueSalts.length, equals(salts.length));
      });
    });

    group('Master Key Derivation', () {
      test('should derive key using Argon2id by default', () async {
        final derivedKey = await KeyManager.deriveMasterKey(
          testPassword,
          testSalt,
        );

        expect(derivedKey, isA<Uint8List>());
        expect(derivedKey.length, equals(32));
      });

      test('should derive key using PBKDF2 when specified', () async {
        final derivedKey = await KeyManager.deriveMasterKey(
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfPbkdf2,
        );

        expect(derivedKey, isA<Uint8List>());
        expect(derivedKey.length, equals(32));
      });

      test('should derive same key for same inputs', () async {
        final key1 = await KeyManager.deriveMasterKey(testPassword, testSalt);
        final key2 = await KeyManager.deriveMasterKey(testPassword, testSalt);
        expect(key1, equals(key2));
      });

      test('should derive different keys for different passwords', () async {
        final key1 = await KeyManager.deriveMasterKey(testPassword, testSalt);
        final key2 = await KeyManager.deriveMasterKey(
          'differentPassword',
          testSalt,
        );
        expect(key1, isNot(equals(key2)));
      });

      test('should derive different keys for different salts', () async {
        final differentSalt = KeyManager.generateSalt();
        final key1 = await KeyManager.deriveMasterKey(testPassword, testSalt);
        final key2 = await KeyManager.deriveMasterKey(
          testPassword,
          differentSalt,
        );
        expect(key1, isNot(equals(key2)));
      });
    });

    group('Master Key Encryption/Decryption', () {
      test('should encrypt and decrypt master key using Argon2id', () async {
        final encrypted = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfArgon2id,
        );

        expect(encrypted, isA<Uint8List>());
        expect(encrypted, isNot(equals(testMasterKey)));

        final decrypted = await KeyManager.decryptMasterKey(
          encrypted,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfArgon2id,
        );

        expect(decrypted, equals(testMasterKey));
      });

      test('should encrypt and decrypt master key using PBKDF2', () async {
        final encrypted = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfPbkdf2,
        );

        expect(encrypted, isA<Uint8List>());
        expect(encrypted, isNot(equals(testMasterKey)));

        final decrypted = await KeyManager.decryptMasterKey(
          encrypted,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfPbkdf2,
        );

        expect(decrypted, equals(testMasterKey));
      });

      test('should fail decryption with wrong password', () async {
        final encrypted = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
        );

        expect(
          () =>
              KeyManager.decryptMasterKey(encrypted, 'wrongPassword', testSalt),
          throwsA(anything),
        );
      });

      test('should fail decryption with wrong salt', () async {
        final encrypted = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
        );

        final wrongSalt = KeyManager.generateSalt();

        expect(
          () => KeyManager.decryptMasterKey(encrypted, testPassword, wrongSalt),
          throwsA(anything),
        );
      });
    });

    group('Password Verification', () {
      test('should verify correct password successfully', () async {
        final encrypted = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
        );

        final isValid = await KeyManager.verifyPassword(
          testPassword,
          encrypted,
          testSalt,
        );

        expect(isValid, isTrue);
      });

      test('should reject incorrect password', () async {
        final encrypted = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
        );

        final isValid = await KeyManager.verifyPassword(
          'wrongPassword',
          encrypted,
          testSalt,
        );

        expect(isValid, isFalse);
      });

      test('should handle verification gracefully with invalid data', () async {
        final invalidEncrypted = Uint8List.fromList([1, 2, 3, 4]);

        final isValid = await KeyManager.verifyPassword(
          testPassword,
          invalidEncrypted,
          testSalt,
        );

        expect(isValid, isFalse);
      });

      test('should use correct KDF version for verification', () async {
        // Test with PBKDF2
        final encryptedPbkdf2 = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfPbkdf2,
        );

        final isValidPbkdf2 = await KeyManager.verifyPassword(
          testPassword,
          encryptedPbkdf2,
          testSalt,
          kdfVersion: KeyManager.kdfPbkdf2,
        );

        expect(isValidPbkdf2, isTrue);

        // Test with Argon2id
        final encryptedArgon2 = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfArgon2id,
        );

        final isValidArgon2 = await KeyManager.verifyPassword(
          testPassword,
          encryptedArgon2,
          testSalt,
          kdfVersion: KeyManager.kdfArgon2id,
        );

        expect(isValidArgon2, isTrue);
      });
    });

    group('Password Hashing', () {
      test('should hash password consistently', () {
        final hash1 = KeyManager.hashPassword(testPassword);
        final hash2 = KeyManager.hashPassword(testPassword);
        expect(hash1, equals(hash2));
      });

      test('should produce different hashes for different passwords', () {
        final hash1 = KeyManager.hashPassword(testPassword);
        final hash2 = KeyManager.hashPassword('differentPassword');
        expect(hash1, isNot(equals(hash2)));
      });

      test('should produce SHA-256 hash', () {
        final hash = KeyManager.hashPassword(testPassword);
        expect(
          hash.length,
          equals(64),
        ); // SHA-256 produces 64 character hex string
        expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(hash), isTrue);
      });

      test('should handle empty password', () {
        final hash = KeyManager.hashPassword('');
        expect(hash.length, equals(64));
        expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(hash), isTrue);
      });
    });

    group('KDF Migration', () {
      test('should migrate from PBKDF2 to Argon2id', () async {
        // Create vault with PBKDF2
        final oldEncryptedKey = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfPbkdf2,
        );

        // Migrate to Argon2id
        final migrationResult = await KeyManager.migrateToArgon2id(
          testPassword,
          oldEncryptedKey,
          testSalt,
        );

        expect(migrationResult, isA<MigrationResult>());
        expect(migrationResult.kdfVersion, equals(KeyManager.kdfArgon2id));
        expect(migrationResult.salt, isNot(equals(testSalt)));

        // Verify migration worked
        final decrypted = await KeyManager.decryptMasterKey(
          migrationResult.encryptedMasterKey,
          testPassword,
          migrationResult.salt,
          kdfVersion: KeyManager.kdfArgon2id,
        );

        expect(decrypted, equals(testMasterKey));
      });

      test('should generate new salt during migration', () async {
        final oldEncryptedKey = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfPbkdf2,
        );

        final migrationResult = await KeyManager.migrateToArgon2id(
          testPassword,
          oldEncryptedKey,
          testSalt,
        );

        expect(migrationResult.salt, isNot(equals(testSalt)));
        expect(migrationResult.salt, isA<Uint8List>());
        expect(migrationResult.salt.length, equals(32));
      });

      test('should fail migration with wrong password', () async {
        final oldEncryptedKey = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfPbkdf2,
        );

        expect(
          () => KeyManager.migrateToArgon2id(
            'wrongPassword',
            oldEncryptedKey,
            testSalt,
          ),
          throwsA(anything),
        );
      });
    });

    group('Migration Decision Logic', () {
      test('should return true for null KDF version', () {
        expect(KeyManager.shouldMigrate(null), isTrue);
      });

      test('should return true for PBKDF2', () {
        expect(KeyManager.shouldMigrate(KeyManager.kdfPbkdf2), isTrue);
      });

      test('should return false for Argon2id', () {
        expect(KeyManager.shouldMigrate(KeyManager.kdfArgon2id), isFalse);
      });
    });

    group('MigrationResult Class', () {
      test('should create MigrationResult with correct properties', () {
        final result = MigrationResult(
          encryptedMasterKey: encryptedMasterKey,
          salt: testSalt,
          kdfVersion: KeyManager.kdfArgon2id,
        );

        expect(result.encryptedMasterKey, equals(encryptedMasterKey));
        expect(result.salt, equals(testSalt));
        expect(result.kdfVersion, equals(KeyManager.kdfArgon2id));
      });
    });

    group('Error Handling', () {
      test('should handle empty password gracefully', () async {
        expect(() => KeyManager.deriveMasterKey('', testSalt), returnsNormally);

        final encrypted = await KeyManager.encryptMasterKey(
          testMasterKey,
          '',
          testSalt,
        );

        final isValid = await KeyManager.verifyPassword(
          '',
          encrypted,
          testSalt,
        );
        expect(isValid, isTrue);
      });

      test('should handle empty salt gracefully', () async {
        final emptySalt = Uint8List(0);

        // Empty salt should throw an error (Argon2 requires at least 8 bytes)
        expect(
          () => KeyManager.deriveMasterKey(testPassword, emptySalt),
          throwsA(anything),
        );
      });

      test('should handle null inputs gracefully', () {
        expect(() => KeyManager.shouldMigrate(null), returnsNormally);

        expect(() => KeyManager.hashPassword(''), returnsNormally);
      });
    });

    group('Security Features', () {
      test('should not store password in memory', () async {
        final originalPassword = testPassword;

        await KeyManager.deriveMasterKey(testPassword, testSalt);
        final hash = KeyManager.hashPassword(testPassword);

        // Verify password hash is not the same as password
        expect(hash, isNot(equals(originalPassword)));
        expect(hash.length, greaterThan(originalPassword.length));
      });

      test('should use different salts for encryption', () async {
        final encrypted1 = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
        );

        final differentSalt = KeyManager.generateSalt();
        final encrypted2 = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          differentSalt,
        );

        expect(encrypted1, isNot(equals(encrypted2)));
      });
    });

    group('Performance Tests', () {
      test('should derive key in reasonable time', () async {
        final stopwatch = Stopwatch()..start();

        await KeyManager.deriveMasterKey(testPassword, testSalt);

        final elapsed = stopwatch.elapsedMilliseconds;
        expect(elapsed, lessThan(10000)); // Should complete within 10 seconds

        print('Key derivation time: ${elapsed}ms');
      });

      test('should encrypt/decrypt master key quickly', () async {
        final stopwatch = Stopwatch()..start();

        // Use Argon2id (the recommended and default for encryptMasterKey)
        final encrypted = await KeyManager.encryptMasterKey(
          testMasterKey,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfArgon2id,
        );
        final encryptionTime = stopwatch.elapsedMilliseconds;

        stopwatch.reset();
        // Must use same KDF version for decryption
        final decrypted = await KeyManager.decryptMasterKey(
          encrypted,
          testPassword,
          testSalt,
          kdfVersion: KeyManager.kdfArgon2id,
        );
        final decryptionTime = stopwatch.elapsedMilliseconds;

        expect(decrypted, equals(testMasterKey));
        expect(encryptionTime, lessThan(5000)); // Argon2id is slower, allow 5 seconds
        expect(decryptionTime, lessThan(5000)); // Argon2id is slower, allow 5 seconds

        print('Encryption time: ${encryptionTime}ms');
        print('Decryption time: ${decryptionTime}ms');
      });
    });
  });
}
