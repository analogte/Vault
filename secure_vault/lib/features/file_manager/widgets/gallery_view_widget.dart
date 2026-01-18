import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:typed_data';
import '../../../core/models/vault.dart';
import '../../../core/models/encrypted_file.dart';
import '../../../services/file_service.dart';
import '../../../services/thumbnail_loader.dart';
import 'image_viewer_dialog.dart';

class GalleryViewWidget extends StatefulWidget {
  final List<EncryptedFile> files;
  final Vault vault;
  final Uint8List masterKey;
  final Set<int> selectedIds;
  final bool isMultiSelectMode;
  final Function(int) onFileSelected;
  final Function(int) onFileLongPress;

  const GalleryViewWidget({
    super.key,
    required this.files,
    required this.vault,
    required this.masterKey,
    this.selectedIds = const {},
    this.isMultiSelectMode = false,
    required this.onFileSelected,
    required this.onFileLongPress,
  });

  @override
  State<GalleryViewWidget> createState() => _GalleryViewWidgetState();
}

class _GalleryViewWidgetState extends State<GalleryViewWidget>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<EncryptedFile> get _imageFiles {
    return widget.files.where((file) => file.isImage).toList();
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
    super.build(context);

    final imageFiles = _imageFiles;

    if (imageFiles.isEmpty) {
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

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: imageFiles.length,
      itemBuilder: (context, index) {
        final file = imageFiles[index];
        final isSelected = file.id != null && widget.selectedIds.contains(file.id);

        return _ImageThumbnail(
          key: ValueKey(file.id),
          file: file,
          vault: widget.vault,
          masterKey: widget.masterKey,
          isSelected: isSelected,
          isMultiSelectMode: widget.isMultiSelectMode,
          onTap: () {
            if (widget.isMultiSelectMode && file.id != null) {
              widget.onFileSelected(file.id!);
            } else {
              _viewImage(file);
            }
          },
          onLongPress: () {
            if (file.id != null) {
              widget.onFileLongPress(file.id!);
            }
          },
        );
      },
    );
  }
}

class _ImageThumbnail extends StatefulWidget {
  final EncryptedFile file;
  final Vault vault;
  final Uint8List masterKey;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ImageThumbnail({
    super.key,
    required this.file,
    required this.vault,
    required this.masterKey,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<_ImageThumbnail>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Cancel any pending thumbnail load
    ThumbnailLoader().cancelLoad(widget.file.id);
    _thumbnailBytes = null; // Free memory
    super.dispose();
  }

  Future<void> _loadThumbnail() async {
    if (_isDisposed || !mounted) return;

    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      final thumbnailLoader = ThumbnailLoader();

      // Use thumbnail loader with caching and throttling
      final bytes = await thumbnailLoader.loadThumbnail(
        widget.file,
        widget.masterKey,
        fileService,
      );

      if (!_isDisposed && mounted) {
        setState(() {
          _thumbnailBytes = bytes;
          _isLoading = false;
          _hasError = bytes == null;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(minHeight: 100),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: widget.isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildContent(),
            ),
          ),

          // Selection overlay
          if (widget.isMultiSelectMode)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_hasError || _thumbnailBytes == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      );
    }

    return Image.memory(
      _thumbnailBytes!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        );
      },
    );
  }
}
