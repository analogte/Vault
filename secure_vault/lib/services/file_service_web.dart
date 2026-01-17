import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../core/utils/logger.dart';

/// Platform-specific file operations for web
/// Uses LRU cache with memory limit to prevent OOM

const String _tag = 'FileServiceWeb';
const String _storageTag = 'WebFileStorage';

/// LRU Cache entry with access timestamp
class _CacheEntry {
  final Uint8List data;
  DateTime lastAccess;

  _CacheEntry(this.data) : lastAccess = DateTime.now();

  void touch() {
    lastAccess = DateTime.now();
  }

  int get size => data.length;
}

/// In-memory file storage with LRU eviction for web platform
class _WebFileStorage {
  final Map<String, _CacheEntry> _cache = {};

  // Maximum cache size: 500MB (adjust based on typical usage)
  static const int maxCacheSize = 500 * 1024 * 1024;

  // Maximum entries (to prevent too many small files)
  static const int maxEntries = 1000;

  int _currentSize = 0;

  /// Get current cache size in bytes
  int get currentSize => _currentSize;

  /// Get number of entries
  int get entryCount => _cache.length;

  /// Store file in cache
  void set(String path, Uint8List data) {
    // Remove existing entry if present
    if (_cache.containsKey(path)) {
      _currentSize -= _cache[path]!.size;
      _cache.remove(path);
    }

    // Evict old entries if needed
    _evictIfNeeded(data.length);

    // Add new entry
    _cache[path] = _CacheEntry(data);
    _currentSize += data.length;

    AppLogger.log('Stored: $path (${_formatSize(data.length)}) - Cache: ${_formatSize(_currentSize)} / ${_formatSize(maxCacheSize)}', tag: _storageTag);
  }

  /// Get file from cache
  Uint8List? get(String path) {
    final entry = _cache[path];
    if (entry != null) {
      entry.touch(); // Update last access time
      return entry.data;
    }
    return null;
  }

  /// Remove file from cache
  void remove(String path) {
    final entry = _cache.remove(path);
    if (entry != null) {
      _currentSize -= entry.size;
      AppLogger.log('Removed: $path - Cache: ${_formatSize(_currentSize)}', tag: _storageTag);
    }
  }

  /// Clear all files from cache
  void clear() {
    _cache.clear();
    _currentSize = 0;
    AppLogger.log('Cache cleared', tag: _storageTag);
  }

  /// Evict least recently used entries to make room for new data
  void _evictIfNeeded(int newDataSize) {
    // Check if we need to evict
    while ((_currentSize + newDataSize > maxCacheSize || _cache.length >= maxEntries) && _cache.isNotEmpty) {
      // Find least recently used entry
      String? lruPath;
      DateTime? lruTime;

      for (final entry in _cache.entries) {
        if (lruTime == null || entry.value.lastAccess.isBefore(lruTime)) {
          lruPath = entry.key;
          lruTime = entry.value.lastAccess;
        }
      }

      if (lruPath != null) {
        final evictedSize = _cache[lruPath]!.size;
        _cache.remove(lruPath);
        _currentSize -= evictedSize;
        AppLogger.log('Evicted LRU: $lruPath (${_formatSize(evictedSize)})', tag: _storageTag);
      } else {
        break;
      }
    }
  }

  /// Format size for logging
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get all stored file paths (for debugging)
  List<String> getAllPaths() => _cache.keys.toList();
}

// Global instance
final _WebFileStorage _webFileStorage = _WebFileStorage();

/// Save encrypted file to in-memory storage with LRU eviction
Future<void> saveEncryptedFile(String filePath, Uint8List data) async {
  AppLogger.log('Saving file to memory: $filePath (${data.length} bytes)', tag: _tag);
  _webFileStorage.set(filePath, data);
}

/// Read encrypted file from in-memory storage
Future<Uint8List> readEncryptedFile(String filePath) async {
  AppLogger.log('Reading file from memory: $filePath', tag: _tag);
  final data = _webFileStorage.get(filePath);
  if (data == null) {
    throw Exception('File not found in cache: $filePath');
  }
  return data;
}

/// Delete encrypted file from in-memory storage
Future<void> deleteEncryptedFile(String filePath) async {
  AppLogger.log('Deleting file from memory: $filePath', tag: _tag);
  _webFileStorage.remove(filePath);
}

/// Generate thumbnail for image file (web version)
Future<String?> generateThumbnail(
  Uint8List imageBytes,
  String vaultPath,
  String encryptedFileName,
) async {
  try {
    // Decode image
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // Resize to thumbnail (150x150)
    final thumbnail = img.copyResize(
      image,
      width: 150,
      height: 150,
      maintainAspect: true,
    );

    // Encode as JPEG
    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);

    // Save thumbnail to memory
    final thumbnailPath = '$vaultPath/thumbnails/${encryptedFileName}_thumb.jpg';
    await saveEncryptedFile(thumbnailPath, Uint8List.fromList(thumbnailBytes));

    return thumbnailPath;
  } catch (e) {
    AppLogger.error('Thumbnail generation error', tag: _tag, error: e);
    return null;
  }
}

/// Get all stored file paths (for debugging)
List<String> getAllStoredPaths() {
  return _webFileStorage.getAllPaths();
}

/// Clear all stored files (for cleanup)
void clearAllFiles() {
  _webFileStorage.clear();
}

/// Get cache statistics
Map<String, dynamic> getCacheStats() {
  return {
    'currentSize': _webFileStorage.currentSize,
    'entryCount': _webFileStorage.entryCount,
    'maxSize': _WebFileStorage.maxCacheSize,
    'maxEntries': _WebFileStorage.maxEntries,
  };
}
