import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../core/models/encrypted_file.dart';
import '../../../core/models/vault.dart';
import '../../../core/storage/database_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../services/file_service.dart';
import '../../../l10n/app_localizations.dart';

class TrashScreen extends StatefulWidget {
  final Vault? vault;
  final Uint8List? masterKey;

  const TrashScreen({
    super.key,
    this.vault,
    this.masterKey,
  });

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  static const String _tag = 'TrashScreen';
  final DatabaseHelper _db = DatabaseHelper.instance;
  final FileService _fileService = FileService();
  List<EncryptedFile> _trashFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrashFiles();
  }

  Future<void> _loadTrashFiles() async {
    setState(() => _isLoading = true);

    try {
      List<EncryptedFile> files;
      if (widget.vault != null) {
        files = await _db.getTrashFilesByVault(widget.vault!.id!);
      } else {
        files = await _db.getTrashFiles();
      }

      setState(() {
        _trashFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading trash', tag: _tag, error: e);
      setState(() => _isLoading = false);
    }
  }

  String _getFileName(EncryptedFile file, S? l10n) {
    if (widget.masterKey != null) {
      try {
        return _fileService.getFileName(file, widget.masterKey!);
      } catch (e) {
        return l10n?.error ?? 'Encrypted file';
      }
    }
    return '${l10n?.files ?? 'File'} ${file.fileType ?? 'unknown'}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _restoreFile(EncryptedFile file) async {
    final l10n = S.of(context);
    try {
      await _db.restoreFile(file.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.fileRestored ?? 'File restored'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadTrashFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.error ?? 'Error'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _permanentlyDelete(EncryptedFile file) async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n?.permanentDelete ?? 'Permanently Delete'),
          ],
        ),
        content: Text(
          l10n?.permanentDeleteWarning ?? 'This action cannot be undone. The file will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.permanentDelete ?? 'Permanently Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete from database
        await _db.deleteFile(file.id!);

        // Delete actual file
        await _fileService.deleteFile(file);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.fileDeleted ?? 'File deleted')),
          );
        }
        _loadTrashFiles();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n?.error ?? 'Error'}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _emptyTrash() async {
    if (_trashFiles.isEmpty) return;

    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n?.emptyTrash ?? 'Empty Trash'),
          ],
        ),
        content: Text(
          l10n?.emptyTrashWarning ?? 'This will permanently delete all files in trash. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n?.emptyTrash ?? 'Empty Trash'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final file in _trashFiles) {
          await _db.deleteFile(file.id!);
          await _fileService.deleteFile(file);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.trashEmptied ?? 'Trash emptied'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadTrashFiles();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n?.error ?? 'Error'}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.trash ?? 'Trash'),
        actions: [
          if (_trashFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: l10n?.emptyTrash ?? 'Empty Trash',
              onPressed: _emptyTrash,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trashFiles.isEmpty
              ? _buildEmptyState(l10n)
              : _buildTrashList(l10n),
    );
  }

  Widget _buildEmptyState(S? l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.trashEmpty ?? 'Trash is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.trashSubtitle ?? 'View and restore deleted files',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrashList(S? l10n) {
    return Column(
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.emptyTrashWarning ?? 'Files will be permanently deleted after 30 days in trash',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        // File list
        Expanded(
          child: ListView.builder(
            itemCount: _trashFiles.length,
            itemBuilder: (context, index) {
              final file = _trashFiles[index];
              return _buildTrashItem(file, l10n);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrashItem(EncryptedFile file, S? l10n) {
    final daysRemaining = file.daysUntilPermanentDeletion ?? 0;

    return Dismissible(
      key: Key(file.id.toString()),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.restore, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _restoreFile(file);
          return false;
        } else {
          await _permanentlyDelete(file);
          return false;
        }
      },
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            file.isImage ? Icons.image : Icons.insert_drive_file,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          _getFileName(file, l10n),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatSize(file.size)} - ${_formatDate(file.deletedAt!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              l10n?.daysRemaining(daysRemaining) ?? '$daysRemaining days remaining',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: daysRemaining <= 7 ? Colors.red : Colors.orange,
                  ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'restore') {
              _restoreFile(file);
            } else if (value == 'delete') {
              _permanentlyDelete(file);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  const Icon(Icons.restore, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(l10n?.restore ?? 'Restore'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_forever, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n?.delete ?? 'Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
