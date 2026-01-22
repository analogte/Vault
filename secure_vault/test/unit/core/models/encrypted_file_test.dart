import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/models/encrypted_file.dart';

void main() {
  group('EncryptedFile Model Tests', () {
    final testCreatedAt = DateTime(2024, 1, 15, 10, 30);
    final testModifiedAt = DateTime(2024, 1, 16, 14, 45);

    group('Constructor', () {
      test('should create EncryptedFile with required fields', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'encrypted_name_abc123',
          encryptedPath: '/path/to/encrypted/file.enc',
          size: 1024,
          createdAt: testCreatedAt,
        );

        expect(file.id, isNull);
        expect(file.vaultId, 1);
        expect(file.encryptedName, 'encrypted_name_abc123');
        expect(file.encryptedPath, '/path/to/encrypted/file.enc');
        expect(file.size, 1024);
        expect(file.createdAt, testCreatedAt);
        expect(file.fileType, isNull);
        expect(file.modifiedAt, isNull);
        expect(file.thumbnailPath, isNull);
        expect(file.deletedAt, isNull);
        expect(file.folderId, isNull);
        expect(file.isChunked, false);
        expect(file.chunkCount, 0);
      });

      test('should create EncryptedFile with all fields', () {
        final deletedAt = DateTime(2024, 1, 20);
        final file = EncryptedFile(
          id: 42,
          vaultId: 1,
          encryptedName: 'encrypted_name',
          encryptedPath: '/path/file.enc',
          fileType: 'jpg',
          size: 2048,
          createdAt: testCreatedAt,
          modifiedAt: testModifiedAt,
          thumbnailPath: '/thumbnails/thumb.jpg',
          deletedAt: deletedAt,
          folderId: 5,
          isChunked: true,
          chunkCount: 10,
        );

        expect(file.id, 42);
        expect(file.fileType, 'jpg');
        expect(file.modifiedAt, testModifiedAt);
        expect(file.thumbnailPath, '/thumbnails/thumb.jpg');
        expect(file.deletedAt, deletedAt);
        expect(file.folderId, 5);
        expect(file.isChunked, true);
        expect(file.chunkCount, 10);
      });
    });

    group('toMap', () {
      test('should convert to map with required fields', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'encrypted_name',
          encryptedPath: '/path/file.enc',
          size: 1024,
          createdAt: testCreatedAt,
        );

        final map = file.toMap();

        expect(map['id'], isNull);
        expect(map['vault_id'], 1);
        expect(map['encrypted_name'], 'encrypted_name');
        expect(map['encrypted_path'], '/path/file.enc');
        expect(map['size'], 1024);
        expect(map['created_at'], testCreatedAt.millisecondsSinceEpoch);
        expect(map['modified_at'], isNull);
        expect(map['is_chunked'], 0);
        expect(map['chunk_count'], 0);
      });

      test('should convert to map with all fields', () {
        final file = EncryptedFile(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          encryptedPath: '/path',
          fileType: 'png',
          size: 512,
          createdAt: testCreatedAt,
          modifiedAt: testModifiedAt,
          isChunked: true,
          chunkCount: 5,
        );

        final map = file.toMap();

        expect(map['id'], 1);
        expect(map['file_type'], 'png');
        expect(map['modified_at'], testModifiedAt.millisecondsSinceEpoch);
        expect(map['is_chunked'], 1);
        expect(map['chunk_count'], 5);
      });
    });

    group('fromMap', () {
      test('should create from map with required fields', () {
        final map = {
          'vault_id': 1,
          'encrypted_name': 'enc_name',
          'encrypted_path': '/enc/path',
          'size': 2048,
          'created_at': testCreatedAt.millisecondsSinceEpoch,
        };

        final file = EncryptedFile.fromMap(map);

        expect(file.id, isNull);
        expect(file.vaultId, 1);
        expect(file.encryptedName, 'enc_name');
        expect(file.encryptedPath, '/enc/path');
        expect(file.size, 2048);
        expect(file.createdAt, testCreatedAt);
        expect(file.isChunked, false);
        expect(file.chunkCount, 0);
      });

      test('should create from map with all fields', () {
        final map = {
          'id': 10,
          'vault_id': 1,
          'encrypted_name': 'enc_name',
          'encrypted_path': '/enc/path',
          'file_type': 'pdf',
          'size': 4096,
          'created_at': testCreatedAt.millisecondsSinceEpoch,
          'modified_at': testModifiedAt.millisecondsSinceEpoch,
          'thumbnail_path': '/thumb.jpg',
          'deleted_at': testModifiedAt.millisecondsSinceEpoch,
          'folder_id': 3,
          'is_chunked': 1,
          'chunk_count': 8,
        };

        final file = EncryptedFile.fromMap(map);

        expect(file.id, 10);
        expect(file.fileType, 'pdf');
        expect(file.modifiedAt, testModifiedAt);
        expect(file.thumbnailPath, '/thumb.jpg');
        expect(file.deletedAt, testModifiedAt);
        expect(file.folderId, 3);
        expect(file.isChunked, true);
        expect(file.chunkCount, 8);
      });

      test('should handle null is_chunked', () {
        final map = {
          'vault_id': 1,
          'encrypted_name': 'name',
          'encrypted_path': '/path',
          'size': 100,
          'created_at': testCreatedAt.millisecondsSinceEpoch,
          'is_chunked': null,
          'chunk_count': null,
        };

        final file = EncryptedFile.fromMap(map);

        expect(file.isChunked, false);
        expect(file.chunkCount, 0);
      });
    });

    group('Roundtrip toMap/fromMap', () {
      test('should preserve all data through roundtrip', () {
        final original = EncryptedFile(
          id: 99,
          vaultId: 5,
          encryptedName: 'test_encrypted_name',
          encryptedPath: '/vaults/5/files/test.enc',
          fileType: 'docx',
          size: 10240,
          createdAt: testCreatedAt,
          modifiedAt: testModifiedAt,
          thumbnailPath: '/thumbs/99.jpg',
          folderId: 7,
          isChunked: true,
          chunkCount: 3,
        );

        final map = original.toMap();
        final restored = EncryptedFile.fromMap(map);

        expect(restored.id, original.id);
        expect(restored.vaultId, original.vaultId);
        expect(restored.encryptedName, original.encryptedName);
        expect(restored.encryptedPath, original.encryptedPath);
        expect(restored.fileType, original.fileType);
        expect(restored.size, original.size);
        expect(restored.createdAt, original.createdAt);
        expect(restored.modifiedAt, original.modifiedAt);
        expect(restored.thumbnailPath, original.thumbnailPath);
        expect(restored.folderId, original.folderId);
        expect(restored.isChunked, original.isChunked);
        expect(restored.chunkCount, original.chunkCount);
      });
    });

    group('isImage', () {
      test('should return true for image file types', () {
        final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];

        for (final type in imageTypes) {
          final file = EncryptedFile(
            vaultId: 1,
            encryptedName: 'test',
            encryptedPath: '/path',
            fileType: type,
            size: 100,
            createdAt: testCreatedAt,
          );
          expect(file.isImage, isTrue, reason: '$type should be an image');
        }
      });

      test('should return true for uppercase image types', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'JPG',
          size: 100,
          createdAt: testCreatedAt,
        );
        expect(file.isImage, isTrue);
      });

      test('should return false for non-image file types', () {
        final nonImageTypes = ['pdf', 'docx', 'txt', 'mp4', 'zip', 'exe'];

        for (final type in nonImageTypes) {
          final file = EncryptedFile(
            vaultId: 1,
            encryptedName: 'test',
            encryptedPath: '/path',
            fileType: type,
            size: 100,
            createdAt: testCreatedAt,
          );
          expect(file.isImage, isFalse, reason: '$type should not be an image');
        }
      });

      test('should return false when fileType is null', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
        );
        expect(file.isImage, isFalse);
      });
    });

    group('isDeleted', () {
      test('should return true when deletedAt is set', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
          deletedAt: DateTime.now(),
        );
        expect(file.isDeleted, isTrue);
      });

      test('should return false when deletedAt is null', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
        );
        expect(file.isDeleted, isFalse);
      });
    });

    group('daysUntilPermanentDeletion', () {
      test('should return null when not deleted', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
        );
        expect(file.daysUntilPermanentDeletion, isNull);
      });

      test('should return remaining days when recently deleted', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
          deletedAt: DateTime.now().subtract(const Duration(days: 10)),
        );
        // Should have about 20 days remaining (30 - 10)
        expect(file.daysUntilPermanentDeletion, closeTo(20, 1));
      });

      test('should return 0 when past 30 days', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
          deletedAt: DateTime.now().subtract(const Duration(days: 35)),
        );
        expect(file.daysUntilPermanentDeletion, 0);
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final original = EncryptedFile(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.vaultId, original.vaultId);
        expect(copy.encryptedName, original.encryptedName);
      });

      test('should copy with partial changes', () {
        final original = EncryptedFile(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
        );

        final copy = original.copyWith(
          encryptedName: 'new_name',
          size: 200,
        );

        expect(copy.id, original.id);
        expect(copy.vaultId, original.vaultId);
        expect(copy.encryptedName, 'new_name');
        expect(copy.size, 200);
        expect(copy.encryptedPath, original.encryptedPath);
      });

      test('should copy with deletedAt for soft delete', () {
        final original = EncryptedFile(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          encryptedPath: '/path',
          size: 100,
          createdAt: testCreatedAt,
        );

        final deleteTime = DateTime.now();
        final copy = original.copyWith(deletedAt: deleteTime);

        expect(copy.deletedAt, deleteTime);
        expect(copy.isDeleted, isTrue);
        expect(original.isDeleted, isFalse);
      });
    });
  });
}
