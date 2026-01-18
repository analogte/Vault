import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class MultiSelectToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  const MultiSelectToolbar({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onClear,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Selected count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.selectedCount(selectedCount) ?? '$selectedCount รายการที่เลือก',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Select all button
            IconButton(
              onPressed: onSelectAll,
              icon: const Icon(Icons.select_all),
              tooltip: l10n?.selectAll ?? 'เลือกทั้งหมด',
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),

            // Move to folder button
            IconButton(
              onPressed: onMove,
              icon: const Icon(Icons.drive_file_move),
              tooltip: l10n?.moveToFolder ?? 'ย้ายไปโฟลเดอร์',
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),

            // Delete button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              tooltip: l10n?.movedToTrash ?? 'ย้ายไปถังขยะ',
              color: Colors.red,
            ),

            // Clear selection button
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              tooltip: l10n?.deselectAll ?? 'ยกเลิกการเลือก',
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
