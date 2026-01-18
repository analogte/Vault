import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/logger.dart';

/// Service for sharing decrypted files
class ShareService {
  static const String _tag = 'ShareService';

  /// Share a single file
  /// Decrypts and saves to temp, then shares via system share sheet
  Future<void> shareFile({
    required Uint8List decryptedData,
    required String fileName,
    String? mimeType,
  }) async {
    File? tempFile;
    try {
      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/share_$fileName';
      tempFile = File(tempPath);
      await tempFile.writeAsBytes(decryptedData);

      AppLogger.log('Sharing file: $fileName', tag: _tag);

      // Share using share_plus
      final result = await Share.shareXFiles(
        [XFile(tempPath, mimeType: mimeType)],
        subject: fileName,
      );

      AppLogger.log('Share result: ${result.status}', tag: _tag);

      // Clean up temp file after a delay (to allow sharing to complete)
      _scheduleCleanup(tempFile);
    } catch (e) {
      AppLogger.error('Share error', tag: _tag, error: e);
      // Clean up on error
      try { tempFile?.delete(); } catch (_) {}
      rethrow;
    }
  }

  /// Share multiple files
  Future<void> shareFiles({
    required List<({Uint8List data, String fileName})> files,
  }) async {
    final tempFiles = <File>[];
    try {
      final tempDir = await getTemporaryDirectory();
      final xFiles = <XFile>[];

      for (final file in files) {
        final tempPath = '${tempDir.path}/share_${file.fileName}';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(file.data);
        tempFiles.add(tempFile);
        xFiles.add(XFile(tempPath));
      }

      AppLogger.log('Sharing ${files.length} files', tag: _tag);

      final result = await Share.shareXFiles(
        xFiles,
        subject: files.length == 1 ? files.first.fileName : '${files.length} files',
      );

      AppLogger.log('Share result: ${result.status}', tag: _tag);

      // Clean up temp files
      for (final tempFile in tempFiles) {
        _scheduleCleanup(tempFile);
      }
    } catch (e) {
      AppLogger.error('Share multiple error', tag: _tag, error: e);
      // Clean up on error
      for (final tempFile in tempFiles) {
        tempFile.delete().then((_) {}).catchError((_) {});
      }
      rethrow;
    }
  }

  /// Schedule cleanup of temp file after delay
  void _scheduleCleanup(File file) {
    Future.delayed(const Duration(minutes: 5), () async {
      try {
        await file.delete();
      } catch (e) {
        AppLogger.warning('Failed to delete temp share file', tag: _tag);
      }
    });
  }

  /// Get MIME type from file extension
  String? getMimeType(String? fileType) {
    if (fileType == null) return null;
    final ext = fileType.toLowerCase();

    // Images
    if (['jpg', 'jpeg'].contains(ext)) return 'image/jpeg';
    if (ext == 'png') return 'image/png';
    if (ext == 'gif') return 'image/gif';
    if (ext == 'webp') return 'image/webp';
    if (ext == 'bmp') return 'image/bmp';
    if (['heic', 'heif'].contains(ext)) return 'image/heic';

    // Videos
    if (ext == 'mp4') return 'video/mp4';
    if (ext == 'mov') return 'video/quicktime';
    if (ext == 'avi') return 'video/x-msvideo';
    if (ext == 'mkv') return 'video/x-matroska';
    if (ext == 'webm') return 'video/webm';

    // Audio
    if (ext == 'mp3') return 'audio/mpeg';
    if (ext == 'wav') return 'audio/wav';
    if (ext == 'aac') return 'audio/aac';
    if (ext == 'flac') return 'audio/flac';
    if (ext == 'm4a') return 'audio/mp4';
    if (ext == 'ogg') return 'audio/ogg';

    // Documents
    if (ext == 'pdf') return 'application/pdf';
    if (ext == 'doc') return 'application/msword';
    if (ext == 'docx') return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    if (ext == 'xls') return 'application/vnd.ms-excel';
    if (ext == 'xlsx') return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    if (ext == 'ppt') return 'application/vnd.ms-powerpoint';
    if (ext == 'pptx') return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    if (ext == 'txt') return 'text/plain';
    if (ext == 'csv') return 'text/csv';
    if (ext == 'json') return 'application/json';
    if (ext == 'xml') return 'application/xml';

    // Archives
    if (ext == 'zip') return 'application/zip';
    if (ext == 'rar') return 'application/x-rar-compressed';
    if (ext == '7z') return 'application/x-7z-compressed';

    return 'application/octet-stream';
  }
}
