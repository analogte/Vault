import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../../core/models/file_folder.dart';
import '../../../services/file_service.dart';
import '../../../l10n/app_localizations.dart';

class FolderBreadcrumb extends StatelessWidget {
  final List<FileFolder> path;
  final Uint8List masterKey;
  final Function(int index) onNavigate;

  const FolderBreadcrumb({
    super.key,
    required this.path,
    required this.masterKey,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final fileService = Provider.of<FileService>(context, listen: false);
    final l10n = S.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Root
            InkWell(
              onTap: () => onNavigate(-1),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n?.root ?? 'Root',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Path items
            ...path.asMap().entries.map((entry) {
              final index = entry.key;
              final folder = entry.value;
              final isLast = index == path.length - 1;
              final folderName = fileService.getFolderName(folder, masterKey);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  InkWell(
                    onTap: isLast ? null : () => onNavigate(index),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        folderName,
                        style: TextStyle(
                          color: isLast
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
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
    );
  }
}
