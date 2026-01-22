import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/core/models/encrypted_file.dart';
import 'package:secure_vault/services/file_service.dart';

void main() {
  group('FileService Tests', () {
    late FileService fileService;

    setUp(() {
      fileService = FileService();
    });

    group('getFileName', () {
      // Note: This requires a valid masterKey, which needs crypto setup
      // These tests verify the service exists and methods are callable
      test('should have getFileName method', () {
        expect(fileService.getFileName, isA<Function>());
      });
    });

    group('_isImageFile helper logic', () {
      // Test image type detection through EncryptedFile.isImage
      test('should detect jpg as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'jpg',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isTrue);
      });

      test('should detect jpeg as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'jpeg',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isTrue);
      });

      test('should detect png as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'png',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isTrue);
      });

      test('should detect gif as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'gif',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isTrue);
      });

      test('should detect webp as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'webp',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isTrue);
      });

      test('should detect bmp as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'bmp',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isTrue);
      });

      test('should not detect pdf as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'pdf',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isFalse);
      });

      test('should not detect mp4 as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'mp4',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isFalse);
      });

      test('should not detect docx as image', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'docx',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isFalse);
      });

      test('should handle null fileType', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isFalse);
      });

      test('should handle uppercase file types', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          fileType: 'PNG',
          size: 100,
          createdAt: DateTime.now(),
        );
        expect(file.isImage, isTrue);
      });
    });

    group('EncryptedFile soft delete', () {
      test('should mark file as deleted', () {
        final original = EncryptedFile(
          id: 1,
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: DateTime.now(),
        );

        expect(original.isDeleted, isFalse);
        expect(original.deletedAt, isNull);

        final deleted = original.copyWith(deletedAt: DateTime.now());

        expect(deleted.isDeleted, isTrue);
        expect(deleted.deletedAt, isNotNull);
      });

      test('should calculate days until permanent deletion', () {
        final file = EncryptedFile(
          id: 1,
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: DateTime.now(),
          deletedAt: DateTime.now().subtract(const Duration(days: 5)),
        );

        // Should have ~25 days remaining (30 - 5)
        expect(file.daysUntilPermanentDeletion, closeTo(25, 1));
      });

      test('should return 0 days for files past 30 days', () {
        final file = EncryptedFile(
          id: 1,
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100,
          createdAt: DateTime.now(),
          deletedAt: DateTime.now().subtract(const Duration(days: 35)),
        );

        expect(file.daysUntilPermanentDeletion, 0);
      });
    });

    group('EncryptedFile chunked support', () {
      test('should support chunked files', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 100000000, // 100MB
          createdAt: DateTime.now(),
          isChunked: true,
          chunkCount: 25,
        );

        expect(file.isChunked, isTrue);
        expect(file.chunkCount, 25);
      });

      test('should default to non-chunked', () {
        final file = EncryptedFile(
          vaultId: 1,
          encryptedName: 'test',
          encryptedPath: '/path',
          size: 1000,
          createdAt: DateTime.now(),
        );

        expect(file.isChunked, isFalse);
        expect(file.chunkCount, 0);
      });
    });

    group('Storage path generation logic', () {
      // Test the hash-based directory structure concept
      test('should generate consistent paths for same input', () {
        const encryptedFileName = 'abc123encrypted';
        final hash = encryptedFileName.hashCode;
        final dir1 = (hash.abs() % 256).toRadixString(16).padLeft(2, '0');
        final dir2 = ((hash.abs() ~/ 256) % 256).toRadixString(16).padLeft(2, '0');

        // Same hash should give same directories
        final hash2 = encryptedFileName.hashCode;
        final dir1_2 = (hash2.abs() % 256).toRadixString(16).padLeft(2, '0');
        final dir2_2 = ((hash2.abs() ~/ 256) % 256).toRadixString(16).padLeft(2, '0');

        expect(dir1, dir1_2);
        expect(dir2, dir2_2);
      });

      test('should generate valid hex directory names', () {
        const testNames = ['file1', 'file2', 'test.enc', 'encrypted_long_name_here'];

        for (final name in testNames) {
          final hash = name.hashCode;
          final dir1 = (hash.abs() % 256).toRadixString(16).padLeft(2, '0');
          final dir2 = ((hash.abs() ~/ 256) % 256).toRadixString(16).padLeft(2, '0');

          // Should be valid 2-character hex strings
          expect(dir1.length, 2);
          expect(dir2.length, 2);
          expect(RegExp(r'^[0-9a-f]{2}$').hasMatch(dir1), isTrue);
          expect(RegExp(r'^[0-9a-f]{2}$').hasMatch(dir2), isTrue);
        }
      });

      test('should distribute files across directories', () {
        final directories = <String>{};

        // Generate directory paths for many files
        for (var i = 0; i < 100; i++) {
          final name = 'encrypted_file_$i';
          final hash = name.hashCode;
          final dir1 = (hash.abs() % 256).toRadixString(16).padLeft(2, '0');
          final dir2 = ((hash.abs() ~/ 256) % 256).toRadixString(16).padLeft(2, '0');
          directories.add('$dir1/$dir2');
        }

        // Should have some distribution (not all in same directory)
        expect(directories.length, greaterThan(10));
      });
    });

    group('FileService Extension', () {
      test('should have copyWith extension on EncryptedFile', () {
        final original = EncryptedFile(
          id: 1,
          vaultId: 2,
          encryptedName: 'name',
          encryptedPath: '/path',
          size: 100,
          createdAt: DateTime.now(),
        );

        final copied = original.copyWith(size: 200);

        expect(copied.id, original.id);
        expect(copied.size, 200);
      });
    });
  });
}
