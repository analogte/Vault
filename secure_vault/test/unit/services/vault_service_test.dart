import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/models/vault.dart';

void main() {
  group('Vault Model Tests', () {
    const testName = 'Test Vault';

    group('Vault Creation', () {
      test('should create vault with default PBKDF2 version', () {
        final vault = Vault(
          name: testName,
          path: '/test/path',
          createdAt: DateTime.now(),
          salt: List.generate(32, (i) => i),
          encryptedMasterKey: List.generate(64, (i) => i),
        );

        expect(vault.kdfVersion, equals('pbkdf2'));
      });

      test('should detect Argon2id vault', () {
        final vault = Vault(
          name: testName,
          path: '/test/path',
          createdAt: DateTime.now(),
          kdfVersion: 'argon2id',
          salt: List.generate(32, (i) => i),
          encryptedMasterKey: List.generate(64, (i) => i),
        );

        expect(vault.usesArgon2id, isTrue);
        expect(vault.usesPbkdf2, isFalse);
      });

      test('should detect PBKDF2 vault', () {
        final vault = Vault(
          name: testName,
          path: '/test/path',
          createdAt: DateTime.now(),
          kdfVersion: 'pbkdf2',
          salt: List.generate(32, (i) => i),
          encryptedMasterKey: List.generate(64, (i) => i),
        );

        expect(vault.usesArgon2id, isFalse);
        expect(vault.usesPbkdf2, isTrue);
      });

      test('should copy vault with partial updates', () {
        final originalVault = Vault(
          id: 1,
          name: 'Original Name',
          path: '/original/path',
          createdAt: DateTime(2024, 1, 1),
          lastAccessed: DateTime(2024, 1, 2),
          salt: List.generate(32, (i) => i),
          encryptedMasterKey: List.generate(64, (i) => i),
          kdfVersion: 'pbkdf2',
          isDecoy: false,
        );

        final copiedVault = originalVault.copyWith(
          name: 'Updated Name',
          lastAccessed: DateTime(2024, 1, 3),
          kdfVersion: 'argon2id',
        );

        expect(copiedVault.id, equals(originalVault.id));
        expect(copiedVault.name, equals('Updated Name'));
        expect(copiedVault.path, equals(originalVault.path));
        expect(copiedVault.createdAt, equals(originalVault.createdAt));
        expect(copiedVault.lastAccessed, equals(DateTime(2024, 1, 3)));
        expect(copiedVault.salt, equals(originalVault.salt));
        expect(
          copiedVault.encryptedMasterKey,
          equals(originalVault.encryptedMasterKey),
        );
        expect(copiedVault.kdfVersion, equals('argon2id'));
        expect(copiedVault.isDecoy, equals(originalVault.isDecoy));
      });

      test('should handle decoy vault flag', () {
        final vault = Vault(
          name: testName,
          path: '/test/path',
          createdAt: DateTime.now(),
          salt: List.generate(32, (i) => i),
          encryptedMasterKey: List.generate(64, (i) => i),
          isDecoy: true,
        );

        expect(vault.isDecoy, isTrue);
      });

      test('should handle vault without id', () {
        final vault = Vault(
          name: testName,
          path: '/test/path',
          createdAt: DateTime.now(),
          salt: List.generate(32, (i) => i),
          encryptedMasterKey: List.generate(64, (i) => i),
        );

        expect(vault.id, isNull);
      });

      test('should handle vault with all fields', () {
        final now = DateTime.now();
        final vault = Vault(
          id: 42,
          name: testName,
          path: '/test/path',
          createdAt: now,
          lastAccessed: now,
          salt: List.generate(32, (i) => i),
          encryptedMasterKey: List.generate(64, (i) => i),
          kdfVersion: 'argon2id',
          isDecoy: false,
        );

        expect(vault.id, equals(42));
        expect(vault.name, equals(testName));
        expect(vault.path, equals('/test/path'));
        expect(vault.createdAt, equals(now));
        expect(vault.lastAccessed, equals(now));
        expect(vault.salt.length, equals(32));
        expect(vault.encryptedMasterKey.length, equals(64));
        expect(vault.kdfVersion, equals('argon2id'));
        expect(vault.isDecoy, isFalse);
      });
    });

    group('Vault copyWith', () {
      test('should preserve original values when not overridden', () {
        final original = Vault(
          id: 1,
          name: 'Original',
          path: '/path',
          createdAt: DateTime(2024, 1, 1),
          salt: [1, 2, 3],
          encryptedMasterKey: [4, 5, 6],
        );

        final copied = original.copyWith();

        expect(copied.id, equals(original.id));
        expect(copied.name, equals(original.name));
        expect(copied.path, equals(original.path));
        expect(copied.createdAt, equals(original.createdAt));
        expect(copied.salt, equals(original.salt));
        expect(copied.encryptedMasterKey, equals(original.encryptedMasterKey));
      });

      test('should update only specified fields', () {
        final original = Vault(
          id: 1,
          name: 'Original',
          path: '/path',
          createdAt: DateTime(2024, 1, 1),
          salt: [1, 2, 3],
          encryptedMasterKey: [4, 5, 6],
        );

        final copied = original.copyWith(name: 'New Name');

        expect(copied.name, equals('New Name'));
        expect(copied.id, equals(original.id));
        expect(copied.path, equals(original.path));
      });

      test('should handle updating salt and encryptedMasterKey', () {
        final original = Vault(
          name: 'Test',
          path: '/path',
          createdAt: DateTime.now(),
          salt: [1, 2, 3],
          encryptedMasterKey: [4, 5, 6],
        );

        final newSalt = [10, 20, 30];
        final newKey = [40, 50, 60];
        final copied = original.copyWith(
          salt: newSalt,
          encryptedMasterKey: newKey,
        );

        expect(copied.salt, equals(newSalt));
        expect(copied.encryptedMasterKey, equals(newKey));
      });
    });

    group('KDF Version Detection', () {
      test('should correctly identify argon2id version', () {
        final vault = Vault(
          name: 'Test',
          path: '/path',
          createdAt: DateTime.now(),
          kdfVersion: 'argon2id',
          salt: [],
          encryptedMasterKey: [],
        );

        expect(vault.usesArgon2id, isTrue);
        expect(vault.usesPbkdf2, isFalse);
      });

      test('should correctly identify pbkdf2 version', () {
        final vault = Vault(
          name: 'Test',
          path: '/path',
          createdAt: DateTime.now(),
          kdfVersion: 'pbkdf2',
          salt: [],
          encryptedMasterKey: [],
        );

        expect(vault.usesArgon2id, isFalse);
        expect(vault.usesPbkdf2, isTrue);
      });

      test('should default to pbkdf2 when not specified', () {
        final vault = Vault(
          name: 'Test',
          path: '/path',
          createdAt: DateTime.now(),
          salt: [],
          encryptedMasterKey: [],
        );

        expect(vault.kdfVersion, equals('pbkdf2'));
        expect(vault.usesPbkdf2, isTrue);
      });
    });
  });
}
