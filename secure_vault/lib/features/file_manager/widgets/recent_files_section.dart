import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../core/models/encrypted_file.dart';
import '../../../core/models/vault.dart';
import '../../../core/storage/database_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/file_service.dart';

class RecentFilesSection extends StatefulWidget {
  final Vault vault;
  final Uint8List masterKey;
  final VoidCallback onFileDeleted;
  final Function(EncryptedFile file) onFileTap;

  const RecentFilesSection({
    super.key,
    required this.vault,
    required this.masterKey,
    required this.onFileDeleted,
    required this.onFileTap,
  });

  @override
  State<RecentFilesSection> createState() => _RecentFilesSectionState();
}

class _RecentFilesSectionState extends State<RecentFilesSection> {
  List<EncryptedFile> _recentFiles = [];
  bool _isLoading = true;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  Future<void> _loadRecentFiles() async {
    setState(() => _isLoading = true);
    try {
      final files = await DatabaseHelper.instance.getRecentFiles(
        widget.vault.id!,
        limit: 10,
      );
      if (mounted) {
        setState(() {
          _recentFiles = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String? fileType) {
    final ext = fileType?.toLowerCase() ?? '';
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext)) {
      return Icons.image;
    } else if (['mp4', 'mov', 'avi', 'mkv', 'wmv'].contains(ext)) {
      return Icons.video_file;
    } else if (['mp3', 'wav', 'aac', 'flac', 'm4a'].contains(ext)) {
      return Icons.audio_file;
    } else if (['pdf'].contains(ext)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      return Icons.description;
    } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
      return Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(ext)) {
      return Icons.slideshow;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return Icons.folder_zip;
    } else if (['txt', 'md', 'json', 'xml', 'html', 'css', 'js'].contains(ext)) {
      return Icons.code;
    }
    return Icons.insert_drive_file;
  }

  Color _getFileColor(String? fileType) {
    final ext = fileType?.toLowerCase() ?? '';
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(ext)) {
      return Colors.green;
    } else if (['mp4', 'mov', 'avi', 'mkv', 'wmv'].contains(ext)) {
      return Colors.red;
    } else if (['mp3', 'wav', 'aac', 'flac', 'm4a'].contains(ext)) {
      return Colors.purple;
    } else if (['pdf'].contains(ext)) {
      return Colors.red[700]!;
    } else if (['doc', 'docx'].contains(ext)) {
      return Colors.blue;
    } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
      return Colors.green[700]!;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_recentFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.recentFiles ?? 'เปิดล่าสุด',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${_recentFiles.length})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),

        // Recent files list
        if (_isExpanded)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _recentFiles.length,
              itemBuilder: (context, index) {
                final file = _recentFiles[index];
                return _buildRecentFileCard(file);
              },
            ),
          ),

        if (_isExpanded) const Divider(height: 16),
      ],
    );
  }

  Widget _buildRecentFileCard(EncryptedFile file) {
    final theme = Theme.of(context);
    final fileService = FileService();
    final fileName = fileService.getFileName(file, widget.masterKey);
    final fileIcon = _getFileIcon(file.fileType);
    final fileColor = _getFileColor(file.fileType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => widget.onFileTap(file),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: fileColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  fileIcon,
                  color: fileColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                _formatFileSize(file.size),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
