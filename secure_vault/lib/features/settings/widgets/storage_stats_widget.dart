import 'package:flutter/material.dart';
import '../../../core/storage/database_helper.dart';
import '../../../l10n/app_localizations.dart';

class StorageStatsWidget extends StatefulWidget {
  final int? vaultId;

  const StorageStatsWidget({super.key, this.vaultId});

  @override
  State<StorageStatsWidget> createState() => _StorageStatsWidgetState();
}

class _StorageStatsWidgetState extends State<StorageStatsWidget> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await DatabaseHelper.instance.getStorageStats(vaultId: widget.vaultId);
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_stats == null) {
      return const SizedBox.shrink();
    }

    final totalFiles = _stats!['totalFiles'] as int;
    final totalSize = _stats!['totalSize'] as int;
    final trashFiles = _stats!['trashFiles'] as int;
    final trashSize = _stats!['trashSize'] as int;
    final folderCount = _stats!['folderCount'] as int;
    final byCategory = _stats!['byCategory'] as Map<String, Map<String, int>>;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.storage, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n?.storageStats ?? 'สถิติการใช้งาน',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadStats,
                  tooltip: l10n?.loading ?? 'รีเฟรช',
                ),
              ],
            ),
            const Divider(),

            // Total stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.folder,
                    label: l10n?.folders ?? 'โฟลเดอร์',
                    value: '$folderCount',
                    color: Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.insert_drive_file,
                    label: l10n?.files ?? 'ไฟล์',
                    value: '$totalFiles',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.sd_storage,
                    label: l10n?.size ?? 'ขนาด',
                    value: _formatSize(totalSize),
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Category breakdown
            Text(
              l10n?.byCategory ?? 'แยกตามประเภท',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            _buildCategoryBar(byCategory, totalSize, theme),

            const SizedBox(height: 8),

            // Category details
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildCategoryChip(
                  l10n?.filterImages ?? 'รูปภาพ',
                  byCategory['images']!['count']!,
                  byCategory['images']!['size']!,
                  Colors.green,
                ),
                _buildCategoryChip(
                  l10n?.filterVideos ?? 'วิดีโอ',
                  byCategory['videos']!['count']!,
                  byCategory['videos']!['size']!,
                  Colors.red,
                ),
                _buildCategoryChip(
                  l10n?.filterDocuments ?? 'เอกสาร',
                  byCategory['documents']!['count']!,
                  byCategory['documents']!['size']!,
                  Colors.blue,
                ),
                _buildCategoryChip(
                  l10n?.filterAudio ?? 'เสียง',
                  byCategory['audio']!['count']!,
                  byCategory['audio']!['size']!,
                  Colors.purple,
                ),
                _buildCategoryChip(
                  l10n?.other ?? 'อื่นๆ',
                  byCategory['other']!['count']!,
                  byCategory['other']!['size']!,
                  Colors.grey,
                ),
              ],
            ),

            // Trash info
            if (trashFiles > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n?.trash ?? 'ถังขยะ'}: $trashFiles ${l10n?.files ?? 'ไฟล์'} (${_formatSize(trashSize)})',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBar(
    Map<String, Map<String, int>> byCategory,
    int totalSize,
    ThemeData theme,
  ) {
    if (totalSize == 0) {
      return Container(
        height: 12,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    final categories = [
      ('images', Colors.green),
      ('videos', Colors.red),
      ('documents', Colors.blue),
      ('audio', Colors.purple),
      ('other', Colors.grey),
    ];

    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: categories.map((cat) {
          final size = byCategory[cat.$1]!['size']!;
          final flex = ((size / totalSize) * 100).round();
          if (flex == 0) return const SizedBox.shrink();
          return Expanded(
            flex: flex.clamp(1, 100),
            child: Container(color: cat.$2),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label, int count, int size, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count (${_formatSize(size)})',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
