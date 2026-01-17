import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../core/models/encrypted_file.dart';
import '../../../core/models/vault.dart';
import '../../../core/storage/database_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../services/file_service.dart';

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

  String _getFileName(EncryptedFile file) {
    if (widget.masterKey != null) {
      try {
        return _fileService.getFileName(file, widget.masterKey!);
      } catch (e) {
        return 'ไฟล์เข้ารหัส';
      }
    }
    return 'ไฟล์ ${file.fileType ?? 'unknown'}';
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
    try {
      await _db.restoreFile(file.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กู้คืนไฟล์สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadTrashFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _permanentlyDelete(EncryptedFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('ลบถาวร?'),
          ],
        ),
        content: const Text(
          'ไฟล์จะถูกลบถาวรและไม่สามารถกู้คืนได้อีก\n\nคุณต้องการดำเนินการต่อหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ลบถาวร'),
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
            const SnackBar(content: Text('ลบไฟล์ถาวรแล้ว')),
          );
        }
        _loadTrashFiles();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _emptyTrash() async {
    if (_trashFiles.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('ล้างถังขยะ?'),
          ],
        ),
        content: Text(
          'ไฟล์ทั้งหมด ${_trashFiles.length} ไฟล์ จะถูกลบถาวร\nและไม่สามารถกู้คืนได้อีก',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ล้างถังขยะ'),
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
            const SnackBar(
              content: Text('ล้างถังขยะแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadTrashFiles();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาด: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ถังขยะ'),
        actions: [
          if (_trashFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'ล้างถังขยะ',
              onPressed: _emptyTrash,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trashFiles.isEmpty
              ? _buildEmptyState()
              : _buildTrashList(),
    );
  }

  Widget _buildEmptyState() {
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
            'ไม่มีไฟล์ในถังขยะ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'ไฟล์ที่ลบจะอยู่ที่นี่ 30 วัน\nก่อนถูกลบถาวรอัตโนมัติ',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrashList() {
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
                  'ไฟล์จะถูกลบถาวรหลังจากอยู่ในถังขยะ 30 วัน',
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
              return _buildTrashItem(file);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrashItem(EncryptedFile file) {
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
          _getFileName(file),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatSize(file.size)} • ลบเมื่อ ${_formatDate(file.deletedAt!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'จะถูกลบถาวรใน $daysRemaining วัน',
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
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, color: Colors.green),
                  SizedBox(width: 8),
                  Text('กู้คืน'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red),
                  SizedBox(width: 8),
                  Text('ลบถาวร'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
