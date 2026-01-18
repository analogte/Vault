import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../core/storage/database_helper.dart';
import '../core/models/vault.dart';
import '../core/models/encrypted_file.dart';
import '../core/models/file_folder.dart';
import '../core/encryption/crypto_service.dart';
import '../core/utils/logger.dart';

/// Backup file format version
const int kBackupVersion = 1;

/// Backup file extension
const String kBackupExtension = '.svbackup';

/// Backup result model
class BackupResult {
  final bool success;
  final String? filePath;
  final String? error;
  final int vaultCount;
  final int fileCount;
  final int folderCount;

  BackupResult({
    required this.success,
    this.filePath,
    this.error,
    this.vaultCount = 0,
    this.fileCount = 0,
    this.folderCount = 0,
  });
}

/// Restore result model
class RestoreResult {
  final bool success;
  final String? error;
  final int vaultCount;
  final int fileCount;
  final int folderCount;
  final List<String> warnings;

  RestoreResult({
    required this.success,
    this.error,
    this.vaultCount = 0,
    this.fileCount = 0,
    this.folderCount = 0,
    this.warnings = const [],
  });
}

/// Backup info model
class BackupInfo {
  final int version;
  final DateTime createdAt;
  final String deviceName;
  final int vaultCount;
  final int fileCount;
  final int folderCount;
  final bool isPasswordProtected;

  BackupInfo({
    required this.version,
    required this.createdAt,
    required this.deviceName,
    required this.vaultCount,
    required this.fileCount,
    required this.folderCount,
    required this.isPasswordProtected,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      version: json['version'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
      deviceName: json['deviceName'] ?? 'Unknown',
      vaultCount: json['vaultCount'] ?? 0,
      fileCount: json['fileCount'] ?? 0,
      folderCount: json['folderCount'] ?? 0,
      isPasswordProtected: json['isPasswordProtected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'deviceName': deviceName,
        'vaultCount': vaultCount,
        'fileCount': fileCount,
        'folderCount': folderCount,
        'isPasswordProtected': isPasswordProtected,
      };
}

/// Service for backup and restore functionality
class BackupService {
  static const String _tag = 'BackupService';

  /// Create a backup of all data
  Future<BackupResult> createBackup({
    String? password,
    void Function(String status, double progress)? onProgress,
  }) async {
    try {
      AppLogger.log('Starting backup creation...', tag: _tag);
      onProgress?.call('กำลังเตรียมข้อมูล...', 0.0);

      // Get all vaults
      final vaults = await DatabaseHelper.instance.getAllVaults();
      if (vaults.isEmpty) {
        return BackupResult(
          success: false,
          error: 'ไม่มี Vault ที่จะ backup',
        );
      }

      // Get all files and folders
      final allFiles = <EncryptedFile>[];
      final allFolders = <FileFolder>[];

      for (final vault in vaults) {
        final files = await DatabaseHelper.instance.getFilesByVault(vault.id!);
        final folders =
            await DatabaseHelper.instance.getFoldersByVault(vault.id!);
        allFiles.addAll(files);
        allFolders.addAll(folders);
      }

      onProgress?.call('กำลังสร้างไฟล์ backup...', 0.2);

      // Create archive
      final archive = Archive();

      // Add metadata
      final metadata = BackupInfo(
        version: kBackupVersion,
        createdAt: DateTime.now(),
        deviceName: Platform.localHostname,
        vaultCount: vaults.length,
        fileCount: allFiles.length,
        folderCount: allFolders.length,
        isPasswordProtected: password != null && password.isNotEmpty,
      );

      final metadataJson = jsonEncode(metadata.toJson());
      archive.addFile(ArchiveFile(
        'metadata.json',
        metadataJson.length,
        utf8.encode(metadataJson),
      ));

      onProgress?.call('กำลัง backup vaults...', 0.3);

      // Add vaults data
      final vaultsJson = jsonEncode(vaults.map((v) => v.toMap()).toList());
      archive.addFile(ArchiveFile(
        'vaults.json',
        vaultsJson.length,
        utf8.encode(vaultsJson),
      ));

      // Add folders data
      final foldersJson = jsonEncode(allFolders.map((f) => f.toMap()).toList());
      archive.addFile(ArchiveFile(
        'folders.json',
        foldersJson.length,
        utf8.encode(foldersJson),
      ));

      onProgress?.call('กำลัง backup ข้อมูลไฟล์...', 0.4);

      // Add files metadata
      final filesJson = jsonEncode(allFiles.map((f) => f.toMap()).toList());
      archive.addFile(ArchiveFile(
        'files.json',
        filesJson.length,
        utf8.encode(filesJson),
      ));

      onProgress?.call('กำลัง backup encrypted files...', 0.5);

      // Add actual encrypted file data
      int processedFiles = 0;
      for (final file in allFiles) {
        final encryptedPath = file.encryptedPath;
        final encryptedFile = File(encryptedPath);

        if (await encryptedFile.exists()) {
          final fileData = await encryptedFile.readAsBytes();
          final archivePath = 'files/${file.id}_${path.basename(encryptedPath)}';
          archive.addFile(ArchiveFile(archivePath, fileData.length, fileData));
        }

        processedFiles++;
        final progress = 0.5 + (processedFiles / allFiles.length) * 0.4;
        onProgress?.call(
            'กำลัง backup ไฟล์ ($processedFiles/${allFiles.length})...',
            progress);
      }

      onProgress?.call('กำลังบีบอัดข้อมูล...', 0.9);

      // Encode archive
      Uint8List archiveData = Uint8List.fromList(ZipEncoder().encode(archive)!);

      // Encrypt if password provided
      if (password != null && password.isNotEmpty) {
        onProgress?.call('กำลังเข้ารหัส backup...', 0.95);
        archiveData = _encryptBackup(archiveData, password);
      }

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = 'secure_vault_backup_$timestamp$kBackupExtension';
      final backupPath = path.join(tempDir.path, backupFileName);
      final backupFile = File(backupPath);
      await backupFile.writeAsBytes(archiveData);

      onProgress?.call('เสร็จสิ้น!', 1.0);

      AppLogger.log(
        'Backup created: ${vaults.length} vaults, ${allFiles.length} files, ${allFolders.length} folders',
        tag: _tag,
      );

      return BackupResult(
        success: true,
        filePath: backupPath,
        vaultCount: vaults.length,
        fileCount: allFiles.length,
        folderCount: allFolders.length,
      );
    } catch (e, stack) {
      AppLogger.error('Backup creation failed', tag: _tag, error: e, stackTrace: stack);
      return BackupResult(
        success: false,
        error: 'การสร้าง backup ล้มเหลว: $e',
      );
    }
  }

  /// Share backup file
  Future<bool> shareBackup(String filePath) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Secure Vault Backup',
        text: 'ไฟล์ backup จาก Secure Vault',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      AppLogger.error('Share backup failed', tag: _tag, error: e);
      return false;
    }
  }

  /// Save backup to selected location
  Future<String?> saveBackupToLocation(String filePath) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'บันทึก Backup',
        fileName: path.basename(filePath),
        type: FileType.custom,
        allowedExtensions: ['svbackup'],
      );

