import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/models/vault.dart';
import '../../../core/models/encrypted_file.dart';
import '../../../core/models/file_folder.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/file_service.dart';
import '../widgets/file_list_widget.dart';
import '../widgets/gallery_view_widget.dart';
import '../widgets/upload_progress_dialog.dart';
import '../widgets/folder_breadcrumb.dart';
import '../widgets/folder_card.dart';
import '../widgets/create_folder_dialog.dart';
import '../widgets/move_to_folder_dialog.dart';
import '../widgets/multi_select_toolbar.dart';
import '../widgets/recent_files_section.dart';
import '../widgets/image_viewer_dialog.dart';
import '../widgets/pdf_viewer_screen.dart';
import '../widgets/video_viewer_screen.dart';
import '../utils/file_operations.dart';

// Conditional import for file reading
import 'file_reader_io.dart' if (dart.library.html) 'file_reader_web.dart'
    as file_reader;

/// File data holder for cross-platform compatibility
class FileData {
  final String name;
  final Uint8List bytes;
  final String? originalPath; // For potential deletion after upload

  FileData({required this.name, required this.bytes, this.originalPath});
}

class FileManagerScreen extends StatefulWidget {
  final Vault vault;
  final Uint8List masterKey;

  const FileManagerScreen({
    super.key,
    required this.vault,
    required this.masterKey,
  });

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen>
    with SingleTickerProviderStateMixin {
  static const String _tag = 'FileManagerScreen';
  late TabController _tabController;
  List<EncryptedFile> _files = [];
  List<FileFolder> _folders = [];
  bool _isLoading = true;

  // Race condition prevention: version counter
  int _loadVersion = 0;

  // Search, Sort, Filter state
  bool _isSearching = false;
  String _searchQuery = '';
  SortType _sortType = SortType.dateNewest;
  FileTypeFilter _typeFilter = FileTypeFilter.all;
  final TextEditingController _searchController = TextEditingController();

  // Decrypted file names cache for performance
  Map<int, String> _decryptedNames = {};

  // Folder navigation state
  int? _currentFolderId;
  List<FileFolder> _folderPath = []; // Breadcrumb path

  // Multi-select state
  final Set<int> _selectedFileIds = {};
  final Set<int> _selectedFolderIds = {};
  bool get _isMultiSelectMode =>
      _selectedFileIds.isNotEmpty || _selectedFolderIds.isNotEmpty;

  // Recent files key for refresh
  final GlobalKey<State<RecentFilesSection>> _recentFilesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    // Increment version to invalidate any pending loads
    final currentVersion = ++_loadVersion;

    setState(() => _isLoading = true);

    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      final files = await fileService.getFiles(widget.vault.id!);
      final folders =
          await fileService.getFolders(widget.vault.id!, _currentFolderId);

      // Cache decrypted names for search/sort
      final decryptedNames = <int, String>{};
      for (final file in files) {
        if (file.id != null) {
          decryptedNames[file.id!] =
              fileService.getFileName(file, widget.masterKey);
        }
      }

      // Only update state if this is still the latest request
      if (mounted && currentVersion == _loadVersion) {
        setState(() {
          _files = files;
          _folders = folders;
          _decryptedNames = decryptedNames;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load files error', tag: _tag, error: e);
      if (mounted && currentVersion == _loadVersion) {
        setState(() => _isLoading = false);
        final l10n = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e')),
        );
      }
    }
  }

  // Get filtered and sorted files for current folder
  List<EncryptedFile> get _filteredFiles {
    // Filter by current folder first
    var filesInFolder = _files
        .where((f) => f.folderId == _currentFolderId)
        .toList();

    // Apply search, filter, and sort
    return FileOperations.applyFiltersAndSort(
      files: filesInFolder,
      searchQuery: _searchQuery,
      typeFilter: _typeFilter,
      sortType: _sortType,
      decryptedNames: _decryptedNames,
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showSortMenu() {
    final l10n = S.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n?.sortBy ?? 'เรียงตาม',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...SortType.values.map((type) => ListTile(
                  leading: Icon(
                    _sortType == type
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _sortType == type
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(_getSortTypeLabel(type, l10n)),
                  onTap: () {
                    setState(() => _sortType = type);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _getSortTypeLabel(SortType type, S? l10n) {
    switch (type) {
      case SortType.dateNewest:
        return l10n?.sortNewest ?? 'ล่าสุดก่อน';
      case SortType.dateOldest:
        return l10n?.sortOldest ?? 'เก่าสุดก่อน';
      case SortType.nameAsc:
        return l10n?.sortNameAZ ?? 'ชื่อ ก-ฮ';
      case SortType.nameDesc:
        return l10n?.sortNameZA ?? 'ชื่อ ฮ-ก';
      case SortType.sizeSmall:
        return l10n?.sortSizeSmall ?? 'ขนาดเล็กก่อน';
      case SortType.sizeLarge:
        return l10n?.sortSizeLarge ?? 'ขนาดใหญ่ก่อน';
    }
  }

  String _getFilterTypeLabel(FileTypeFilter filter, S? l10n) {
    switch (filter) {
      case FileTypeFilter.all:
        return l10n?.filterAll ?? 'ทั้งหมด';
      case FileTypeFilter.images:
        return l10n?.filterImages ?? 'รูปภาพ';
      case FileTypeFilter.documents:
        return l10n?.filterDocuments ?? 'เอกสาร';
      case FileTypeFilter.videos:
        return l10n?.filterVideos ?? 'วิดีโอ';
      case FileTypeFilter.audio:
        return l10n?.filterAudio ?? 'เสียง';
    }
  }

  // Multi-select methods
  void _toggleFileSelection(int fileId) {
    setState(() {
      if (_selectedFileIds.contains(fileId)) {
        _selectedFileIds.remove(fileId);
      } else {
        _selectedFileIds.add(fileId);
      }
    });
  }

  void _toggleFolderSelection(int folderId) {
    setState(() {
      if (_selectedFolderIds.contains(folderId)) {
        _selectedFolderIds.remove(folderId);
      } else {
        _selectedFolderIds.add(folderId);
      }
    });
  }

  void _selectAllFiles() {
    setState(() {
      _selectedFileIds.clear();
      _selectedFileIds.addAll(
        _filteredFiles.where((f) => f.id != null).map((f) => f.id!),
      );
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFileIds.clear();
      _selectedFolderIds.clear();
    });
  }

  Future<void> _deleteSelectedFiles() async {
    if (_selectedFileIds.isEmpty) return;

    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.movedToTrash ?? 'ย้ายไปถังขยะ'),
        content: Text(
          '${l10n?.selectedCount(_selectedFileIds.length) ?? 'เลือก ${_selectedFileIds.length} รายการ'}\n'
          '${l10n?.daysRemaining(30) ?? 'คุณสามารถกู้คืนได้ภายใน 30 วัน'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.movedToTrash ?? 'ย้ายไปถังขยะ'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final fileService = Provider.of<FileService>(context, listen: false);
      int successCount = 0;

      for (final fileId in _selectedFileIds) {
        final file = _files.firstWhere(
          (f) => f.id == fileId,
          orElse: () => _files.first,
        );
        if (file.id == fileId) {
          final success = await fileService.moveToTrash(file);
          if (success) successCount++;
        }
      }

      _clearSelection();
      _loadFiles();

      if (mounted) {
        final l10nAfter = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10nAfter?.movedToTrash ?? 'ย้ายไปถังขยะ'} $successCount ${l10nAfter?.files ?? 'ไฟล์'}'),
          ),
        );
      }
    }
  }

  Future<void> _moveSelectedToFolder() async {
    if (_selectedFileIds.isEmpty) return;

    final targetFolderId = await showDialog<int?>(
      context: context,
      builder: (context) => MoveToFolderDialog(
        vaultId: widget.vault.id!,
        currentFolderId: _currentFolderId,
        masterKey: widget.masterKey,
      ),
    );

    if (targetFolderId != null && mounted) {
      final fileService = Provider.of<FileService>(context, listen: false);
      int successCount = 0;

      for (final fileId in _selectedFileIds) {
        final success = await fileService.moveFileToFolder(
          fileId,
          targetFolderId == -1 ? null : targetFolderId,
        );
        if (success) successCount++;
      }

      _clearSelection();
      _loadFiles();

      if (mounted) {
        final l10n = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.movedToFolder ?? 'ย้ายสำเร็จ'} $successCount ${l10n?.files ?? 'ไฟล์'}'),
          ),
        );
      }
    }
  }

  // Folder navigation
  Future<void> _openFolder(FileFolder folder) async {
    setState(() {
      _currentFolderId = folder.id;
      _folderPath.add(folder);
    });
    _loadFiles();
  }

  void _navigateToFolder(int index) {
    // Navigate to specific folder in breadcrumb
    if (index == -1) {
      // Root
      setState(() {
        _currentFolderId = null;
        _folderPath.clear();
      });
    } else {
      setState(() {
        _currentFolderId = _folderPath[index].id;
        _folderPath = _folderPath.sublist(0, index + 1);
      });
    }
    _loadFiles();
  }

  Future<void> _createFolder() async {
    final folderName = await showDialog<String>(
      context: context,
      builder: (context) => const CreateFolderDialog(),
    );

    if (folderName != null && folderName.isNotEmpty && mounted) {
      final fileService = Provider.of<FileService>(context, listen: false);
      final l10n = S.of(context);
      try {
        await fileService.createFolder(
          vaultId: widget.vault.id!,
          name: folderName,
          masterKey: widget.masterKey,
          parentFolderId: _currentFolderId,
        );
        _loadFiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n?.folderCreated ?? 'สร้างโฟลเดอร์สำเร็จ'}: "$folderName"')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
        withData: true, // Important: Load bytes for web compatibility
      );

      if (result != null && result.files.isNotEmpty) {
        final fileDataList = <FileData>[];

        for (final file in result.files) {
          Uint8List? bytes = file.bytes;

          // On mobile/desktop, bytes might be null - read from path
          if (bytes == null && file.path != null && !kIsWeb) {
            bytes = await file_reader.readFileFromPath(file.path!);
          }

          if (bytes != null) {
            fileDataList.add(FileData(
              name: file.name,
              bytes: bytes,
              originalPath: file.path, // Store original path for potential deletion
            ));
          } else {
            AppLogger.warning('Could not load bytes for: ${file.name}',
                tag: _tag);
          }
        }

        if (fileDataList.isNotEmpty) {
          // Check for large files and show warning
          final filesToUpload = await _checkLargeFilesAndWarn(fileDataList);
          if (filesToUpload != null && filesToUpload.isNotEmpty) {
            await _uploadFiles(filesToUpload);
          }
        } else {
          if (mounted) {
            final l10n = S.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n?.errorOccurred ?? 'ไม่สามารถโหลดไฟล์ได้')),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.error('Pick file error', tag: _tag, error: e);
      if (mounted) {
        final l10n = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        final fileDataList = <FileData>[];

        for (final image in images) {
          final bytes = await image.readAsBytes();
          fileDataList.add(FileData(
            name: image.name,
            bytes: bytes,
            originalPath: image.path, // Store original path for potential deletion
          ));
        }

        if (fileDataList.isNotEmpty) {
          // Check for large files and show warning
          final filesToUpload = await _checkLargeFilesAndWarn(fileDataList);
          if (filesToUpload != null && filesToUpload.isNotEmpty) {
            await _uploadFiles(filesToUpload);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Pick image error', tag: _tag, error: e);
      if (mounted) {
        final l10n = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e')),
        );
      }
    }
  }

  /// Take a photo using camera
  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final fileName = 'Photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final fileData = FileData(
          name: fileName,
          bytes: bytes,
          originalPath: photo.path,
        );

        await _uploadFiles([fileData]);
      }
    } catch (e) {
      AppLogger.error('Take photo error', tag: _tag, error: e);
      if (mounted) {
        final l10n = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e')),
        );
      }
    }
  }

  /// Record a video using camera
  Future<void> _takeVideo() async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        final bytes = await video.readAsBytes();
        final fileName = 'Video_${DateTime.now().millisecondsSinceEpoch}.mp4';

        final fileData = FileData(
          name: fileName,
          bytes: bytes,
          originalPath: video.path,
        );

        // Check for large files and show warning
        final filesToUpload = await _checkLargeFilesAndWarn([fileData]);
        if (filesToUpload != null && filesToUpload.isNotEmpty) {
          await _uploadFiles(filesToUpload);
        }
      }
    } catch (e) {
      AppLogger.error('Take video error', tag: _tag, error: e);
      if (mounted) {
        final l10n = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e')),
        );
      }
    }
  }

  /// Open file for viewing/preview
  Future<void> _openFile(EncryptedFile file) async {
    final l10n = S.of(context);
    final fileService = Provider.of<FileService>(context, listen: false);

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get file content with tracking
      final decryptedData = await fileService.getFileContentWithTracking(
        file,
        widget.masterKey,
      );

      // Close loading
      if (mounted) Navigator.pop(context);

      final fileName = fileService.getFileName(file, widget.masterKey);
      final ext = file.fileType?.toLowerCase() ?? '';

      // Check file type and open appropriate viewer
      if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext)) {
        // Image viewer
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => ImageViewerDialog(
              imageBytes: decryptedData,
              fileName: fileName,
              file: file,
              masterKey: widget.masterKey,
              onDeleted: _loadFiles,
            ),
          );
        }
      } else if (ext == 'pdf') {
        // PDF viewer
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                pdfBytes: decryptedData,
                fileName: fileName,
              ),
            ),
          );
        }
      } else if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(ext)) {
        // Video viewer
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoViewerScreen(
                videoBytes: decryptedData,
                fileName: fileName,
              ),
            ),
          );
        }
      } else if (['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg'].contains(ext)) {
        // Audio player (use video player for audio)
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoViewerScreen(
                videoBytes: decryptedData,
                fileName: fileName,
                isAudio: true,
              ),
            ),
          );
        }
      } else {
        // For other files, show info and offer download
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n?.fileOpened ?? 'เปิดไฟล์'}: $fileName'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading if showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      AppLogger.error('Open file error', tag: _tag, error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e')),
        );
      }
    }
  }

  // Track upload cancellation
  bool _uploadCancelled = false;

  // File size limit constants
  static const int _largeFileSizeLimit = 500 * 1024 * 1024; // 500MB

  /// Format file size to human readable string
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Check for large files and show warning dialog
  /// Returns the list of files to upload (may be filtered)
  Future<List<FileData>?> _checkLargeFilesAndWarn(List<FileData> files) async {
    final largeFiles = files.where((f) => f.bytes.length > _largeFileSizeLimit).toList();

    if (largeFiles.isEmpty) {
      return files; // No large files, proceed normally
    }

    final l10n = S.of(context);
    final totalLargeSize = largeFiles.fold<int>(0, (sum, f) => sum + f.bytes.length);
    final estimatedRam = totalLargeSize * 2; // Encryption uses ~2x memory

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.largeFileWarning ?? 'คำเตือนไฟล์ขนาดใหญ่',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.largeFileWarningMessage(largeFiles.length, '500 MB') ??
                    'คุณเลือก ${largeFiles.length} ไฟล์ที่มีขนาดใหญ่กว่า 500 MB '
                        'ไฟล์ขนาดใหญ่ต้องใช้ RAM มาก และอาจทำให้แอปค้างหรือปิดตัว',
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.largeFilesList ?? 'ไฟล์ขนาดใหญ่:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: largeFiles.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              f.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            _formatFileSize(f.bytes.length),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.memory, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n?.estimatedRamUsage(_formatFileSize(estimatedRam)) ??
                            'RAM ที่ต้องใช้โดยประมาณ: ${_formatFileSize(estimatedRam)}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text(l10n?.cancel ?? 'ยกเลิก'),
          ),
          if (files.length > largeFiles.length)
            TextButton(
              onPressed: () => Navigator.pop(context, 'skip_large'),
              child: Text(l10n?.removeAndContinue ?? 'ลบไฟล์ใหญ่ออก'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'proceed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.proceedAnyway ?? 'ดำเนินการต่อ'),
          ),
        ],
      ),
    );

    switch (result) {
      case 'proceed':
        return files; // Upload all including large files
      case 'skip_large':
        // Return only files under the limit
        return files.where((f) => f.bytes.length <= _largeFileSizeLimit).toList();
      case 'cancel':
      default:
        return null; // User cancelled
    }
  }

  /// Ask user if they want to delete original files after successful upload
  Future<void> _askToDeleteOriginals(List<FileData> uploadedFiles) async {
    // Only ask on mobile (not web) and only if we have original paths
    if (kIsWeb) return;

    final filesWithPaths = uploadedFiles.where((f) => f.originalPath != null).toList();
    if (filesWithPaths.isEmpty) return;

    final l10n = S.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_sweep, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.deleteOriginalTitle ?? 'ลบไฟล์ต้นฉบับ?',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.deleteOriginalMessage(filesWithPaths.length) ??
                  'อัปโหลด ${filesWithPaths.length} ไฟล์สำเร็จ '
                      'คุณต้องการลบไฟล์ต้นฉบับจากเครื่องเพื่อประหยัดพื้นที่หรือไม่?',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.deleteOriginalWarning ??
                          'การดำเนินการนี้จะลบไฟล์ต้นฉบับจากแกลเลอรี/โฟลเดอร์อย่างถาวร',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.keepOriginals ?? 'เก็บไว้'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.deleteOriginals ?? 'ลบต้นฉบับ'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await _deleteOriginalFiles(filesWithPaths);
    }
  }

  /// Delete original files from device storage
  Future<void> _deleteOriginalFiles(List<FileData> files) async {
    int deletedCount = 0;

    for (final file in files) {
      if (file.originalPath != null) {
        try {
          final originalFile = await file_reader.getFileFromPath(file.originalPath!);
          if (originalFile != null && await originalFile.exists()) {
            await originalFile.delete();
            deletedCount++;
          }
        } catch (e) {
          AppLogger.warning('Could not delete original: ${file.originalPath}', tag: _tag);
        }
      }
    }

    if (mounted) {
      final l10n = S.of(context);
      if (deletedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.originalsDeleted(deletedCount) ??
                  'ลบไฟล์ต้นฉบับ $deletedCount ไฟล์แล้ว',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.originalsDeleteFailed ??
                  'ไม่สามารถลบไฟล์ต้นฉบับบางไฟล์ได้',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _uploadFiles(List<FileData> files) async {
    if (files.isEmpty) return;

    final l10n = S.of(context);
    _uploadCancelled = false;
    int currentFileIndex = 0;
    double currentFileProgress = 0.0;
    String currentStatus = l10n?.preparing ?? 'กำลังเตรียมไฟล์...';
    String currentFileName = files.first.name;

    // Show progress dialog with StatefulBuilder for updates
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Store the setState function for updating dialog
          _updateProgressDialog =
              (int fileIndex, String fileName, double progress, String status) {
            if (mounted && !_uploadCancelled) {
              setDialogState(() {
                currentFileIndex = fileIndex;
                currentFileName = fileName;
                currentFileProgress = progress;
                currentStatus = status;
              });
            }
          };

          return UploadProgressDialog(
            currentFile: currentFileIndex + 1,
            totalFiles: files.length,
            currentFileName: currentFileName,
            fileProgress: currentFileProgress,
            statusText: currentStatus,
            onCancel: () {
              _uploadCancelled = true;
              Navigator.pop(dialogContext);
            },
          );
        },
      ),
    );

    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      int successCount = 0;
      List<String> errors = [];
      List<FileData> successfullyUploaded = []; // Track for deletion option

      for (int i = 0; i < files.length; i++) {
        // Check if cancelled
        if (_uploadCancelled) {
          AppLogger.log('Upload cancelled by user', tag: _tag);
          break;
        }

        final fileData = files[i];
        _updateProgressDialog?.call(i, fileData.name, 0.0, l10n?.preparing ?? 'กำลังเตรียมไฟล์...');

        try {
          AppLogger.log(
              'Uploading: ${fileData.name} (${fileData.bytes.length} bytes)',
              tag: _tag);
          await fileService.saveFileFromBytes(
            vaultId: widget.vault.id!,
            fileBytes: fileData.bytes,
            originalFileName: fileData.name,
            masterKey: widget.masterKey,
            vaultPath: widget.vault.path,
            folderId: _currentFolderId,
            onProgress: (progress, status) {
              _updateProgressDialog?.call(i, fileData.name, progress, status);
            },
          );
          successCount++;
          successfullyUploaded.add(fileData); // Track successful upload
          AppLogger.log('Upload success: ${fileData.name}', tag: _tag);
        } catch (e) {
          AppLogger.error('Upload failed: ${fileData.name}',
              tag: _tag, error: e);
          errors.add('${fileData.name}: $e');
        }
      }

      // Close dialog if not cancelled
      if (mounted && !_uploadCancelled) {
        Navigator.pop(context);
      }

      // Show result
      if (mounted) {
        final l10nResult = S.of(context);
        if (_uploadCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10nResult?.cancel ?? 'ยกเลิก'} (${l10nResult?.success ?? 'สำเร็จ'} $successCount ${l10nResult?.files ?? 'ไฟล์'})'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (errors.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10nResult?.success ?? 'สำเร็จ'} $successCount ${l10nResult?.files ?? 'ไฟล์'}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10nResult?.success ?? 'สำเร็จ'} $successCount/${files.length} ${l10nResult?.files ?? 'ไฟล์'}'),
              backgroundColor: successCount > 0 ? Colors.orange : Colors.red,
            ),
          );
        }

        _loadFiles();

        // Ask user if they want to delete original files (only on success)
        if (successfullyUploaded.isNotEmpty && !_uploadCancelled) {
          await _askToDeleteOriginals(successfullyUploaded);
        }
      }
    } catch (e) {
      AppLogger.error('Upload error', tag: _tag, error: e);
      if (mounted && !_uploadCancelled) {
        Navigator.pop(context);
        final l10nError = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10nError?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    _updateProgressDialog = null;
  }

  // Callback to update progress dialog
  void Function(int fileIndex, String fileName, double progress, String status)?
      _updateProgressDialog;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Filter chips
          if (!_isMultiSelectMode) _buildFilterChips(),

          // Breadcrumb navigation
          if (_folderPath.isNotEmpty && !_isMultiSelectMode)
            FolderBreadcrumb(
              path: _folderPath,
              masterKey: widget.masterKey,
              onNavigate: _navigateToFolder,
            ),

          // Multi-select toolbar
          if (_isMultiSelectMode)
            MultiSelectToolbar(
              selectedCount: _selectedFileIds.length + _selectedFolderIds.length,
              onSelectAll: _selectAllFiles,
              onClear: _clearSelection,
              onDelete: _deleteSelectedFiles,
              onMove: _moveSelectedToFolder,
            ),

          // Recent files section (only at root folder)
          if (!_isMultiSelectMode && _currentFolderId == null && !_isLoading)
            RecentFilesSection(
              key: _recentFilesKey,
              vault: widget.vault,
              masterKey: widget.masterKey,
              onFileDeleted: _loadFiles,
              onFileTap: _openFile,
            ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFileListWithFolders(),
                      GalleryViewWidget(
                        files: _filteredFiles,
                        vault: widget.vault,
                        masterKey: widget.masterKey,
                        selectedIds: _selectedFileIds,
                        isMultiSelectMode: _isMultiSelectMode,
                        onFileSelected: _toggleFileSelection,
                        onFileLongPress: (id) {
                          if (!_isMultiSelectMode) {
                            _toggleFileSelection(id);
                          }
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'folder',
                  onPressed: _createFolder,
                  tooltip: l10n?.createFolder ?? 'สร้างโฟลเดอร์',
                  mini: true,
                  child: const Icon(Icons.create_new_folder),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'takeVideo',
                  onPressed: _takeVideo,
                  tooltip: l10n?.takeVideo ?? 'ถ่ายวิดีโอ',
                  mini: true,
                  child: const Icon(Icons.videocam),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'takePhoto',
                  onPressed: _takePhoto,
                  tooltip: l10n?.takePhoto ?? 'ถ่ายรูป',
                  mini: true,
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'image',
                  onPressed: _pickImage,
                  tooltip: l10n?.addImages ?? 'เลือกรูปภาพ',
                  child: const Icon(Icons.photo_library),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'file',
                  onPressed: _pickFile,
                  tooltip: l10n?.addFiles ?? 'เลือกไฟล์',
                  child: const Icon(Icons.attach_file),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final l10n = S.of(context);
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _toggleSearch,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n?.searchFiles ?? 'ค้นหาไฟล์...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      );
    }

    return AppBar(
      title: Text(widget.vault.name),
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(icon: const Icon(Icons.list), text: l10n?.files ?? 'ไฟล์ทั้งหมด'),
          Tab(icon: const Icon(Icons.photo_library), text: l10n?.filterImages ?? 'แกลเลอรี'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
          tooltip: l10n?.search ?? 'ค้นหา',
        ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: _showSortMenu,
          tooltip: l10n?.sortBy ?? 'เรียงลำดับ',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadFiles,
          tooltip: l10n?.loading ?? 'รีเฟรช',
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final l10n = S.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: FileTypeFilter.values.map((filter) {
          final isSelected = _typeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterTypeLabel(filter, l10n)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _typeFilter = selected ? filter : FileTypeFilter.all;
                });
              },
              selectedColor:
                  Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor:
                  Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFileListWithFolders() {
    final foldersInCurrent = _folders
        .where((f) => f.parentFolderId == _currentFolderId)
        .toList();

    return CustomScrollView(
      slivers: [
        // Folders section
        if (foldersInCurrent.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final folder = foldersInCurrent[index];
                  return FolderCard(
                    folder: folder,
                    masterKey: widget.masterKey,
                    isSelected: _selectedFolderIds.contains(folder.id),
                    isMultiSelectMode: _isMultiSelectMode,
                    onTap: () => _openFolder(folder),
                    onLongPress: () {
                      if (!_isMultiSelectMode && folder.id != null) {
                        _toggleFolderSelection(folder.id!);
                      }
                    },
                    onSelected: () {
                      if (folder.id != null) {
                        _toggleFolderSelection(folder.id!);
                      }
                    },
                  );
                },
                childCount: foldersInCurrent.length,
              ),
            ),
          ),

        // Divider between folders and files
        if (foldersInCurrent.isNotEmpty && _filteredFiles.isNotEmpty)
          const SliverToBoxAdapter(
            child: Divider(height: 24),
          ),

        // Files section
        SliverFillRemaining(
          child: FileListWidget(
            files: _filteredFiles,
            vault: widget.vault,
            masterKey: widget.masterKey,
            onFileDeleted: _loadFiles,
            selectedIds: _selectedFileIds,
            isMultiSelectMode: _isMultiSelectMode,
            onFileSelected: _toggleFileSelection,
            onFileLongPress: (id) {
              if (!_isMultiSelectMode) {
                _toggleFileSelection(id);
              }
            },
            onFileTap: _openFile,
          ),
        ),
      ],
    );
  }
}
