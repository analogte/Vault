// File operations utilities for Search, Sort, and Filter

import '../../../core/models/encrypted_file.dart';

/// Sort types for file listing
enum SortType {
  dateNewest,  // ล่าสุด (default)
  dateOldest,  // เก่าสุด
  nameAsc,     // ชื่อ ก-ฮ
  nameDesc,    // ชื่อ ฮ-ก
  sizeSmall,   // เล็กสุด
  sizeLarge,   // ใหญ่สุด
}

/// File type filter options
enum FileTypeFilter {
  all,        // ทั้งหมด
  images,     // รูปภาพ
  documents,  // เอกสาร (pdf, doc, txt)
  videos,     // วิดีโอ
  audio,      // เสียง
}

/// Extension methods for SortType
extension SortTypeExtension on SortType {
  String get label {
    switch (this) {
      case SortType.dateNewest:
        return 'ล่าสุดก่อน';
      case SortType.dateOldest:
        return 'เก่าสุดก่อน';
      case SortType.nameAsc:
        return 'ชื่อ ก-ฮ';
      case SortType.nameDesc:
        return 'ชื่อ ฮ-ก';
      case SortType.sizeSmall:
        return 'ขนาดเล็กก่อน';
      case SortType.sizeLarge:
        return 'ขนาดใหญ่ก่อน';
    }
  }
}

/// Extension methods for FileTypeFilter
extension FileTypeFilterExtension on FileTypeFilter {
  String get label {
    switch (this) {
      case FileTypeFilter.all:
        return 'ทั้งหมด';
      case FileTypeFilter.images:
        return 'รูปภาพ';
      case FileTypeFilter.documents:
        return 'เอกสาร';
      case FileTypeFilter.videos:
        return 'วิดีโอ';
      case FileTypeFilter.audio:
        return 'เสียง';
    }
  }
}

/// File operations helper class
class FileOperations {
  // Image file extensions
  static const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];

  // Document file extensions
  static const documentExtensions = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'];

  // Video file extensions
  static const videoExtensions = ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm'];

  // Audio file extensions
  static const audioExtensions = ['mp3', 'wav', 'flac', 'aac', 'm4a', 'ogg', 'wma'];

  /// Filter files by search query and decrypted names
  static List<EncryptedFile> filterBySearch(
    List<EncryptedFile> files,
    String query,
    Map<int, String> decryptedNames,
  ) {
    if (query.isEmpty) return files;

    final lowerQuery = query.toLowerCase();
    return files.where((file) {
      final name = decryptedNames[file.id]?.toLowerCase() ?? '';
      return name.contains(lowerQuery);
    }).toList();
  }

  /// Filter files by file type
  static List<EncryptedFile> filterByType(
    List<EncryptedFile> files,
    FileTypeFilter filter,
  ) {
    if (filter == FileTypeFilter.all) return files;

    return files.where((file) {
      final ext = file.fileType?.toLowerCase() ?? '';
      switch (filter) {
        case FileTypeFilter.all:
          return true;
        case FileTypeFilter.images:
          return imageExtensions.contains(ext);
        case FileTypeFilter.documents:
          return documentExtensions.contains(ext);
        case FileTypeFilter.videos:
          return videoExtensions.contains(ext);
        case FileTypeFilter.audio:
          return audioExtensions.contains(ext);
      }
    }).toList();
  }

  /// Sort files by the specified sort type
  static List<EncryptedFile> sortFiles(
    List<EncryptedFile> files,
    SortType sortType,
    Map<int, String> decryptedNames,
  ) {
    final sortedFiles = List<EncryptedFile>.from(files);

    switch (sortType) {
      case SortType.dateNewest:
        sortedFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.dateOldest:
        sortedFiles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortType.nameAsc:
        sortedFiles.sort((a, b) {
          final nameA = decryptedNames[a.id]?.toLowerCase() ?? '';
          final nameB = decryptedNames[b.id]?.toLowerCase() ?? '';
          return nameA.compareTo(nameB);
        });
        break;
      case SortType.nameDesc:
        sortedFiles.sort((a, b) {
          final nameA = decryptedNames[a.id]?.toLowerCase() ?? '';
          final nameB = decryptedNames[b.id]?.toLowerCase() ?? '';
          return nameB.compareTo(nameA);
        });
        break;
      case SortType.sizeSmall:
        sortedFiles.sort((a, b) => a.size.compareTo(b.size));
        break;
      case SortType.sizeLarge:
        sortedFiles.sort((a, b) => b.size.compareTo(a.size));
        break;
    }

    return sortedFiles;
  }

  /// Apply all filters and sorting
  static List<EncryptedFile> applyFiltersAndSort({
    required List<EncryptedFile> files,
    required String searchQuery,
    required FileTypeFilter typeFilter,
    required SortType sortType,
    required Map<int, String> decryptedNames,
  }) {
    // 1. Filter by type first (most restrictive)
    var result = filterByType(files, typeFilter);

    // 2. Filter by search query
    result = filterBySearch(result, searchQuery, decryptedNames);

    // 3. Sort the result
    result = sortFiles(result, sortType, decryptedNames);

    return result;
  }

  /// Check if file matches a specific type category
  static bool isImageFile(String? fileType) {
    if (fileType == null) return false;
    return imageExtensions.contains(fileType.toLowerCase());
  }

  static bool isDocumentFile(String? fileType) {
    if (fileType == null) return false;
    return documentExtensions.contains(fileType.toLowerCase());
  }

  static bool isVideoFile(String? fileType) {
    if (fileType == null) return false;
    return videoExtensions.contains(fileType.toLowerCase());
  }

  static bool isAudioFile(String? fileType) {
    if (fileType == null) return false;
    return audioExtensions.contains(fileType.toLowerCase());
  }
}
