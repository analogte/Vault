import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/encryption/crypto_service.dart';
import 'package:secure_vault/core/encryption/key_manager.dart';
import 'package:secure_vault/core/models/vault.dart';

/// Integration tests for the complete encryption workflow
/// These tests verify the full encryption/decryption cycle works correctly
void main() {
  group('Encryption Flow Integration Tests', () {
    test('Full vault creation and encryption workflow', () async {
      // Simulate creating a new vault
      final vaultPassword = 'MySecureVaultPassword123!';

      // Step 1: Generate salt for key derivation
      final salt = KeyManager.generateSalt();
      expect(salt, hasLength(32));

      // Step 2: Generate master key for the vault
      final masterKey = KeyManager.generateMasterKey();
      expect(masterKey, hasLength(32));

      // Step 3: Encrypt master key with password
      final encryptedMasterKey = await KeyManager.encryptMasterKey(
        masterKey,
        vaultPassword,
        salt,
        kdfVersion: KeyManager.kdfArgon2id,
      );
      expect(encryptedMasterKey.length, greaterThan(masterKey.length));

      // Step 4: Create vault model
      final vault = Vault(
        id: 1,
        name: 'My Secure Vault',
        path: '/path/to/vault',
        createdAt: DateTime.now(),
        salt: salt.toList(),
        encryptedMasterKey: encryptedMasterKey.toList(),
        kdfVersion: 'argon2id',
      );

      expect(vault.name, 'My Secure Vault');
      expect(vault.usesArgon2id, true);

      // Step 5: Simulate opening vault - decrypt master key
      final recoveredMasterKey = await KeyManager.decryptMasterKey(
        Uint8List.fromList(vault.encryptedMasterKey),
        vaultPassword,
        Uint8List.fromList(vault.salt),
        kdfVersion: vault.kdfVersion,
      );

      expect(recoveredMasterKey, masterKey);
    });

    test('File encryption and decryption workflow', () async {
      final masterKey = KeyManager.generateMasterKey();

      // Test file data (simulating an image)
      final originalFileName = 'secret_photo.jpg';
      final originalFileData = Uint8List.fromList(
        List.generate(1024, (i) => i % 256), // 1KB test data
      );

      // Encrypt file name
      final encryptedFileName = CryptoService.encryptFileName(
        originalFileName,
        masterKey,
      );
      expect(encryptedFileName, isNot(equals(originalFileName)));

      // Encrypt file data
      final encryptedData = CryptoService.encryptData(originalFileData, masterKey);
      expect(encryptedData.ciphertext, isNot(equals(originalFileData)));
      expect(encryptedData.toBytes().length, greaterThan(originalFileData.length));

      // Simulate storing encrypted data (in real app, written to disk)
      final storedEncryptedBytes = encryptedData.toBytes();

      // Decrypt file name
      final decryptedFileName = CryptoService.decryptFileName(
        encryptedFileName,
        masterKey,
      );
      expect(decryptedFileName, originalFileName);

      // Decrypt file data
      final decryptedData = CryptoService.decryptData(
        EncryptedData.fromBytes(storedEncryptedBytes),
        masterKey,
      );
      expect(decryptedData, originalFileData);
    });

    test('Multiple files with same master key', () async {
      final masterKey = KeyManager.generateMasterKey();

      // Encrypt multiple files
      final files = [
        ('document.pdf', Uint8List.fromList('PDF content here'.codeUnits)),
        ('image.png', Uint8List.fromList('PNG binary data'.codeUnits)),
        ('video.mp4', Uint8List.fromList('MP4 video data'.codeUnits)),
      ];

      final encryptedFiles = <(String, Uint8List, Uint8List)>[];

      for (final file in files) {
        final encName = CryptoService.encryptFileName(file.$1, masterKey);
        final encData = CryptoService.encryptData(file.$2, masterKey);
        encryptedFiles.add((encName, encData.toBytes(), file.$2));
      }

      // Verify all files can be decrypted
      for (int i = 0; i < encryptedFiles.length; i++) {
        final decName = CryptoService.decryptFileName(
          encryptedFiles[i].$1,
          masterKey,
        );
        final decData = CryptoService.decryptData(
          EncryptedData.fromBytes(encryptedFiles[i].$2),
          masterKey,
        );

        expect(decName, files[i].$1);
        expect(decData, files[i].$2);
      }
    });

    test('Password change preserves file access', () async {
      final oldPassword = 'OldPassword123!';
      final newPassword = 'NewPassword456!';

      // Setup vault with old password
      final oldSalt = KeyManager.generateSalt();
      final masterKey = KeyManager.generateMasterKey();
      final encMasterKeyOld = await KeyManager.encryptMasterKey(
        masterKey,
        oldPassword,
        oldSalt,
        kdfVersion: KeyManager.kdfArgon2id,
      );

      // Encrypt some files
      final testData = Uint8List.fromList('Important data'.codeUnits);
      final encryptedData = CryptoService.encryptData(testData, masterKey);

      // Change password
      final newSalt = KeyManager.generateSalt();

      // Decrypt master key with old password, re-encrypt with new password
      final decMasterKey = await KeyManager.decryptMasterKey(
        encMasterKeyOld,
        oldPassword,
        oldSalt,
        kdfVersion: KeyManager.kdfArgon2id,
      );
      final encMasterKeyNew = await KeyManager.encryptMasterKey(
        decMasterKey,
        newPassword,
        newSalt,
        kdfVersion: KeyManager.kdfArgon2id,
      );

      // Verify files are still accessible with new password
      final recoveredMasterKey = await KeyManager.decryptMasterKey(
        encMasterKeyNew,
        newPassword,
        newSalt,
        kdfVersion: KeyManager.kdfArgon2id,
      );
      final decryptedData = CryptoService.decryptData(encryptedData, recoveredMasterKey);

      expect(decryptedData, testData);
      expect(String.fromCharCodes(decryptedData), 'Important data');
    });

    test('Wrong password cannot decrypt vault', () async {
      final correctPassword = 'CorrectPassword123!';
      final wrongPassword = 'WrongPassword456!';

      final salt = KeyManager.generateSalt();
      final masterKey = KeyManager.generateMasterKey();
      final encryptedMasterKey = await KeyManager.encryptMasterKey(
        masterKey,
        correctPassword,
        salt,
        kdfVersion: KeyManager.kdfArgon2id,
      );

      // Try wrong password
      expect(
        () async => await KeyManager.decryptMasterKey(
          encryptedMasterKey,
          wrongPassword,
          salt,
          kdfVersion: KeyManager.kdfArgon2id,
        ),
        throwsException,
      );
    });

    test('Vault serialization preserves encryption data', () async {
      final password = 'TestPassword123!';
      final salt = KeyManager.generateSalt();
      final masterKey = KeyManager.generateMasterKey();
      final encMasterKey = await KeyManager.encryptMasterKey(
        masterKey,
        password,
        salt,
        kdfVersion: KeyManager.kdfArgon2id,
      );

      // Create and serialize vault
      final vault = Vault(
        id: 42,
        name: 'Serialization Test',
        path: '/test/path',
        createdAt: DateTime.now(),
        salt: salt.toList(),
        encryptedMasterKey: encMasterKey.toList(),
        kdfVersion: 'argon2id',
      );

      final map = vault.toMap();
      final restored = Vault.fromMap(map);

      // Verify master key can be recovered
      final restoredMasterKey = await KeyManager.decryptMasterKey(
        Uint8List.fromList(restored.encryptedMasterKey),
        password,
        Uint8List.fromList(restored.salt),
        kdfVersion: restored.kdfVersion,
      );

      expect(restoredMasterKey, masterKey);
    });

    test('Large data encryption performance', () async {
      final masterKey = KeyManager.generateMasterKey();

      // 5MB test data
      final largeData = Uint8List(5 * 1024 * 1024);
      for (int i = 0; i < largeData.length; i++) {
        largeData[i] = (i * 7) % 256;
      }

      final encryptStart = DateTime.now();
      final encrypted = CryptoService.encryptData(largeData, masterKey);
      final encryptTime = DateTime.now().difference(encryptStart);

      final decryptStart = DateTime.now();
      final decrypted = CryptoService.decryptData(encrypted, masterKey);
      final decryptTime = DateTime.now().difference(decryptStart);

      expect(decrypted, largeData);

      // Log performance metrics
      print('5MB encryption: ${encryptTime.inMilliseconds}ms');
      print('5MB decryption: ${decryptTime.inMilliseconds}ms');

      // Performance should be reasonable (< 10 seconds for 5MB)
      expect(encryptTime.inSeconds, lessThan(10));
      expect(decryptTime.inSeconds, lessThan(10));
    });

    test('Unicode file names are preserved', () async {
      final masterKey = KeyManager.generateMasterKey();

      final unicodeFileNames = [
        'รูปภาพสวยๆ.jpg',
        '文档.pdf',
        'Документ.txt',
        'ファイル名.png',
        'emoji_🎉_file.txt',
      ];

      for (final fileName in unicodeFileNames) {
        final encrypted = CryptoService.encryptFileName(fileName, masterKey);
        final decrypted = CryptoService.decryptFileName(encrypted, masterKey);
        expect(decrypted, fileName, reason: 'Failed for: $fileName');
      }
    });

    test('Empty file handling', () async {
      final masterKey = KeyManager.generateMasterKey();
      final emptyData = Uint8List(0);

      final encrypted = CryptoService.encryptData(emptyData, masterKey);
      final decrypted = CryptoService.decryptData(encrypted, masterKey);

      expect(decrypted, emptyData);
      expect(decrypted.length, 0);
    });

    test('Decoy vault creation and access', () async {
      // Create main vault
      final mainPassword = 'MainPassword123!';
      final mainSalt = KeyManager.generateSalt();
      final mainMasterKey = KeyManager.generateMasterKey();
      final mainEncMasterKey = await KeyManager.encryptMasterKey(
        mainMasterKey,
        mainPassword,
        mainSalt,
        kdfVersion: KeyManager.kdfArgon2id,
      );

      final mainVault = Vault(
        id: 1,
        name: 'Main Vault',
        path: '/main',
        createdAt: DateTime.now(),
        salt: mainSalt.toList(),
        encryptedMasterKey: mainEncMasterKey.toList(),
        kdfVersion: 'argon2id',
        isDecoy: false,
      );

      // Create decoy vault (different password)
      final decoyPassword = 'DecoyPassword456!';
      final decoySalt = KeyManager.generateSalt();
      final decoyMasterKey = KeyManager.generateMasterKey();
      final decoyEncMasterKey = await KeyManager.encryptMasterKey(
        decoyMasterKey,
        decoyPassword,
        decoySalt,
        kdfVersion: KeyManager.kdfArgon2id,
      );

      final decoyVault = Vault(
        id: 2,
        name: 'Main Vault', // Same name
        path: '/main',
        createdAt: DateTime.now(),
        salt: decoySalt.toList(),
        encryptedMasterKey: decoyEncMasterKey.toList(),
        kdfVersion: 'argon2id',
        isDecoy: true,
      );

      expect(mainVault.isDecoy, false);
      expect(decoyVault.isDecoy, true);

      // Verify both vaults can be opened with their respective passwords
      final mainRecoveredKey = await KeyManager.decryptMasterKey(
        Uint8List.fromList(mainVault.encryptedMasterKey),
        mainPassword,
        Uint8List.fromList(mainVault.salt),
        kdfVersion: mainVault.kdfVersion,
      );
      expect(mainRecoveredKey, mainMasterKey);

      final decoyRecoveredKey = await KeyManager.decryptMasterKey(
        Uint8List.fromList(decoyVault.encryptedMasterKey),
        decoyPassword,
        Uint8List.fromList(decoyVault.salt),
        kdfVersion: decoyVault.kdfVersion,
      );
      expect(decoyRecoveredKey, decoyMasterKey);

      // Verify master keys are different
      expect(mainMasterKey, isNot(equals(decoyMasterKey)));
    });

    test('KDF version compatibility - PBKDF2 legacy support', () async {
      final password = 'LegacyPassword123!';
      final salt = KeyManager.generateSalt();
      final masterKey = KeyManager.generateMasterKey();

      // Create vault with PBKDF2 (legacy)
      final encMasterKeyPbkdf2 = await KeyManager.encryptMasterKey(
        masterKey,
        password,
        salt,
        kdfVersion: KeyManager.kdfPbkdf2,
      );

      // Decrypt with PBKDF2
      final recoveredMasterKey = await KeyManager.decryptMasterKey(
        encMasterKeyPbkdf2,
        password,
        salt,
        kdfVersion: KeyManager.kdfPbkdf2,
      );

      expect(recoveredMasterKey, masterKey);
    });
  });
}
