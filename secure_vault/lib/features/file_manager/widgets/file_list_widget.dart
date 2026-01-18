import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../../core/models/vault.dart';
import '../../../core/models/encrypted_file.dart';
import '../../../services/file_service.dart';
import '../../../services/share_service.dart';
import '../../../core/storage/database_helper.dart';
import '../../../utils/file_utils.dart';
import 'tag_selector_dialog.dart';

class FileListWidget extends StatelessWidget {
  final List<EncryptedFile> files;
  final Vault vault;
  final Uint8List masterKey;
  final VoidCallback onFileDeleted;
  final Set<int> selectedIds;
  final bool isMultiSelectMode;
  final Function(int) onFileSelected;
  final Function(int) onFileLongPress;

  const FileListWidget({
    super.key,
    required this.files,
    required this.vault,
    required this.masterKey,
    required this.onFileDeleted,
    this.selectedIds = const {},
    this.isMultiSelectMode = false,
    required this.onFileSelected,
    required this.onFileLongPress,
  });

  IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    switch (fileType.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
        return Icons.text_snippet;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _shareFile(BuildContext context, EncryptedFile file) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final fileService = Provider.of<FileService>(context, listen: false);
      final shareService = ShareService();

      // Decrypt file
      final decryptedData = await fileService.getFileContent(file, masterKey);
      final fileName = fileService.getFileName(file, masterKey);
      final mimeType = shareService.getMimeType(file.fileType);

      // Close loading
      if (context.mounted) Navigator.pop(context);

      // Share file
      await shareService.shareFile(
        decryptedData: decryptedData,
        fileName: fileName,
        mimeType: mimeType,
      );
    } catch (e) {
      // Close loading if showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<void> _deleteFile(BuildContext context, EncryptedFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ย้ายไปถังขยะ'),
        content: const Text(
          'ไฟล์จะถูกย้ายไปถังขยะ\nคุณสามารถกู้คืนได้ภายใน 30 วัน',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ย้ายไปถังขยะ'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final fileService = Provider.of<FileService>(context, listen: false);
      final success = await fileService.moveToTrash(file);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ย้ายไปถังขยะแล้ว'),
            action: SnackBarAction(
              label: 'เลิกทำ',
              onPressed: () async {
                await fileService.restoreFromTrash(file);
                onFileDeleted();
              },
            ),
          ),
        );
        onFileDeleted();
      }
    }
  }

  Future<void> _manageTags(BuildContext context, EncryptedFile file) async {
    if (file.id == null) return;

    try {
      // Load current tags for this file
      final currentTags = await DatabaseHelper.instance.getTagsForFile(file.id!);

      if (!context.mounted) return;

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => TagSelectorDialog(
          vaultId: vault.id!,
          fileId: file.id!,
          currentTags: currentTags,
        ),
      );

      if (result == true && context.mounted) {
        // Refresh file list to show updated tags
        onFileDeleted(); // Reuse callback to trigger refresh
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีไฟล์',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'กดปุ่ม + เพื่อเพิ่มไฟล์',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final fileService = Provider.of<FileService>(context, listen: false);
        final fileName = fileService.getFileName(file, masterKey);
        final isSelected = file.id != null && selectedIds.contains(file.id);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isSelected ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (isMultiSelectMode && file.id != null) {
                  onFileSelected(file.id!);
                } else {
                  // TODO: Open file viewer
                }
              },
              onLongPress: () {
                if (file.id != null) {
                  onFileLongPress(file.id!);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Checkbox or file icon
                    if (isMultiSelectMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: file.id != null
                              ? (_) => onFileSelected(file.id!)
                              : null,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getFileIcon(file.fileType),
                          size: 32,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),

                    if (!isMultiSelectMode) const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            FileUtils.formatFileSize(file.size),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${file.createdAt.day}/${file.createdAt.month}/${file.createdAt.year}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!isMultiSelectMode)
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('แชร์'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'tags',
                            child: Row(
                              children: [
                                Icon(Icons.label, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('จัดการ Tags'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('ลบ', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'share') {
                            _shareFile(context, file);
                          } else if (value == 'tags') {
                            _manageTags(context, file);
                          } else if (value == 'delete') {
                            _deleteFile(context, file);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
