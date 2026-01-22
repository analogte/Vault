import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/models/file_folder.dart';

void main() {
  group('FileFolder Model Tests', () {
    final testCreatedAt = DateTime(2024, 1, 15, 10, 30);
    final testModifiedAt = DateTime(2024, 1, 16, 14, 45);

    group('Constructor', () {
      test('should create FileFolder with required fields', () {
        final folder = FileFolder(
          vaultId: 1,
          encryptedName: 'encrypted_folder_name',
          createdAt: testCreatedAt,
        );

        expect(folder.id, isNull);
        expect(folder.vaultId, 1);
        expect(folder.encryptedName, 'encrypted_folder_name');
        expect(folder.parentFolderId, isNull);
        expect(folder.createdAt, testCreatedAt);
        expect(folder.modifiedAt, isNull);
        expect(folder.fileCount, 0);
      });

      test('should create FileFolder with all fields', () {
        final folder = FileFolder(
          id: 42,
          vaultId: 1,
          encryptedName: 'encrypted_name',
          parentFolderId: 10,
          createdAt: testCreatedAt,
          modifiedAt: testModifiedAt,
          fileCount: 15,
        );

        expect(folder.id, 42);
        expect(folder.parentFolderId, 10);
        expect(folder.modifiedAt, testModifiedAt);
        expect(folder.fileCount, 15);
      });

      test('should create root folder without parent', () {
        final folder = FileFolder(
          vaultId: 1,
          encryptedName: 'Root',
          createdAt: testCreatedAt,
        );

        expect(folder.parentFolderId, isNull);
      });

      test('should create nested folder with parent', () {
        final parentFolder = FileFolder(
          id: 1,
          vaultId: 1,
          encryptedName: 'Parent',
          createdAt: testCreatedAt,
        );

        final childFolder = FileFolder(
          id: 2,
          vaultId: 1,
          encryptedName: 'Child',
          parentFolderId: parentFolder.id,
          createdAt: testCreatedAt,
        );

        expect(childFolder.parentFolderId, 1);
      });
    });

    group('toMap', () {
      test('should convert to map with required fields', () {
        final folder = FileFolder(
          vaultId: 1,
          encryptedName: 'encrypted_name',
          createdAt: testCreatedAt,
        );

        final map = folder.toMap();

        expect(map['id'], isNull);
        expect(map['vault_id'], 1);
        expect(map['encrypted_name'], 'encrypted_name');
        expect(map['parent_folder_id'], isNull);
        expect(map['created_at'], testCreatedAt.millisecondsSinceEpoch);
        expect(map['modified_at'], isNull);
        // fileCount should not be in map (computed field)
        expect(map.containsKey('file_count'), isFalse);
      });

      test('should convert to map with all DB fields', () {
        final folder = FileFolder(
          id: 5,
          vaultId: 2,
          encryptedName: 'name',
          parentFolderId: 3,
          createdAt: testCreatedAt,
          modifiedAt: testModifiedAt,
          fileCount: 10, // This should not be stored
        );

        final map = folder.toMap();

        expect(map['id'], 5);
        expect(map['parent_folder_id'], 3);
        expect(map['modified_at'], testModifiedAt.millisecondsSinceEpoch);
      });
    });

    group('fromMap', () {
      test('should create from map with required fields', () {
        final map = {
          'vault_id': 1,
          'encrypted_name': 'enc_folder',
          'created_at': testCreatedAt.millisecondsSinceEpoch,
        };

        final folder = FileFolder.fromMap(map);

        expect(folder.id, isNull);
        expect(folder.vaultId, 1);
        expect(folder.encryptedName, 'enc_folder');
        expect(folder.parentFolderId, isNull);
        expect(folder.createdAt, testCreatedAt);
        expect(folder.fileCount, 0);
      });

      test('should create from map with all fields', () {
        final map = {
          'id': 10,
          'vault_id': 2,
          'encrypted_name': 'folder_name',
          'parent_folder_id': 5,
          'created_at': testCreatedAt.millisecondsSinceEpoch,
          'modified_at': testModifiedAt.millisecondsSinceEpoch,
          'file_count': 25,
        };

        final folder = FileFolder.fromMap(map);

        expect(folder.id, 10);
        expect(folder.parentFolderId, 5);
        expect(folder.modifiedAt, testModifiedAt);
        expect(folder.fileCount, 25);
      });

      test('should handle null file_count', () {
        final map = {
          'vault_id': 1,
          'encrypted_name': 'name',
          'created_at': testCreatedAt.millisecondsSinceEpoch,
          'file_count': null,
        };

        final folder = FileFolder.fromMap(map);
        expect(folder.fileCount, 0);
      });
    });

    group('Roundtrip toMap/fromMap', () {
      test('should preserve data through roundtrip', () {
        final original = FileFolder(
          id: 99,
          vaultId: 5,
          encryptedName: 'test_folder',
          parentFolderId: 7,
          createdAt: testCreatedAt,
          modifiedAt: testModifiedAt,
        );

        final map = original.toMap();
        final restored = FileFolder.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.vaultId, original.vaultId);
        expect(restored.encryptedName, original.encryptedName);
        expect(restored.parentFolderId, original.parentFolderId);
        expect(restored.createdAt, original.createdAt);
        expect(restored.modifiedAt, original.modifiedAt);
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final original = FileFolder(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.vaultId, original.vaultId);
        expect(copy.encryptedName, original.encryptedName);
      });

      test('should copy with partial changes', () {
        final original = FileFolder(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          createdAt: testCreatedAt,
          fileCount: 5,
        );

        final copy = original.copyWith(
          encryptedName: 'new_name',
          fileCount: 10,
        );

        expect(copy.id, original.id);
        expect(copy.encryptedName, 'new_name');
        expect(copy.fileCount, 10);
      });

      test('should copy with new parent folder', () {
        final original = FileFolder(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          parentFolderId: 5,
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith(parentFolderId: 10);

        expect(copy.parentFolderId, 10);
        expect(original.parentFolderId, 5);
      });

      test('should update modifiedAt when moving folder', () {
        final original = FileFolder(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          createdAt: testCreatedAt,
        );

        final newModifiedAt = DateTime.now();
        final copy = original.copyWith(
          parentFolderId: 3,
          modifiedAt: newModifiedAt,
        );

        expect(copy.modifiedAt, newModifiedAt);
        expect(original.modifiedAt, isNull);
      });
    });

    group('File Count', () {
      test('should be mutable for computed updates', () {
        final folder = FileFolder(
          vaultId: 1,
          encryptedName: 'name',
          createdAt: testCreatedAt,
          fileCount: 0,
        );

        expect(folder.fileCount, 0);

        // fileCount is mutable for database query results
        folder.fileCount = 5;
        expect(folder.fileCount, 5);
      });
    });
  });
}
