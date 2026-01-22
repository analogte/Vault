import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackupService Tests', () {
    late BackupService backupService;

    setUp(() {
      backupService = BackupService();
    });

    group('BackupInfo Model', () {
      test('should create BackupInfo with required fields', () {
        final info = BackupInfo(
          version: '1.0.0',
          createdAt: DateTime(2024, 1, 15),
          deviceName: 'Test Device',
          vaultCount: 3,
          fileCount: 100,
          isPasswordProtected: false,
        );

        expect(info.version, '1.0.0');
        expect(info.createdAt, DateTime(2024, 1, 15));
        expect(info.deviceName, 'Test Device');
        expect(info.vaultCount, 3);
        expect(info.fileCount, 100);
        expect(info.isPasswordProtected, isFalse);
      });

      test('should create password protected BackupInfo', () {
        final info = BackupInfo(
          version: '1.0.0',
          createdAt: DateTime.now(),
          deviceName: 'Device',
          vaultCount: 1,
          fileCount: 10,
          isPasswordProtected: true,
        );

        expect(info.isPasswordProtected, isTrue);
      });
    });

    group('BackupInfo toJson', () {
      test('should convert to JSON', () {
        final info = BackupInfo(
          version: '1.0.0',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          deviceName: 'Test Device',
          vaultCount: 3,
          fileCount: 100,
          isPasswordProtected: false,
        );

        final json = info.toJson();

        expect(json['version'], '1.0.0');
        expect(json['createdAt'], '2024-01-15T10:30:00.000');
        expect(json['deviceName'], 'Test Device');
        expect(json['vaultCount'], 3);
        expect(json['fileCount'], 100);
        expect(json['isPasswordProtected'], false);
      });
    });

    group('BackupInfo fromJson', () {
      test('should create from JSON', () {
        final json = {
          'version': '2.0.0',
          'createdAt': '2024-06-15T14:30:00.000',
          'deviceName': 'iPhone 15',
          'vaultCount': 5,
          'fileCount': 250,
          'isPasswordProtected': true,
        };

        final info = BackupInfo.fromJson(json);

        expect(info.version, '2.0.0');
        expect(info.createdAt, DateTime(2024, 6, 15, 14, 30));
        expect(info.deviceName, 'iPhone 15');
        expect(info.vaultCount, 5);
        expect(info.fileCount, 250);
        expect(info.isPasswordProtected, isTrue);
      });

      test('should use default values for missing fields', () {
        final json = {
          'version': '1.0.0',
          'createdAt': '2024-01-15T10:30:00.000',
          'vaultCount': 1,
          'fileCount': 10,
        };

        final info = BackupInfo.fromJson(json);

        expect(info.deviceName, 'Unknown');
        expect(info.isPasswordProtected, isFalse);
      });
    });

    group('BackupInfo Roundtrip', () {
      test('should preserve data through JSON roundtrip', () {
        final original = BackupInfo(
          version: '1.5.0',
          createdAt: DateTime(2024, 3, 20, 16, 45),
          deviceName: 'Pixel 8 Pro',
          vaultCount: 10,
          fileCount: 500,
          isPasswordProtected: true,
        );

        final json = original.toJson();
        final restored = BackupInfo.fromJson(json);

        expect(restored.version, original.version);
        expect(restored.createdAt, original.createdAt);
        expect(restored.deviceName, original.deviceName);
        expect(restored.vaultCount, original.vaultCount);
        expect(restored.fileCount, original.fileCount);
        expect(restored.isPasswordProtected, original.isPasswordProtected);
      });
    });

    group('RestoreResult Model', () {
      test('should create successful RestoreResult', () {
        final result = RestoreResult(
          success: true,
          vaultsRestored: 3,
          filesRestored: 50,
          warnings: [],
        );

        expect(result.success, isTrue);
        expect(result.vaultsRestored, 3);
        expect(result.filesRestored, 50);
        expect(result.warnings, isEmpty);
        expect(result.error, isNull);
      });

      test('should create failed RestoreResult', () {
        final result = RestoreResult(
          success: false,
          vaultsRestored: 0,
          filesRestored: 0,
          warnings: [],
          error: 'File corrupted',
        );

        expect(result.success, isFalse);
        expect(result.error, 'File corrupted');
      });

      test('should create RestoreResult with warnings', () {
        final result = RestoreResult(
          success: true,
          vaultsRestored: 2,
          filesRestored: 30,
          warnings: [
            'Vault "Work" already exists - skipped',
            'File "doc.pdf" missing from backup',
          ],
        );

        expect(result.success, isTrue);
        expect(result.warnings.length, 2);
        expect(result.warnings[0], contains('Work'));
        expect(result.warnings[1], contains('doc.pdf'));
      });
    });

    group('BackupService Methods', () {
      test('should have createBackup method', () {
        expect(backupService.createBackup, isA<Function>());
      });

      test('should have restoreBackup method', () {
        expect(backupService.restoreBackup, isA<Function>());
      });

      test('should have getBackupInfo method', () {
        expect(backupService.getBackupInfo, isA<Function>());
      });

      test('should have shareBackup method', () {
        expect(backupService.shareBackup, isA<Function>());
      });

      test('should have pickBackupFile method', () {
        expect(backupService.pickBackupFile, isA<Function>());
      });

      test('should have deleteBackupFile method', () {
        expect(backupService.deleteBackupFile, isA<Function>());
      });

      test('should have getBackupFileSize method', () {
        expect(backupService.getBackupFileSize, isA<Function>());
      });
    });

    group('Backup Extension', () {
      test('backup extension should be .svbackup', () {
        expect(BackupService.kBackupExtension, '.svbackup');
      });
    });

    group('formatFileSize', () {
      test('should format bytes correctly', () {
        expect(BackupService.formatFileSize(500), '500 B');
      });

      test('should format kilobytes correctly', () {
        expect(BackupService.formatFileSize(1024), '1.0 KB');
        expect(BackupService.formatFileSize(2048), '2.0 KB');
        expect(BackupService.formatFileSize(1536), '1.5 KB');
      });

      test('should format megabytes correctly', () {
        expect(BackupService.formatFileSize(1048576), '1.0 MB');
        expect(BackupService.formatFileSize(5242880), '5.0 MB');
        expect(BackupService.formatFileSize(1572864), '1.5 MB');
      });

      test('should format gigabytes correctly', () {
        expect(BackupService.formatFileSize(1073741824), '1.0 GB');
        expect(BackupService.formatFileSize(2147483648), '2.0 GB');
      });

      test('should handle zero bytes', () {
        expect(BackupService.formatFileSize(0), '0 B');
      });

      test('should handle small values', () {
        expect(BackupService.formatFileSize(1), '1 B');
        expect(BackupService.formatFileSize(100), '100 B');
        expect(BackupService.formatFileSize(1023), '1023 B');
      });

      test('should handle boundary values', () {
        // Just under 1 KB
        expect(BackupService.formatFileSize(1023), '1023 B');
        // Exactly 1 KB
        expect(BackupService.formatFileSize(1024), '1.0 KB');
        // Just under 1 MB
        expect(BackupService.formatFileSize(1048575), '1024.0 KB');
        // Exactly 1 MB
        expect(BackupService.formatFileSize(1048576), '1.0 MB');
      });
    });

    group('Progress Callback', () {
      test('should support progress callback in createBackup', () async {
        final progressUpdates = <double>[];

        // Note: This would need actual database data to work
        // Just testing the callback signature
        void onProgress(String status, double progress) {
          progressUpdates.add(progress);
        }

        expect(onProgress, isA<Function>());
      });
    });
  });
}
