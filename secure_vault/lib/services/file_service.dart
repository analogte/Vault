import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import '../core/models/encrypted_file.dart';
import '../core/models/file_folder.dart';
import '../core/storage/database_helper.dart';
import '../core/encryption/crypto_isolate.dart';
import '../core/utils/logger.dart';

// Conditional import for IO operations
import 'file_service_io.dart' if (dart.library.html) 'file_service_web.dart'
    as platform_file;

/// Service for managing encrypted files
class FileService {
  static const String _tag = 'FileService';
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Encrypt and save file to vault (cross-platform)
  /// Uses background isolate for encryption to prevent UI blocking
  Future<EncryptedFile> saveFileFromBytes({
    required int vaultId,
    required Uint8List fileBytes,
    required String originalFileName,
    required Uint8List masterKey,
    required String vaultPath,
    int? folderId,
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.0, 'เริ่มการเข้ารหัส...');
    AppLogger.log('Saving file: $originalFileName (${fileBytes.length} bytes)', tag: _tag);

    // Encrypt file content in background isolate (won't freeze UI)
    onProgress?.call(0.1, 'กำลังเข้ารหัสไฟล์...');
    final encryptedBytes = await CryptoIsolate.encryptData(fileBytes, masterKey);
    AppLogger.log('File encrypted', tag: _tag);

    // Encrypt file name (small, sync is fine)
    onProgress?.call(0.4, 'กำลังเข้ารหัสชื่อไฟล์...');
    final encryptedFileName = CryptoIsolate.encryptFileName(originalFileName, masterKey);

    // Get file extension
    final fileExtension = path.extension(originalFileName).toLowerCase().replaceFirst('.', '');
    final fileType = fileExtension.isEmpty ? null : fileExtension;

    // Generate storage path
    final storagePath = _generateStoragePath(vaultPath, encryptedFileName);
    AppLogger.log('Storage path: $storagePath', tag: _tag);

    // Save encrypted file (platform-specific)
    onProgress?.call(0.5, 'กำลังบันทึกไฟล์...');
    await platform_file.saveEncryptedFile(storagePath, encryptedBytes);
    AppLogger.log('Encrypted file saved', tag: _tag);

    // Generate thumbnail if image (skip on web for now)
    String? thumbnailPath;
    if (!kIsWeb && _isImageFile(fileType)) {
      onProgress?.call(0.7, 'กำลังสร้าง Thumbnail...');
      thumbnailPath = await platform_file.generateThumbnail(
        fileBytes,
        vaultPath,
        encryptedFileName,
      );
    }

    // Create encrypted file record
    onProgress?.call(0.9, 'กำลังบันทึกลงฐานข้อมูล...');
    final encryptedFile = EncryptedFile(
      vaultId: vaultId,
      encryptedName: encryptedFileName,
      encryptedPath: storagePath,
      fileType: fileType,
      size: fileBytes.length,
      createdAt: DateTime.now(),
      thumbnailPath: thumbnailPath,
      folderId: folderId,
    );

    // Save to database
    final id = await _db.createFile(encryptedFile);
    AppLogger.log('File saved to database with ID: $id', tag: _tag);

    onProgress?.call(1.0, 'เสร็จสิ้น');
    return encryptedFile.copyWith(id: id);
  }

  /// Decrypt and retrieve file content
  /// Uses background isolate for decryption to prevent UI blocking
  Future<Uint8List> getFileContent(EncryptedFile file, Uint8List masterKey) async {
    // Read encrypted file (platform-specific)
    final encryptedBytes = await platform_file.readEncryptedFile(file.encryptedPath);

    // Decrypt file content in background isolate (won't freeze UI)
    return await CryptoIsolate.decryptData(encryptedBytes, masterKey);
  }

  /// Decrypt and retrieve file content, also track as recent access
  Future<Uint8List> getFileContentWithTracking(
    EncryptedFile file,
    Uint8List masterKey, {
    bool trackAccess = true,
  }) async {
    // Track file access for recent files feature
    if (trackAccess && file.id != null) {
      try {
        await _db.trackFileAccess(file.id!, file.vaultId);
      } catch (e) {
        AppLogger.warning('Failed to track file access', tag: _tag);
      }
    }

    // Read encrypted file (platform-specific)
    final encryptedBytes = await platform_file.readEncryptedFile(file.encryptedPath);

    // Decrypt file content in background isolate (won't freeze UI)
    return await CryptoIsolate.decryptData(encryptedBytes, masterKey);
  }

  /// Get recent files for a vault
  Future<List<EncryptedFile>> getRecentFiles(int vaultId, {int limit = 10}) async {
    return await _db.getRecentFiles(vaultId, limit: limit);
  }

  /// Clear recent files for a vault
  Future<void> clearRecentFiles(int vaultId) async {
    await _db.clearRecentFiles(vaultId);
  }

  /// Get decrypted file name
  String getFileName(EncryptedFile file, Uint8List masterKey) {
    return CryptoIsolate.decryptFileName(file.encryptedName, masterKey);
  }

