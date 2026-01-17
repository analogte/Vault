import 'package:flutter/material.dart';

/// Dialog showing upload progress with file-by-file status
class UploadProgressDialog extends StatelessWidget {
  final int currentFile;
  final int totalFiles;
  final String currentFileName;
  final double fileProgress;
  final String statusText;
  final VoidCallback? onCancel;

  const UploadProgressDialog({
    super.key,
    required this.currentFile,
    required this.totalFiles,
    required this.currentFileName,
    required this.fileProgress,
    required this.statusText,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final overallProgress = totalFiles > 0
        ? (currentFile - 1 + fileProgress) / totalFiles
        : 0.0;

    return PopScope(
      canPop: false, // Prevent dismissing with back button
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  const Icon(Icons.cloud_upload, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'กำลังอัปโหลด',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Overall progress
              Text(
                'ไฟล์ที่ $currentFile จาก $totalFiles',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(overallProgress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),

              const SizedBox(height: 16),

              // Current file info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentFileName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fileProgress,
                              minHeight: 4,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(fileProgress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // Cancel button (optional)
              if (onCancel != null) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('ยกเลิก'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
