import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/models/vault.dart';
import '../../../core/models/encrypted_file.dart';
import '../../../core/utils/logger.dart';
import '../../../services/file_service.dart';
import '../widgets/file_list_widget.dart';
import '../widgets/gallery_view_widget.dart';
import '../widgets/upload_progress_dialog.dart';

// Conditional import for file reading
import 'file_reader_io.dart' if (dart.library.html) 'file_reader_web.dart'
    as file_reader;

/// File data holder for cross-platform compatibility
class FileData {
  final String name;
  final Uint8List bytes;

  FileData({required this.name, required this.bytes});
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
  bool _isLoading = true;

  // Race condition prevention: version counter
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    // Increment version to invalidate any pending loads
    final currentVersion = ++_loadVersion;

    setState(() => _isLoading = true);

    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      final files = await fileService.getFiles(widget.vault.id!);

      // Only update state if this is still the latest request
      if (mounted && currentVersion == _loadVersion) {
        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Load files error', tag: _tag, error: e);
      if (mounted && currentVersion == _loadVersion) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถโหลดไฟล์: $e')),
        );
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
            ));
          } else {
            AppLogger.warning('Could not load bytes for: ${file.name}', tag: _tag);
          }
        }

        if (fileDataList.isNotEmpty) {
          await _uploadFiles(fileDataList);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ไม่สามารถโหลดไฟล์ได้')),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.error('Pick file error', tag: _tag, error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเลือกไฟล์ได้: $e')),
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
          ));
        }

        if (fileDataList.isNotEmpty) {
          await _uploadFiles(fileDataList);
        }
      }
    } catch (e) {
      AppLogger.error('Pick image error', tag: _tag, error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเลือกรูปภาพได้: $e')),
        );
      }
    }
  }

  // Track upload cancellation
  bool _uploadCancelled = false;

  Future<void> _uploadFiles(List<FileData> files) async {
    if (files.isEmpty) return;

    _uploadCancelled = false;
    int currentFileIndex = 0;
    double currentFileProgress = 0.0;
    String currentStatus = 'กำลังเตรียมไฟล์...';
    String currentFileName = files.first.name;

    // Show progress dialog with StatefulBuilder for updates
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Store the setState function for updating dialog
          _updateProgressDialog = (int fileIndex, String fileName, double progress, String status) {
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

      for (int i = 0; i < files.length; i++) {
        // Check if cancelled
        if (_uploadCancelled) {
          AppLogger.log('Upload cancelled by user', tag: _tag);
          break;
        }

        final fileData = files[i];
        _updateProgressDialog?.call(i, fileData.name, 0.0, 'กำลังเตรียมไฟล์...');

        try {
          AppLogger.log('Uploading: ${fileData.name} (${fileData.bytes.length} bytes)', tag: _tag);
          await fileService.saveFileFromBytes(
            vaultId: widget.vault.id!,
            fileBytes: fileData.bytes,
            originalFileName: fileData.name,
            masterKey: widget.masterKey,
            vaultPath: widget.vault.path,
            onProgress: (progress, status) {
              _updateProgressDialog?.call(i, fileData.name, progress, status);
            },
          );
          successCount++;
          AppLogger.log('Upload success: ${fileData.name}', tag: _tag);
        } catch (e) {
          AppLogger.error('Upload failed: ${fileData.name}', tag: _tag, error: e);
          errors.add('${fileData.name}: $e');
        }
      }

      // Close dialog if not cancelled
      if (mounted && !_uploadCancelled) {
        Navigator.pop(context);
      }

      // Show result
      if (mounted) {
        if (_uploadCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ยกเลิกการอัปโหลด (สำเร็จ $successCount ไฟล์)'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (errors.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('อัปโหลดสำเร็จ $successCount ไฟล์'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('อัปโหลดสำเร็จ $successCount/${files.length} ไฟล์'),
              backgroundColor: successCount > 0 ? Colors.orange : Colors.red,
            ),
          );
        }

        _loadFiles();
      }
    } catch (e) {
      AppLogger.error('Upload error', tag: _tag, error: e);
      if (mounted && !_uploadCancelled) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    _updateProgressDialog = null;
  }

  // Callback to update progress dialog
  void Function(int fileIndex, String fileName, double progress, String status)? _updateProgressDialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vault.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'ไฟล์ทั้งหมด'),
            Tab(icon: Icon(Icons.photo_library), text: 'แกลเลอรี'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
            tooltip: 'รีเฟรช',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                FileListWidget(
                  files: _files,
                  vault: widget.vault,
                  masterKey: widget.masterKey,
                  onFileDeleted: _loadFiles,
                ),
                GalleryViewWidget(
                  files: _files,
                  vault: widget.vault,
                  masterKey: widget.masterKey,
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'image',
            onPressed: _pickImage,
            tooltip: 'เลือกรูปภาพ',
            child: const Icon(Icons.photo),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'file',
            onPressed: _pickFile,
            tooltip: 'เลือกไฟล์',
            child: const Icon(Icons.attach_file),
          ),
        ],
      ),
    );
  }
}