  /// Get all files in vault
  Future<List<EncryptedFile>> getFiles(int vaultId) async {
    return await _db.getFilesByVault(vaultId);
  }

  /// Get all image files in vault
  Future<List<EncryptedFile>> getImageFiles(int vaultId) async {
    return await _db.getImageFilesByVault(vaultId);
  }

  // --- Folder Operations ---

  /// Create a new folder
  Future<FileFolder> createFolder({
    required int vaultId,
    required String name,
    required Uint8List masterKey,
    int? parentFolderId,
  }) async {
    // Encrypt folder name
    final encryptedName = CryptoIsolate.encryptFileName(name, masterKey);

    final folder = FileFolder(
      vaultId: vaultId,
      encryptedName: encryptedName,
      parentFolderId: parentFolderId,
      createdAt: DateTime.now(),
    );

    final id = await _db.createFolder(folder);
    AppLogger.log('Folder created with ID: $id', tag: _tag);

    return folder.copyWith(id: id);
  }

  /// Get folders in vault
  Future<List<FileFolder>> getFolders(int vaultId, int? parentFolderId) async {
    return await _db.getFoldersByVault(vaultId, parentFolderId: parentFolderId);
  }

  /// Get decrypted folder name
  String getFolderName(FileFolder folder, Uint8List masterKey) {
    return CryptoIsolate.decryptFileName(folder.encryptedName, masterKey);
  }

  /// Move file to folder
  Future<bool> moveFileToFolder(int fileId, int? folderId) async {
    try {
      await _db.moveFileToFolder(fileId, folderId);
      AppLogger.log('File $fileId moved to folder $folderId', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Move file to folder error', tag: _tag, error: e);
      return false;
    }
  }

  /// Rename folder
  Future<bool> renameFolder(FileFolder folder, String newName, Uint8List masterKey) async {
    try {
      final encryptedName = CryptoIsolate.encryptFileName(newName, masterKey);
      final updatedFolder = folder.copyWith(
        encryptedName: encryptedName,
        modifiedAt: DateTime.now(),
      );
      await _db.updateFolder(updatedFolder);
      return true;
    } catch (e) {
      AppLogger.error('Rename folder error', tag: _tag, error: e);
      return false;
    }
  }

  /// Delete folder
  Future<bool> deleteFolder(int folderId) async {
    try {
      await _db.deleteFolder(folderId);
      AppLogger.log('Folder deleted: $folderId', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Delete folder error', tag: _tag, error: e);
      return false;
    }
  }

  // --- File Operations ---

  /// Soft delete file (move to trash)
  Future<bool> moveToTrash(EncryptedFile file) async {
    try {
      if (file.id == null) return false;
      await _db.softDeleteFile(file.id!);
      AppLogger.log('File moved to trash: ${file.id}', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Move to trash error', tag: _tag, error: e);
      return false;
    }
  }

  /// Restore file from trash
  Future<bool> restoreFromTrash(EncryptedFile file) async {
    try {
      if (file.id == null) return false;
      await _db.restoreFile(file.id!);
      AppLogger.log('File restored: ${file.id}', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Restore error', tag: _tag, error: e);
      return false;
    }
  }

  /// Permanently delete file
  Future<bool> deleteFile(EncryptedFile file) async {
    try {
      // Delete encrypted file (platform-specific)
      await platform_file.deleteEncryptedFile(file.encryptedPath);

      // Delete thumbnail if exists
      if (file.thumbnailPath != null) {
        await platform_file.deleteEncryptedFile(file.thumbnailPath!);
      }

      // Delete from database
      if (file.id != null) {
        await _db.deleteFile(file.id!);
      }

      return true;
    } catch (e) {
      AppLogger.error('Delete error', tag: _tag, error: e);
      return false;
    }
  }

  /// Get trash files
  Future<List<EncryptedFile>> getTrashFiles(int vaultId) async {
    return await _db.getTrashFilesByVault(vaultId);
  }

  /// Get trash count
  Future<int> getTrashCount() async {
    return await _db.getTrashCount();
  }

  /// Generate obfuscated storage path
  String _generateStoragePath(String vaultPath, String encryptedFileName) {
    final hash = encryptedFileName.hashCode;
    final dir1 = (hash.abs() % 256).toRadixString(16).padLeft(2, '0');
    final dir2 = ((hash.abs() ~/ 256) % 256).toRadixString(16).padLeft(2, '0');
    return path.join(vaultPath, 'd', dir1, dir2, encryptedFileName);
  }

  /// Check if file is image
  bool _isImageFile(String? fileType) {
    if (fileType == null) return false;
    final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    return imageTypes.contains(fileType.toLowerCase());
  }
}

extension EncryptedFileExtension on EncryptedFile {
  EncryptedFile copyWith({
    int? id,
    int? vaultId,
    String? encryptedName,
    String? encryptedPath,
    String? fileType,
    int? size,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? thumbnailPath,
    int? folderId,
  }) {
    return EncryptedFile(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      encryptedName: encryptedName ?? this.encryptedName,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      fileType: fileType ?? this.fileType,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      folderId: folderId ?? this.folderId,
    );
  }
}
