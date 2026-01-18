import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../../core/models/file_folder.dart';
import '../../../services/file_service.dart';
import '../../../l10n/app_localizations.dart';

class MoveToFolderDialog extends StatefulWidget {
  final int vaultId;
  final int? currentFolderId;
  final Uint8List masterKey;

  const MoveToFolderDialog({
    super.key,
    required this.vaultId,
    required this.currentFolderId,
    required this.masterKey,
  });

  @override
  State<MoveToFolderDialog> createState() => _MoveToFolderDialogState();
}

class _MoveToFolderDialogState extends State<MoveToFolderDialog> {
  List<FileFolder> _folders = [];
  bool _isLoading = true;
  int? _selectedFolderId;
  int? _currentParentId;
  List<FileFolder> _breadcrumb = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders({int? parentFolderId}) async {
    setState(() => _isLoading = true);

    try {
      final fileService = Provider.of<FileService>(context, listen: false);
      final folders = await fileService.getFolders(widget.vaultId, parentFolderId);

      setState(() {
        _folders = folders;
        _currentParentId = parentFolderId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _enterFolder(FileFolder folder) {
    _breadcrumb.add(folder);
    _loadFolders(parentFolderId: folder.id);
  }

  void _goBack() {
    if (_breadcrumb.isNotEmpty) {
      _breadcrumb.removeLast();
      final parentId = _breadcrumb.isEmpty ? null : _breadcrumb.last.id;
      _loadFolders(parentFolderId: parentId);
    }
  }

  void _goToRoot() {
    _breadcrumb.clear();
    _loadFolders(parentFolderId: null);
  }

  @override
  Widget build(BuildContext context) {
    final fileService = Provider.of<FileService>(context, listen: false);
    final l10n = S.of(context);

    return AlertDialog(
      title: Text(l10n?.moveToFolder ?? 'ย้ายไปโฟลเดอร์'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Breadcrumb
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: _breadcrumb.isEmpty ? null : _goToRoot,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home,
                              size: 18,
                              color: _breadcrumb.isEmpty
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n?.root ?? 'Root',
                              style: TextStyle(
                                color: _breadcrumb.isEmpty
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ..._breadcrumb.asMap().entries.map((entry) {
                      final index = entry.key;
                      final folder = entry.value;
                      final isLast = index == _breadcrumb.length - 1;
                      final name = fileService.getFolderName(folder, widget.masterKey);

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chevron_right, size: 20),
                          InkWell(
                            onTap: isLast
                                ? null
                                : () {
                                    _breadcrumb = _breadcrumb.sublist(0, index + 1);
                                    _loadFolders(parentFolderId: folder.id);
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: isLast
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.primary,
                                  fontWeight: isLast ? FontWeight.w600 : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            const Divider(),

            // Back button
            if (_breadcrumb.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: Text(l10n?.close ?? 'กลับ'),
                onTap: _goBack,
                dense: true,
              ),

            // Root option (move to root)
            if (_currentParentId != null || widget.currentFolderId != null)
              RadioListTile<int?>(
                value: -1, // Special value for root
                groupValue: _selectedFolderId,
                onChanged: (value) => setState(() => _selectedFolderId = value),
                title: Row(
                  children: [
                    Icon(
                      Icons.folder_special,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Text('${l10n?.moveTo ?? 'ย้ายไป'} ${l10n?.root ?? 'Root'}'),
                  ],
                ),
                dense: true,
              ),

            // Folders list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _folders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n?.noFoldersFound ?? 'ไม่มีโฟลเดอร์',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _folders.length,
                          itemBuilder: (context, index) {
                            final folder = _folders[index];
                            final name = fileService.getFolderName(
                              folder,
                              widget.masterKey,
                            );

                            // Don't show current folder
                            if (folder.id == widget.currentFolderId) {
                              return const SizedBox.shrink();
                            }

                            return RadioListTile<int?>(
                              value: folder.id,
                              groupValue: _selectedFolderId,
                              onChanged: (value) =>
                                  setState(() => _selectedFolderId = value),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.folder,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () => _enterFolder(folder),
                                    tooltip: l10n?.openVault ?? 'เปิดโฟลเดอร์',
                                  ),
                                ],
                              ),
                              subtitle: Text('${folder.fileCount} ${l10n?.files ?? 'ไฟล์'}'),
                              dense: true,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'ยกเลิก'),
        ),
        FilledButton.icon(
          onPressed: _selectedFolderId != null
              ? () => Navigator.pop(context, _selectedFolderId)
              : null,
          icon: const Icon(Icons.drive_file_move),
          label: Text(l10n?.moveTo ?? 'ย้าย'),
        ),
      ],
    );
  }
}
