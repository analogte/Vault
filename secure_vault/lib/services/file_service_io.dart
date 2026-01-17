import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../core/utils/logger.dart';

/// Platform-specific file operations for mobile/desktop (dart:io)

const String _tag = 'FileServiceIO';

/// Save encrypted file to disk
Future<void> saveEncryptedFile(String filePath, Uint8List data) async {
  final file = File(filePath);

  // Create directory if it doesn't exist
  final directory = file.parent;
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  await file.writeAsBytes(data);
}

/// Read encrypted file from disk
Future<Uint8List> readEncryptedFile(String filePath) async {
  final file = File(filePath);
  return await file.readAsBytes();
}

/// Delete encrypted file from disk
Future<void> deleteEncryptedFile(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    await file.delete();
  }
}

/// Parameters for thumbnail generation in isolate
class _ThumbnailParams {
  final Uint8List imageBytes;
  final int width;
  final int height;
  final int quality;

  _ThumbnailParams({
    required this.imageBytes,
    this.width = 200,
    this.height = 200,
    this.quality = 75,
  });
}

/// Result from thumbnail generation
class _ThumbnailResult {
  final Uint8List? bytes;
  final String? error;

  _ThumbnailResult({this.bytes, this.error});
}

/// Top-level function for thumbnail generation (required for compute)
_ThumbnailResult _generateThumbnailInIsolate(_ThumbnailParams params) {
  try {
    // Decode image (this is CPU intensive)
    final image = img.decodeImage(params.imageBytes);
    if (image == null) {
      return _ThumbnailResult(error: 'Failed to decode image');
    }

    // Calculate resize dimensions maintaining aspect ratio
    int targetWidth = params.width;
    int targetHeight = params.height;

    final aspectRatio = image.width / image.height;
    if (aspectRatio > 1) {
      // Landscape
      targetHeight = (targetWidth / aspectRatio).round();
    } else {
      // Portrait or square
      targetWidth = (targetHeight * aspectRatio).round();
    }

    // Resize to thumbnail (faster interpolation for thumbnails)
    final thumbnail = img.copyResize(
      image,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.average,
    );

    // Encode as JPEG with specified quality
    final thumbnailBytes = img.encodeJpg(thumbnail, quality: params.quality);

    return _ThumbnailResult(bytes: Uint8List.fromList(thumbnailBytes));
  } catch (e) {
    return _ThumbnailResult(error: e.toString());
  }
}

/// Generate thumbnail for image file
/// Uses compute() to run in isolate, preventing UI freeze
Future<String?> generateThumbnail(
  Uint8List imageBytes,
  String vaultPath,
  String encryptedFileName,
) async {
  try {
    // Generate thumbnail in background isolate
    final result = await compute(
      _generateThumbnailInIsolate,
      _ThumbnailParams(
        imageBytes: imageBytes,
        width: 200,
        height: 200,
        quality: 75,
      ),
    );

    if (result.bytes == null) {
      AppLogger.error('Thumbnail generation failed: ${result.error}', tag: _tag);
      return null;
    }

    // Save thumbnail to disk
    final thumbnailDir = path.join(vaultPath, 'thumbnails');
    final thumbnailPath = path.join(thumbnailDir, '${encryptedFileName}_thumb.jpg');

    await saveEncryptedFile(thumbnailPath, result.bytes!);
    AppLogger.log('Thumbnail saved: $thumbnailPath', tag: _tag);

    return thumbnailPath;
  } catch (e) {
    AppLogger.error('Thumbnail generation error', tag: _tag, error: e);
    return null;
  }
}

/// Generate thumbnail synchronously (for when isolate is not available)
Uint8List? generateThumbnailSync(Uint8List imageBytes) {
  final result = _generateThumbnailInIsolate(_ThumbnailParams(
    imageBytes: imageBytes,
    width: 200,
    height: 200,
    quality: 75,
  ));
  return result.bytes;
}
