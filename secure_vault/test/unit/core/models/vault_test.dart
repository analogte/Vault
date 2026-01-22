import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/models/vault.dart';

void main() {
  group('Vault Model Tests', () {
    late DateTime testDate;
    late List<int> testSalt;
    late List<int> testEncryptedKey;

    setUp(() {
      testDate = DateTime(2025, 1, 22, 10, 30, 0);
      testSalt = List.generate(32, (i) => i);
      testEncryptedKey = List.generate(64, (i) => i * 2);
    });

    group('Constructor', () {
      test('should create vault with all required fields', () {
        final vault = Vault(
          id: 1,
          name: 'Test Vault',
          path: '/path/to/vault',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
        );

        expect(vault.id, 1);
        expect(vault.name, 'Test Vault');
        expect(vault.path, '/path/to/vault');
        expect(vault.createdAt, testDate);
        expect(vault.salt, testSalt);
        expect(vault.encryptedMasterKey, testEncryptedKey);
        expect(vault.kdfVersion, 'pbkdf2'); // Default
        expect(vault.isDecoy, false); // Default
        expect(vault.lastAccessed, null);
      });

      test('should create vault with argon2id kdf', () {
        final vault = Vault(
          name: 'Secure Vault',
          path: '/path/to/vault',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          kdfVersion: 'argon2id',
        );

        expect(vault.kdfVersion, 'argon2id');
        expect(vault.usesArgon2id, true);
        expect(vault.usesPbkdf2, false);
      });

      test('should create decoy vault', () {
        final vault = Vault(
          name: 'Decoy Vault',
          path: '/path/to/decoy',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          isDecoy: true,
        );

        expect(vault.isDecoy, true);
      });

      test('should handle null id', () {
        final vault = Vault(
          name: 'New Vault',
          path: '/path/to/vault',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
        );

        expect(vault.id, null);
      });
    });

    group('toMap', () {
      test('should convert vault to map correctly', () {
        final vault = Vault(
          id: 1,
          name: 'Test Vault',
          path: '/path/to/vault',
          createdAt: testDate,
          lastAccessed: testDate.add(const Duration(hours: 1)),
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          kdfVersion: 'argon2id',
          isDecoy: true,
        );

        final map = vault.toMap();

        expect(map['id'], 1);
        expect(map['name'], 'Test Vault');
        expect(map['path'], '/path/to/vault');
        expect(map['created_at'], testDate.millisecondsSinceEpoch);
        expect(map['last_accessed'],
            testDate.add(const Duration(hours: 1)).millisecondsSinceEpoch);
        expect(map['salt'], base64Encode(Uint8List.fromList(testSalt)));
        expect(map['encrypted_master_key'],
            base64Encode(Uint8List.fromList(testEncryptedKey)));
        expect(map['kdf_version'], 'argon2id');
        expect(map['is_decoy'], 1);
      });

      test('should handle null lastAccessed', () {
        final vault = Vault(
          name: 'Test Vault',
          path: '/path/to/vault',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
        );

        final map = vault.toMap();

        expect(map['last_accessed'], null);
      });

      test('should handle isDecoy false', () {
        final vault = Vault(
          name: 'Test Vault',
          path: '/path/to/vault',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          isDecoy: false,
        );

        final map = vault.toMap();

        expect(map['is_decoy'], 0);
      });
    });

    group('fromMap', () {
      test('should create vault from map with base64 strings', () {
        final map = {
          'id': 1,
          'name': 'Test Vault',
          'path': '/path/to/vault',
          'created_at': testDate.millisecondsSinceEpoch,
          'last_accessed':
              testDate.add(const Duration(hours: 1)).millisecondsSinceEpoch,
          'salt': base64Encode(Uint8List.fromList(testSalt)),
          'encrypted_master_key':
              base64Encode(Uint8List.fromList(testEncryptedKey)),
          'kdf_version': 'argon2id',
          'is_decoy': 1,
        };

        final vault = Vault.fromMap(map);

        expect(vault.id, 1);
        expect(vault.name, 'Test Vault');
        expect(vault.path, '/path/to/vault');
        expect(vault.createdAt, testDate);
        expect(vault.lastAccessed, testDate.add(const Duration(hours: 1)));
        expect(vault.salt, testSalt);
        expect(vault.encryptedMasterKey, testEncryptedKey);
        expect(vault.kdfVersion, 'argon2id');
        expect(vault.isDecoy, true);
      });

      test('should create vault from map with Uint8List values', () {
        final map = {
          'id': 2,
          'name': 'Native Vault',
          'path': '/path/to/native',
          'created_at': testDate.millisecondsSinceEpoch,
          'salt': Uint8List.fromList(testSalt),
          'encrypted_master_key': Uint8List.fromList(testEncryptedKey),
        };

        final vault = Vault.fromMap(map);

        expect(vault.id, 2);
        expect(vault.salt, testSalt);
        expect(vault.encryptedMasterKey, testEncryptedKey);
      });

      test('should create vault from map with List<int> values', () {
        final map = {
          'id': 3,
          'name': 'List Vault',
          'path': '/path/to/list',
          'created_at': testDate.millisecondsSinceEpoch,
          'salt': testSalt,
          'encrypted_master_key': testEncryptedKey,
        };

        final vault = Vault.fromMap(map);

        expect(vault.salt, testSalt);
        expect(vault.encryptedMasterKey, testEncryptedKey);
      });

      test('should handle null kdf_version (backward compatibility)', () {
        final map = {
          'id': 1,
          'name': 'Old Vault',
          'path': '/path/to/old',
          'created_at': testDate.millisecondsSinceEpoch,
          'salt': base64Encode(Uint8List.fromList(testSalt)),
          'encrypted_master_key':
              base64Encode(Uint8List.fromList(testEncryptedKey)),
        };

        final vault = Vault.fromMap(map);

        expect(vault.kdfVersion, 'pbkdf2');
      });

      test('should handle is_decoy as boolean true', () {
        final map = {
          'id': 1,
          'name': 'Decoy Vault',
          'path': '/path/to/decoy',
          'created_at': testDate.millisecondsSinceEpoch,
          'salt': base64Encode(Uint8List.fromList(testSalt)),
          'encrypted_master_key':
              base64Encode(Uint8List.fromList(testEncryptedKey)),
          'is_decoy': true,
        };

        final vault = Vault.fromMap(map);

        expect(vault.isDecoy, true);
      });

      test('should handle null last_accessed', () {
        final map = {
          'id': 1,
          'name': 'Test Vault',
          'path': '/path/to/vault',
          'created_at': testDate.millisecondsSinceEpoch,
          'last_accessed': null,
          'salt': base64Encode(Uint8List.fromList(testSalt)),
          'encrypted_master_key':
              base64Encode(Uint8List.fromList(testEncryptedKey)),
        };

        final vault = Vault.fromMap(map);

        expect(vault.lastAccessed, null);
      });

      test('should throw ArgumentError for invalid salt format', () {
        final map = {
          'id': 1,
          'name': 'Test Vault',
          'path': '/path/to/vault',
          'created_at': testDate.millisecondsSinceEpoch,
          'salt': 12345, // Invalid type
          'encrypted_master_key':
              base64Encode(Uint8List.fromList(testEncryptedKey)),
        };

        expect(() => Vault.fromMap(map), throwsArgumentError);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = Vault(
          id: 1,
          name: 'Original',
          path: '/original/path',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          kdfVersion: 'pbkdf2',
          isDecoy: false,
        );

        final copy = original.copyWith(
          name: 'Updated',
          kdfVersion: 'argon2id',
          isDecoy: true,
        );

        expect(copy.id, original.id);
        expect(copy.name, 'Updated');
        expect(copy.path, original.path);
        expect(copy.createdAt, original.createdAt);
        expect(copy.kdfVersion, 'argon2id');
        expect(copy.isDecoy, true);
      });

      test('should preserve original values when not specified', () {
        final original = Vault(
          id: 1,
          name: 'Original',
          path: '/original/path',
          createdAt: testDate,
          lastAccessed: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          kdfVersion: 'argon2id',
          isDecoy: true,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.path, original.path);
        expect(copy.createdAt, original.createdAt);
        expect(copy.lastAccessed, original.lastAccessed);
        expect(copy.salt, original.salt);
        expect(copy.encryptedMasterKey, original.encryptedMasterKey);
        expect(copy.kdfVersion, original.kdfVersion);
        expect(copy.isDecoy, original.isDecoy);
      });

      test('should update lastAccessed', () {
        final original = Vault(
          id: 1,
          name: 'Original',
          path: '/original/path',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
        );

        final newAccessed = DateTime.now();
        final copy = original.copyWith(lastAccessed: newAccessed);

        expect(copy.lastAccessed, newAccessed);
        expect(original.lastAccessed, null);
      });
    });

    group('KDF Version Helpers', () {
      test('usesArgon2id should return true for argon2id vault', () {
        final vault = Vault(
          name: 'Argon Vault',
          path: '/path',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          kdfVersion: 'argon2id',
        );

        expect(vault.usesArgon2id, true);
        expect(vault.usesPbkdf2, false);
      });

      test('usesPbkdf2 should return true for pbkdf2 vault', () {
        final vault = Vault(
          name: 'PBKDF2 Vault',
          path: '/path',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          kdfVersion: 'pbkdf2',
        );

        expect(vault.usesPbkdf2, true);
        expect(vault.usesArgon2id, false);
      });

      test('default kdfVersion should be pbkdf2', () {
        final vault = Vault(
          name: 'Default Vault',
          path: '/path',
          createdAt: testDate,
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
        );

        expect(vault.kdfVersion, 'pbkdf2');
        expect(vault.usesPbkdf2, true);
      });
    });

    group('Round-trip Serialization', () {
      test('should serialize and deserialize correctly', () {
        final original = Vault(
          id: 42,
          name: 'Round-trip Test',
          path: '/test/roundtrip',
          createdAt: testDate,
          lastAccessed: testDate.add(const Duration(days: 1)),
          salt: testSalt,
          encryptedMasterKey: testEncryptedKey,
          kdfVersion: 'argon2id',
          isDecoy: true,
        );

        final map = original.toMap();
        final restored = Vault.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.path, original.path);
        expect(restored.createdAt, original.createdAt);
        expect(restored.lastAccessed, original.lastAccessed);
        expect(restored.salt, original.salt);
        expect(restored.encryptedMasterKey, original.encryptedMasterKey);
        expect(restored.kdfVersion, original.kdfVersion);
        expect(restored.isDecoy, original.isDecoy);
      });
    });
  });
}
