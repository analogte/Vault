import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../core/models/encrypted_file.dart';
import '../core/storage/database_helper.dart';
import '../core/encryption/crypto_service.dart';

/// Service for managing encrypted files
class FileService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Encrypt and save file to vault
  Future<EncryptedFile> saveFile({
    required int vaultId,
    required File file,
    required String originalFileName,
    required Uint8List masterKey,
    required String vaultPath,
  }) async {
    // Read file content
    final fileBytes = await file.readAsBytes();

    // Encrypt file content
    final encryptedData = CryptoService.encryptData(fileBytes, masterKey);

    // Encrypt file name
    final encryptedFileName = CryptoService.encryptFileName(originalFileName, masterKey);

    // Get file extension
    final fileExtension = path.extension(originalFileName).toLowerCase().replaceFirst('.', '');
    final fileType = fileExtension.isEmpty ? null : fileExtension;

    // Generate storage path (obfuscated directory structure)
    final storagePath = _generateStoragePath(vaultPath, encryptedFileName);

    // Create directory if needed
    final storageFile = File(storagePath);
    await storageFile.parent.create(recursive: true);

    // Write encrypted file
    await storageFile.writeAsBytes(encryptedData.toBytes());

    // Generate thumbnail if image
    String? thumbnailPath;
    if (_isImageFile(fileType)) {
      thumbnailPath = await _generateThumbnail(fileBytes, vaultPath, encryptedFileName);
    }

    // Create encrypted file record
    final encryptedFile = EncryptedFile(
      vaultId: vaultId,
      encryptedName: encryptedFileName,
      encryptedPath: storagePath,
      fileType: fileType,
      size: fileBytes.length,
      createdAt: DateTime.now(),
      thumbnailPath: thumbnailPath,
    );

    // Save to database
    final id = await _db.createFile(encryptedFile);
    return encryptedFile.copyWith(id: id);
  }

  /// Decrypt and retrieve file
  Future<Uint8List> getFileContent(EncryptedFile file, Uint8List masterKey) async {
    // Read encrypted file
    final encryptedFile = File(file.encryptedPath);
    if (!await encryptedFile.exists()) {
      throw Exception('File not found');
    }

    final encryptedBytes = await encryptedFile.readAsBytes();
    final encryptedData = EncryptedData.fromBytes(encryptedBytes);

    // Decrypt file content
    return CryptoService.decryptData(encryptedData, masterKey);
  }

  /// Get decrypted file name
  String getFileName(EncryptedFile file, Uint8List masterKey) {
    return CryptoService.decryptFileName(file.encryptedName, masterKey);
  }

  /// Get all files in vault
  Future<List<EncryptedFile>> getFiles(int vaultId) async {
    return await _db.getFilesByVault(vaultId);
  }

  /// Get all image files in vault
  Future<List<EncryptedFile>> getImageFiles(int vaultId) async {
    return await _db.getImageFilesByVault(vaultId);
  }

  /// Delete file
  Future<bool> deleteFile(EncryptedFile file) async {
    try {
      // Delete encrypted file
      final encryptedFile = File(file.encryptedPath);
      if (await encryptedFile.exists()) {
        await encryptedFile.delete();
      }

      // Delete thumbnail if exists
      if (file.thumbnailPath != null) {
        final thumbnailFile = File(file.thumbnailPath!);
        if (await thumbnailFile.exists()) {
          await thumbnailFile.delete();
        }
      }

      // Delete from database
      if (file.id != null) {
        await _db.deleteFile(file.id!);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate obfuscated storage path
  String _generateStoragePath(String vaultPath, String encryptedFileName) {
    // Create directory structure like: d/00/00/filename
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

  /// Generate thumbnail for image
  Future<String?> _generateThumbnail(
    Uint8List imageBytes,
    String vaultPath,
    String encryptedFileName,
  ) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Calculate thumbnail size (max 200px)
      final maxSize = 200;
      int width = image.width;
      int height = image.height;

      if (width > height) {
        if (width > maxSize) {
          height = (height * maxSize / width).round();
          width = maxSize;
        }
      } else {
        if (height > maxSize) {
          width = (width * maxSize / height).round();
          height = maxSize;
        }
      }

      // Resize image
      final thumbnail = img.copyResize(image, width: width, height: height);

      // Encode as JPEG
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 85);

      // Save thumbnail
      final thumbnailDir = Directory(path.join(vaultPath, 'thumbnails'));
      await thumbnailDir.create(recursive: true);
      final thumbnailPath = path.join(thumbnailDir.path, encryptedFileName);
      await File(thumbnailPath).writeAsBytes(thumbnailBytes);

      return thumbnailPath;
    } catch (e) {
      return null;
    }
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
    );
  }
}