      if (result != null) {
        final sourceFile = File(filePath);
        await sourceFile.copy(result);
        return result;
      }

      return null;
    } catch (e) {
      AppLogger.error('Save backup failed', tag: _tag, error: e);
      return null;
    }
  }

  /// Pick backup file for restore
  Future<String?> pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svbackup'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }

      return null;
    } catch (e) {
      AppLogger.error('Pick backup file failed', tag: _tag, error: e);
      return null;
    }
  }

  /// Get backup info without restoring
  Future<BackupInfo?> getBackupInfo(String filePath, {String? password}) async {
    try {
      final backupFile = File(filePath);
      if (!await backupFile.exists()) {
        return null;
      }

      var data = await backupFile.readAsBytes();

      // Try to decrypt if password provided
      if (password != null && password.isNotEmpty) {
        try {
          data = _decryptBackup(data, password);
        } catch (e) {
          return null;
        }
      }

      // Decode archive
      Archive archive;
      try {
        archive = ZipDecoder().decodeBytes(data);
      } catch (e) {
        return null;
      }

      // Find and read metadata
      final metadataFile = archive.findFile('metadata.json');
      if (metadataFile == null) {
        return null;
      }

      final metadataJson = utf8.decode(metadataFile.content);
      return BackupInfo.fromJson(jsonDecode(metadataJson));
    } catch (e) {
      AppLogger.error('Get backup info failed', tag: _tag, error: e);
      return null;
    }
  }

  /// Restore from backup
  Future<RestoreResult> restoreBackup(
    String filePath, {
    String? password,
    bool overwrite = false,
    void Function(String status, double progress)? onProgress,
  }) async {
    try {
      AppLogger.log('Starting backup restoration...', tag: _tag);
      onProgress?.call('กำลังอ่านไฟล์ backup...', 0.0);

      final backupFile = File(filePath);
      if (!await backupFile.exists()) {
        return RestoreResult(
          success: false,
          error: 'ไม่พบไฟล์ backup',
        );
      }

      var data = await backupFile.readAsBytes();

      // Decrypt if password provided
      if (password != null && password.isNotEmpty) {
        onProgress?.call('กำลังถอดรหัส backup...', 0.1);
        try {
          data = _decryptBackup(data, password);
        } catch (e) {
          return RestoreResult(
            success: false,
            error: 'รหัสผ่านไม่ถูกต้องหรือไฟล์เสียหาย',
          );
        }
      }

      onProgress?.call('กำลังแตกไฟล์...', 0.2);

      // Decode archive
      Archive archive;
      try {
        archive = ZipDecoder().decodeBytes(data);
      } catch (e) {
        return RestoreResult(
          success: false,
          error: 'ไฟล์ backup เสียหายหรือต้องใส่รหัสผ่าน',
        );
      }

      // Read metadata
      final metadataFile = archive.findFile('metadata.json');
      if (metadataFile == null) {
        return RestoreResult(
          success: false,
          error: 'ไฟล์ backup ไม่ถูกต้อง (ไม่พบ metadata)',
        );
      }

      final metadataJson = utf8.decode(metadataFile.content);
      final metadata = BackupInfo.fromJson(jsonDecode(metadataJson));

      // Check password protection
      if (metadata.isPasswordProtected && (password == null || password.isEmpty)) {
        return RestoreResult(
          success: false,
          error: 'ไฟล์ backup นี้ต้องใส่รหัสผ่าน',
        );
      }

      onProgress?.call('กำลัง restore vaults...', 0.3);

      final warnings = <String>[];

      // Read vaults
      final vaultsFile = archive.findFile('vaults.json');
      if (vaultsFile == null) {
        return RestoreResult(
          success: false,
          error: 'ไฟล์ backup ไม่ถูกต้อง (ไม่พบข้อมูล vaults)',
        );
      }

      final vaultsJson = utf8.decode(vaultsFile.content);
      final vaultMaps = List<Map<String, dynamic>>.from(jsonDecode(vaultsJson));
      final vaults = vaultMaps.map((m) => Vault.fromMap(m)).toList();

      // Map old vault IDs to new IDs
      final vaultIdMap = <int, int>{};

      // Get app storage directory for vaults
      final appDir = await getApplicationDocumentsDirectory();
      final vaultsDir = Directory(path.join(appDir.path, 'vaults'));
      if (!await vaultsDir.exists()) {
        await vaultsDir.create(recursive: true);
      }

      for (final vault in vaults) {
        final oldId = vault.id;

        // Check if vault with same name exists
        final existingVaults = await DatabaseHelper.instance.getAllVaults();
        Vault? existingVault;
        for (final v in existingVaults) {
          if (v.name == vault.name) {
            existingVault = v;
            break;
          }
        }

        if (existingVault != null) {
          if (overwrite) {
            // Delete existing vault and its files
            await DatabaseHelper.instance.deleteVault(existingVault.id!);
            warnings.add('Vault "${vault.name}" ถูกแทนที่');
          } else {
            // Skip this vault
            warnings.add('ข้าม Vault "${vault.name}" เนื่องจากมีอยู่แล้ว');
            continue;
          }
        }

        // Create new vault path
        final newVaultPath = path.join(vaultsDir.path, '${DateTime.now().millisecondsSinceEpoch}_${vault.name}');

        // Insert vault with new path
        final newId = await DatabaseHelper.instance.createVault(
          vault.copyWith(id: null, path: newVaultPath),
        );
        if (oldId != null) {
          vaultIdMap[oldId] = newId;
        }

        // Create vault directory
        final vaultDirectory = Directory(newVaultPath);
        if (!await vaultDirectory.exists()) {
          await vaultDirectory.create(recursive: true);
        }
      }

      onProgress?.call('กำลัง restore folders...', 0.4);

      // Read folders
      final foldersFile = archive.findFile('folders.json');
      final folderIdMap = <int, int>{};

      if (foldersFile != null) {
        final foldersJson = utf8.decode(foldersFile.content);
        final folderMaps =
            List<Map<String, dynamic>>.from(jsonDecode(foldersJson));
        final folders = folderMaps.map((m) => FileFolder.fromMap(m)).toList();

        // Sort folders by parent_folder_id to create parent folders first
        folders.sort((a, b) {
          final aParent = a.parentFolderId ?? 0;
          final bParent = b.parentFolderId ?? 0;
          return aParent.compareTo(bParent);
        });

        for (final folder in folders) {
          final oldId = folder.id;
          final oldVaultId = folder.vaultId;

          // Map to new vault ID
          final newVaultId = vaultIdMap[oldVaultId];
          if (newVaultId == null) {
            warnings.add('ข้าม folder เนื่องจากไม่พบ vault');
            continue;
          }

          // Map parent folder ID
          int? newParentId;
          if (folder.parentFolderId != null) {
            newParentId = folderIdMap[folder.parentFolderId];
          }

          // Insert folder
          final newId = await DatabaseHelper.instance.createFolder(
            folder.copyWith(
              id: null,
              vaultId: newVaultId,
              parentFolderId: newParentId,
            ),
          );

          if (oldId != null) {
            folderIdMap[oldId] = newId;
          }
        }
      }

      onProgress?.call('กำลัง restore files...', 0.5);

      // Read files
      final filesFile = archive.findFile('files.json');
      if (filesFile == null) {
        return RestoreResult(
          success: false,
          error: 'ไฟล์ backup ไม่ถูกต้อง (ไม่พบข้อมูล files)',
        );
      }

      final filesJson = utf8.decode(filesFile.content);
      final fileMaps = List<Map<String, dynamic>>.from(jsonDecode(filesJson));
      final files = fileMaps.map((m) => EncryptedFile.fromMap(m)).toList();

      int restoredFiles = 0;
      int processedFiles = 0;

      for (final file in files) {
        final oldId = file.id;
        final oldVaultId = file.vaultId;

        // Map to new vault ID
        final newVaultId = vaultIdMap[oldVaultId];
        if (newVaultId == null) {
          warnings.add('ข้าม file เนื่องจากไม่พบ vault');
          processedFiles++;
          continue;
        }

        // Map folder ID
        int? newFolderId;
        if (file.folderId != null) {
          newFolderId = folderIdMap[file.folderId];
        }

        // Find encrypted file data in archive
        final archiveFilePath =
            'files/${oldId}_${path.basename(file.encryptedPath)}';
        final archiveFile = archive.findFile(archiveFilePath);

        if (archiveFile == null) {
          warnings.add('ไม่พบไฟล์ encrypted สำหรับ file ID $oldId');
          processedFiles++;
          continue;
        }

        // Create new encrypted path
        final newEncryptedPath = path.join(
          vaultsDir.path,
          '$newVaultId',
          '${DateTime.now().millisecondsSinceEpoch}_$processedFiles.enc',
        );

        // Ensure directory exists
        final fileDir = Directory(path.dirname(newEncryptedPath));
        if (!await fileDir.exists()) {
          await fileDir.create(recursive: true);
        }

        // Write encrypted file
        final encryptedFile = File(newEncryptedPath);
        await encryptedFile.writeAsBytes(archiveFile.content);

        // Insert file record
        await DatabaseHelper.instance.createFile(
          file.copyWith(
            id: null,
            vaultId: newVaultId,
            folderId: newFolderId,
            encryptedPath: newEncryptedPath,
          ),
        );

        restoredFiles++;
        processedFiles++;
        final progress = 0.5 + (processedFiles / files.length) * 0.4;
        onProgress?.call(
            'กำลัง restore ไฟล์ ($processedFiles/${files.length})...',
            progress);
      }

      onProgress?.call('เสร็จสิ้น!', 1.0);

      AppLogger.log(
        'Restore completed: ${vaultIdMap.length} vaults, $restoredFiles files, ${folderIdMap.length} folders',
        tag: _tag,
      );

      return RestoreResult(
        success: true,
        vaultCount: vaultIdMap.length,
        fileCount: restoredFiles,
        folderCount: folderIdMap.length,
        warnings: warnings,
      );
    } catch (e, stack) {
      AppLogger.error('Restore failed', tag: _tag, error: e, stackTrace: stack);
      return RestoreResult(
        success: false,
        error: 'การ restore ล้มเหลว: $e',
      );
    }
  }

  /// Encrypt backup data with password
  Uint8List _encryptBackup(Uint8List data, String password) {
    // Generate salt and derive key
    final salt = CryptoService.generateSalt();
    final key = CryptoService.deriveKey(password, salt);

    // Encrypt data
    final encrypted = CryptoService.encryptData(data, key);

    // Combine: salt (32) + encrypted data (iv + tag + ciphertext)
    final result = BytesBuilder();
    result.add(salt);
    result.add(encrypted.toBytes());

    return result.toBytes();
  }

  /// Decrypt backup data with password
  Uint8List _decryptBackup(Uint8List data, String password) {
    // Extract salt and encrypted data
    final salt = data.sublist(0, 32);
    final encryptedBytes = data.sublist(32);

    // Derive key
    final key = CryptoService.deriveKey(password, Uint8List.fromList(salt));

    // Decrypt
    final encryptedData = EncryptedData.fromBytes(Uint8List.fromList(encryptedBytes));
    return CryptoService.decryptData(encryptedData, key);
  }

  /// Delete backup file
  Future<void> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      AppLogger.error('Delete backup file failed', tag: _tag, error: e);
    }
  }

  /// Get backup file size
  Future<int> getBackupFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
