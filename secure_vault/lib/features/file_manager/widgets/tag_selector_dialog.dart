import 'package:flutter/material.dart';
import '../../../core/models/file_tag.dart';
import '../../../core/storage/database_helper.dart';

class TagSelectorDialog extends StatefulWidget {
  final int vaultId;
  final int fileId;
  final List<FileTag> currentTags;

  const TagSelectorDialog({
    super.key,
    required this.vaultId,
    required this.fileId,
    required this.currentTags,
  });

  @override
  State<TagSelectorDialog> createState() => _TagSelectorDialogState();
}

class _TagSelectorDialogState extends State<TagSelectorDialog> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<FileTag> _allTags = [];
  Set<int> _selectedTagIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTagIds = widget.currentTags.where((t) => t.id != null).map((t) => t.id!).toSet();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    try {
      final tags = await _db.getTagsByVault(widget.vaultId);
      if (mounted) {
        setState(() {
          _allTags = tags;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createTag() async {
    final result = await showDialog<FileTag>(
      context: context,
      builder: (context) => CreateTagDialog(vaultId: widget.vaultId),
    );

    if (result != null) {
      await _loadTags();
      if (result.id != null) {
        setState(() => _selectedTagIds.add(result.id!));
      }
    }
  }

  void _toggleTag(int tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });
  }

  Future<void> _save() async {
    await _db.setTagsForFile(widget.fileId, _selectedTagIds.toList());
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.label),
          SizedBox(width: 8),
          Text('จัดการ Tags'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_allTags.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'ยังไม่มี Tags\nกด + เพื่อสร้าง Tag ใหม่',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allTags.map((tag) {
                          final isSelected = tag.id != null && _selectedTagIds.contains(tag.id);
                          return FilterChip(
                            label: Text(tag.name),
                            selected: isSelected,
                            onSelected: (_) {
                              if (tag.id != null) {
                                _toggleTag(tag.id!);
                              }
                            },
                            selectedColor: Color(tag.colorValue).withValues(alpha: 0.3),
                            checkmarkColor: Color(tag.colorValue),
                            avatar: CircleAvatar(
                              backgroundColor: Color(tag.colorValue),
                              radius: 8,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: _createTag,
                      icon: const Icon(Icons.add),
                      label: const Text('สร้าง Tag ใหม่'),
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}

class CreateTagDialog extends StatefulWidget {
  final int vaultId;

  const CreateTagDialog({super.key, required this.vaultId});

  @override
  State<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends State<CreateTagDialog> {
  final _nameController = TextEditingController();
  String _selectedColor = FileTag.predefinedColors.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาใส่ชื่อ Tag')),
      );
      return;
    }

    final tag = FileTag(
      vaultId: widget.vaultId,
      name: _nameController.text.trim(),
      color: _selectedColor,
      createdAt: DateTime.now(),
    );

    final id = await DatabaseHelper.instance.createTag(tag);

    if (mounted) {
      Navigator.pop(context, tag.copyWith(id: id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('สร้าง Tag ใหม่'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'ชื่อ Tag',
              hintText: 'เช่น: งาน, ส่วนตัว, สำคัญ',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          const Text('เลือกสี:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FileTag.predefinedColors.map((color) {
              final isSelected = _selectedColor == color;
              final colorValue = int.parse(color.replaceFirst('#', '0xFF'));
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(colorValue),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _create,
          child: const Text('สร้าง'),
        ),
      ],
    );
  }
}
