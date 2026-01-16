import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:typed_data';
import 'dart:io';
import '../../../core/models/vault.dart';
import '../../../core/models/encrypted_file.dart';
import '../../../services/file_service.dart';
import 'image_viewer_dialog.dart';

class GalleryViewWidget extends StatefulWidget {
  final Vault vault;
  final Uint8List masterKey;

  const GalleryViewWidget({
    super.key,
    required this.vault,
    required this.masterKey,
  });

  @override
  State<GalleryViewWidget> createState() => _GalleryViewWidgetState();
}

class _GalleryViewWidgetState extends State<GalleryViewWidget> {
  List<EncryptedFile> _imageFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    final fileService = Provider.of<FileService>(context, listen: false);
    final images = await fileService.getImageFiles(widget.vault.id!);
    setState(() {
      _imageFiles = images;
      _isLoading = false;
    });
  }

  Future<void> _viewImage(EncryptedFile file) async {
    final fileService = Provider.of<FileService>(context, listen: false);
    
    try {
      final imageBytes = await fileService.getFileContent(file, widget.masterKey);
      final fileName = fileService.getFileName(file, widget.masterKey);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ImageViewerDialog(
            imageBytes: imageBytes,
            fileName: fileName,
            file: file,
            masterKey: widget.masterKey,
            onDeleted: () {
              _loadImages();
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเปิดรูปภาพ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_imageFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีรูปภาพ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'อัปโหลดรูปภาพเพื่อดูในแกลเลอรี',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadImages,
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        itemCount: _imageFiles.length,
        itemBuilder: (context, index) {
          final file = _imageFiles[index];
          return _ImageThumbnail(
            file: file,
            vault: widget.vault,
            masterKey: widget.masterKey,
            onTap: () => _viewImage(file),
          );
        },
      ),
    );
  }
}

class _ImageThumbnail extends StatefulWidget {
  final EncryptedFile file;
  final Vault vault;
  final Uint8List masterKey;
  final VoidCallback onTap;

  const _ImageThumbnail({
    required this.file,
    required this.vault,
    required this.masterKey,
    required this.onTap,
  });

  @override
  State<_ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<_ImageThumbnail> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      
      // Try to load thumbnail first
      if (widget.file.thumbnailPath != null) {
        final thumbnailFile = File(widget.file.thumbnailPath!);
        if (await thumbnailFile.exists()) {
          final bytes = await thumbnailFile.readAsBytes();
          if (mounted) {
            setState(() {
              _thumbnailBytes = bytes;
              _isLoading = false;
            });
            return;
          }
        }
      }

      // Fallback: load full image and create thumbnail
      final imageBytes = await fileService.getFileContent(widget.file, widget.masterKey);
      if (mounted) {
        setState(() {
          _thumbnailBytes = imageBytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.grey[200],
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _thumbnailBytes == null
                  ? const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    )
                  : Image.memory(
                      _thumbnailBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
