import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../core/models/vault.dart';
import '../../../core/models/encrypted_file.dart';
import '../../../services/file_service.dart';
import '../widgets/file_list_widget.dart';
import '../widgets/gallery_view_widget.dart';

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
  late TabController _tabController;
  List<EncryptedFile> _files = [];
  bool _isLoading = true;

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
    setState(() => _isLoading = true);
    final fileService = Provider.of<FileService>(context, listen: false);
    final files = await fileService.getFiles(widget.vault.id!);
    setState(() {
      _files = files;
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      await _uploadFiles(result.files.map((f) => File(f.path!)).toList());
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      final files = images.map((img) => File(img.path)).toList();
      await _uploadFiles(files);
    }
  }

  Future<void> _uploadFiles(List<File> files) async {
    if (files.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      int successCount = 0;

      for (final file in files) {
        try {
          await fileService.saveFile(
            vaultId: widget.vault.id!,
            file: file,
            originalFileName: file.path.split('/').last,
            masterKey: widget.masterKey,
            vaultPath: widget.vault.path,
          );
          successCount++;
        } catch (e) {
          // Continue with other files
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปโหลดสำเร็จ $successCount/${files.length} ไฟล์'),
          ),
        );
        _loadFiles();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

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
