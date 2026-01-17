import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/models/encrypted_file.dart';
import 'file_service.dart';

/// Thumbnail loading task
class _LoadTask {
  final EncryptedFile file;
  final Uint8List masterKey;
  final Completer<Uint8List?> completer;
  bool cancelled = false;

  _LoadTask({
    required this.file,
    required this.masterKey,
  }) : completer = Completer<Uint8List?>();

  void cancel() {
    cancelled = true;
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  }
}

/// Singleton thumbnail loader with concurrent limit and caching
class ThumbnailLoader {
  static final ThumbnailLoader _instance = ThumbnailLoader._internal();
  factory ThumbnailLoader() => _instance;
  ThumbnailLoader._internal();

  // Maximum concurrent loads
  static const int maxConcurrent = 3;

  // Memory cache for loaded thumbnails
  final Map<int, Uint8List> _cache = {};
  static const int maxCacheSize = 100;

  // Pending tasks queue
  final Queue<_LoadTask> _pendingQueue = Queue();

  // Currently loading count
  int _activeLoads = 0;

  // File service reference (lazy initialized)
  FileService? _fileService;

  /// Set file service reference
  void setFileService(FileService service) {
    _fileService = service;
  }

  /// Load thumbnail with caching and throttling
  Future<Uint8List?> loadThumbnail(
    EncryptedFile file,
    Uint8List masterKey,
    FileService fileService,
  ) async {
    _fileService = fileService;

    // Check cache first
    if (file.id != null && _cache.containsKey(file.id)) {
      return _cache[file.id];
    }

    // Create load task
    final task = _LoadTask(file: file, masterKey: masterKey);
    _pendingQueue.add(task);

    // Try to start processing
    _processQueue();

    return task.completer.future;
  }

  /// Cancel pending load for a file
  void cancelLoad(int? fileId) {
    if (fileId == null) return;

    // Find and cancel pending task
    for (final task in _pendingQueue) {
      if (task.file.id == fileId && !task.cancelled) {
        task.cancel();
        break;
      }
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Process pending queue
  void _processQueue() {
    while (_activeLoads < maxConcurrent && _pendingQueue.isNotEmpty) {
      final task = _pendingQueue.removeFirst();

      // Skip cancelled tasks
      if (task.cancelled) continue;

      _activeLoads++;
      _loadThumbnailTask(task);
    }
  }

  /// Execute a single load task
  Future<void> _loadThumbnailTask(_LoadTask task) async {
    try {
      if (task.cancelled) {
        _activeLoads--;
        _processQueue();
        return;
      }

      Uint8List? bytes;

      // Try to load from thumbnail file first
      if (!kIsWeb && task.file.thumbnailPath != null) {
        final thumbnailFile = File(task.file.thumbnailPath!);
        if (await thumbnailFile.exists()) {
          bytes = await thumbnailFile.readAsBytes();
        }
      }

      // Check if cancelled during I/O
      if (task.cancelled) {
        _activeLoads--;
        _processQueue();
        return;
      }

      // Fallback: load full image if no thumbnail
      if (bytes == null && _fileService != null) {
        bytes = await _fileService!.getFileContent(task.file, task.masterKey);
      }

      // Cache the result
      if (bytes != null && task.file.id != null) {
        _addToCache(task.file.id!, bytes);
      }

      // Complete the task
      if (!task.completer.isCompleted) {
        task.completer.complete(bytes);
      }
    } catch (e) {
      if (!task.completer.isCompleted) {
        task.completer.complete(null);
      }
    } finally {
      _activeLoads--;
      _processQueue();
    }
  }

  /// Add to cache with LRU eviction
  void _addToCache(int fileId, Uint8List bytes) {
    // Evict oldest if cache is full
    while (_cache.length >= maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[fileId] = bytes;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    int totalSize = 0;
    for (final bytes in _cache.values) {
      totalSize += bytes.length;
    }
    return {
      'entries': _cache.length,
      'totalSize': totalSize,
      'pendingTasks': _pendingQueue.length,
      'activeLoads': _activeLoads,
    };
  }
}
