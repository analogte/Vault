import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/backup_service.dart';
import '../../../services/cloud_backup_service.dart';
import '../../../l10n/app_localizations.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  late final CloudBackupService _cloudBackupService;

  bool _isCreatingBackup = false;
  bool _isRestoringBackup = false;
  String _statusMessage = '';
  double _progress = 0.0;

  // Cloud backup
  List<CloudBackupInfo> _cloudBackups = [];
  bool _isLoadingCloudBackups = false;

  // Backup password
  final _passwordController = TextEditingController();
  bool _usePassword = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _cloudBackupService = CloudBackupService();
    _cloudBackupService.addListener(_onCloudServiceChanged);
    _loadCloudBackupsIfSignedIn();
  }

  void _onCloudServiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCloudBackupsIfSignedIn() async {
    if (_cloudBackupService.isSignedIn) {
      await _loadCloudBackups();
    }
  }

  Future<void> _loadCloudBackups() async {
    setState(() => _isLoadingCloudBackups = true);
    _cloudBackups = await _cloudBackupService.listBackups();
    if (mounted) setState(() => _isLoadingCloudBackups = false);
  }

  @override
  void dispose() {
    _cloudBackupService.removeListener(_onCloudServiceChanged);
    _cloudBackupService.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.backupTitle ?? 'สำรองข้อมูล'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.backupInfo ?? 'เกี่ยวกับการสำรองข้อมูล',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• ${l10n?.backupInfo1 ?? 'ไฟล์ Backup จะรวม Vaults, Folders และไฟล์ทั้งหมด'}\n'
                    '• ${l10n?.backupInfo2 ?? 'ไฟล์ยังคงเข้ารหัสอยู่ ปลอดภัยแม้แชร์ไป Cloud'}\n'
                    '• ${l10n?.backupInfo3 ?? 'สามารถตั้งรหัสผ่านเพิ่มเติมเพื่อความปลอดภัย'}\n'
                    '• ${l10n?.backupInfo4 ?? 'แนะนำให้สำรองข้อมูลเป็นประจำ'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Create Backup Section
          Text(
            l10n?.createBackup ?? 'สร้าง Backup',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Password option
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n?.setBackupPassword ?? 'ตั้งรหัสผ่าน Backup'),
                  subtitle: Text(l10n?.setBackupPasswordSubtitle ?? 'เข้ารหัสไฟล์ backup ด้วยรหัสผ่านเพิ่มเติม'),
                  secondary: const Icon(Icons.lock_outline),
                  value: _usePassword,
                  onChanged: _isCreatingBackup || _isRestoringBackup
                      ? null
                      : (value) => setState(() => _usePassword = value),
                ),
                if (_usePassword)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !_isCreatingBackup && !_isRestoringBackup,
                      decoration: InputDecoration(
                        labelText: l10n?.password ?? 'รหัสผ่าน',
                        hintText: l10n?.enterBackupPassword ?? 'ใส่รหัสผ่านสำหรับ backup',
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Create backup button
          FilledButton.icon(
            onPressed: _isCreatingBackup || _isRestoringBackup
                ? null
                : _createBackup,
            icon: _isCreatingBackup
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.backup),
            label: Text(_isCreatingBackup
                ? (l10n?.creating ?? 'กำลังสร้าง...')
                : (l10n?.createBackup ?? 'สร้าง Backup')),
          ),

          const SizedBox(height: 32),

          // Restore Backup Section
          Text(
            l10n?.restoreFromBackup ?? 'กู้คืนจาก Backup',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restore,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n?.selectBackupFile ?? 'เลือกไฟล์ .svbackup เพื่อกู้คืน',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ ${l10n?.duplicateVaultWarning ?? 'หาก Vault ที่กู้คืนมีชื่อซ้ำกับที่มีอยู่ ระบบจะข้ามการกู้คืน vault นั้น'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Restore button
          OutlinedButton.icon(
            onPressed: _isCreatingBackup || _isRestoringBackup
                ? null
                : _restoreBackup,
            icon: _isRestoringBackup
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.upload_file),
            label: Text(_isRestoringBackup
                ? (l10n?.restoring ?? 'กำลังกู้คืน...')
                : (l10n?.selectBackupFileButton ?? 'เลือกไฟล์ Backup')),
          ),

          // Progress indicator
          if (_isCreatingBackup || _isRestoringBackup) ...[
            const SizedBox(height: 24),
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Google Drive Backup Section
          _buildGoogleDriveSection(theme, l10n),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGoogleDriveSection(ThemeData theme, S? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Google Drive Backup',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sign in status card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _cloudBackupService.isSignedIn
                ? _buildSignedInContent(theme, l10n)
                : _buildSignedOutContent(theme, l10n),
          ),
        ),

        // Cloud backups list
        if (_cloudBackupService.isSignedIn) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Backup ใน Drive',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_isLoadingCloudBackups)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCloudBackups,
                  tooltip: 'รีเฟรช',
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_cloudBackups.isEmpty && !_isLoadingCloudBackups)
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'ยังไม่มี Backup ใน Google Drive',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            ..._cloudBackups.map((backup) => _buildCloudBackupTile(backup, theme, l10n)),
        ],

        // Cloud backup progress
        if (_cloudBackupService.isLoading) ...[
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _cloudBackupService.uploadProgress > 0
                        ? _cloudBackupService.uploadProgress
                        : null,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _cloudBackupService.statusMessage ?? 'กำลังดำเนินการ...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSignedOutContent(ThemeData theme, S? l10n) {
    return Column(
      children: [
        const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        const Text(
          'เข้าสู่ระบบ Google เพื่อสำรองข้อมูลไปยัง Drive',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _signInToGoogle,
          icon: const Icon(Icons.login),
          label: const Text('เข้าสู่ระบบ Google'),
        ),
      ],
    );
  }

  Widget _buildSignedInContent(ThemeData theme, S? l10n) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: _cloudBackupService.userPhotoUrl != null
                  ? NetworkImage(_cloudBackupService.userPhotoUrl!)
                  : null,
              child: _cloudBackupService.userPhotoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cloudBackupService.userDisplayName ?? 'Google User',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _cloudBackupService.userEmail ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOutFromGoogle,
              tooltip: 'ออกจากระบบ',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _cloudBackupService.isLoading ? null : _backupToGoogleDrive,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Backup ไป Drive'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCloudBackupTile(CloudBackupInfo backup, ThemeData theme, S? l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.backup, color: Colors.blue),
        title: Text(
          backup.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${backup.formattedSize} • ${backup.formattedDate}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        trailing: PopupMenuButton<String>(
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
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('ลบ', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'restore') {
              _restoreFromGoogleDrive(backup);
            } else if (value == 'delete') {
              _deleteCloudBackup(backup);
            }
          },
        ),
      ),
    );
  }

  Future<void> _signInToGoogle() async {
    final success = await _cloudBackupService.signIn();
    if (success) {
      await _loadCloudBackups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เข้าสู่ระบบ Google สำเร็จ')),
        );
      }
    }
  }

  Future<void> _signOutFromGoogle() async {
    await _cloudBackupService.signOut();
    _cloudBackups = [];
    if (mounted) setState(() {});
  }

  Future<void> _backupToGoogleDrive() async {
    final l10n = S.of(context);

    // Create local backup first
    setState(() {
      _isCreatingBackup = true;
      _progress = 0.0;
      _statusMessage = l10n?.preparing ?? 'กำลังเตรียมข้อมูล...';
    });

    final result = await _backupService.createBackup(
      password: _usePassword ? _passwordController.text : null,
      onProgress: (status, progress) {
        if (mounted) {
          setState(() {
            _statusMessage = _localizeProgressStatus(status);
            _progress = progress;
          });
        }
      },
    );

    if (!mounted) return;

    setState(() => _isCreatingBackup = false);

    if (!result.success || result.filePath == null) {
      _showSnackBar(result.error ?? 'สร้าง backup ไม่สำเร็จ', isError: true);
      return;
    }

    // Upload to Google Drive
    final file = File(result.filePath!);
    final fileName = 'SecureVault_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.svbackup';

    final uploadSuccess = await _cloudBackupService.uploadBackup(
      backupFile: file,
      fileName: fileName,
    );

    // Clean up local backup file
    await _backupService.deleteBackupFile(result.filePath!);

    if (uploadSuccess) {
      await _loadCloudBackups();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup ไป Google Drive สำเร็จ')),
        );
      }
    } else {
      if (mounted) {
        _showSnackBar(_cloudBackupService.statusMessage ?? 'อัปโหลดไม่สำเร็จ', isError: true);
      }
    }
  }

  Future<void> _restoreFromGoogleDrive(CloudBackupInfo backup) async {
    final l10n = S.of(context);

    // Download from Google Drive
    final downloadedFile = await _cloudBackupService.downloadBackup(
      fileId: backup.id,
      fileName: backup.name,
    );

    if (downloadedFile == null) {
      if (mounted) {
        _showSnackBar(_cloudBackupService.statusMessage ?? 'ดาวน์โหลดไม่สำเร็จ', isError: true);
      }
      return;
    }

    // Check if backup needs password
    final info = await _backupService.getBackupInfo(downloadedFile.path);

    String? password;
    if (info == null || info.isPasswordProtected) {
      password = await _showPasswordDialog();
      if (password == null) {
        await downloadedFile.delete();
        return;
      }

      if (info == null) {
        final infoWithPassword = await _backupService.getBackupInfo(downloadedFile.path, password: password);
        if (infoWithPassword == null) {
          _showSnackBar(l10n?.wrongPasswordOrCorrupt ?? 'รหัสผ่านไม่ถูกต้อง', isError: true);
          await downloadedFile.delete();
          return;
        }

        if (!mounted) return;
        final shouldRestore = await _showBackupInfoDialog(infoWithPassword);
        if (shouldRestore != true) {
          await downloadedFile.delete();
          return;
        }
      } else {
        if (!mounted) return;
        final shouldRestore = await _showBackupInfoDialog(info);
        if (shouldRestore != true) {
          await downloadedFile.delete();
          return;
        }
      }
    } else {
      if (!mounted) return;
      final shouldRestore = await _showBackupInfoDialog(info);
      if (shouldRestore != true) {
        await downloadedFile.delete();
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _isRestoringBackup = true;
      _progress = 0.0;
      _statusMessage = l10n?.preparing ?? 'กำลังเตรียมข้อมูล...';
    });

    final result = await _backupService.restoreBackup(
      downloadedFile.path,
      password: password,
      overwrite: false,
      onProgress: (status, progress) {
        if (mounted) {
          setState(() {
            _statusMessage = _localizeProgressStatus(status);
            _progress = progress;
          });
        }
      },
    );

    // Clean up downloaded file
    await downloadedFile.delete();

    if (!mounted) return;

    setState(() => _isRestoringBackup = false);

    if (result.success) {
      _showRestoreSuccessDialog(result);
    } else {
      _showSnackBar(result.error ?? 'กู้คืนไม่สำเร็จ', isError: true);
    }
  }

  Future<void> _deleteCloudBackup(CloudBackupInfo backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบ Backup'),
        content: Text('คุณต้องการลบ "${backup.name}" จาก Google Drive หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _cloudBackupService.deleteBackup(backup.id);
      if (success) {
        await _loadCloudBackups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ลบ backup สำเร็จ')),
          );
        }
      }
    }
  }

  Future<void> _createBackup() async {
    final l10n = S.of(context);

    // Validate password if enabled
    if (_usePassword && _passwordController.text.isEmpty) {
      _showSnackBar(l10n?.pleaseEnterPassword ?? 'กรุณาใส่รหัสผ่าน', isError: true);
      return;
    }

    if (_usePassword && _passwordController.text.length < 4) {
      _showSnackBar(l10n?.passwordMinLength ?? 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร', isError: true);
      return;
    }

    setState(() {
      _isCreatingBackup = true;
      _progress = 0.0;
      _statusMessage = l10n?.preparing ?? 'กำลังเตรียมข้อมูล...';
    });

    final result = await _backupService.createBackup(
      password: _usePassword ? _passwordController.text : null,
      onProgress: (status, progress) {
        if (mounted) {
          setState(() {
            _statusMessage = _localizeProgressStatus(status);
            _progress = progress;
          });
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _isCreatingBackup = false;
    });

    if (result.success && result.filePath != null) {
      _showBackupSuccessDialog(result);
    } else {
      _showSnackBar(result.error ?? (l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'), isError: true);
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = S.of(context);

    // Pick backup file
    final filePath = await _backupService.pickBackupFile();
    if (filePath == null) return;

    // Check if backup needs password
    final info = await _backupService.getBackupInfo(filePath);

    String? password;
    if (info == null) {
      // Could be password protected, ask for password
      password = await _showPasswordDialog();
      if (password == null) return;

      // Try with password
      final infoWithPassword =
          await _backupService.getBackupInfo(filePath, password: password);
      if (infoWithPassword == null) {
        _showSnackBar(l10n?.wrongPasswordOrCorrupt ?? 'รหัสผ่านไม่ถูกต้องหรือไฟล์เสียหาย', isError: true);
        return;
      }

      if (!mounted) return;
      // Show backup info and confirm
      final shouldRestore = await _showBackupInfoDialog(infoWithPassword);
      if (shouldRestore != true) return;
    } else if (info.isPasswordProtected) {
      password = await _showPasswordDialog();
      if (password == null) return;

      if (!mounted) return;
      // Show backup info and confirm
      final shouldRestore = await _showBackupInfoDialog(info);
      if (shouldRestore != true) return;
    } else {
      if (!mounted) return;
      // Show backup info and confirm
      final shouldRestore = await _showBackupInfoDialog(info);
      if (shouldRestore != true) return;
    }

    if (!mounted) return;

    setState(() {
      _isRestoringBackup = true;
      _progress = 0.0;
      _statusMessage = l10n?.preparing ?? 'กำลังเตรียมข้อมูล...';
    });

    final result = await _backupService.restoreBackup(
      filePath,
      password: password,
      overwrite: false,
      onProgress: (status, progress) {
        if (mounted) {
          setState(() {
            _statusMessage = _localizeProgressStatus(status);
            _progress = progress;
          });
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _isRestoringBackup = false;
    });

    if (result.success) {
      _showRestoreSuccessDialog(result);
    } else {
      _showSnackBar(result.error ?? (l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'), isError: true);
    }
  }

  String _localizeProgressStatus(String status) {
    final l10n = S.of(context);

    // Map English status messages to localized versions
    if (status.contains('Preparing') || status.contains('กำลังเตรียม')) {
      return l10n?.preparing ?? 'กำลังเตรียมข้อมูล...';
    }
    if (status.contains('Creating backup file') || status.contains('กำลังสร้างไฟล์')) {
      return l10n?.creatingBackupFile ?? 'กำลังสร้างไฟล์ backup...';
    }
    if (status.contains('Backing up vaults') || status.contains('backup vaults')) {
      return l10n?.backingUpVaults ?? 'กำลัง backup vaults...';
    }
    if (status.contains('Backing up file data') || status.contains('backup ข้อมูลไฟล์')) {
      return l10n?.backingUpFileData ?? 'กำลัง backup ข้อมูลไฟล์...';
    }
    if (status.contains('Backing up encrypted') || status.contains('backup encrypted')) {
      return l10n?.backingUpEncryptedFiles ?? 'กำลัง backup encrypted files...';
    }
    if (status.contains('Compressing') || status.contains('บีบอัด')) {
      return l10n?.compressing ?? 'กำลังบีบอัดข้อมูล...';
    }
    if (status.contains('Encrypting') || status.contains('เข้ารหัส')) {
      return l10n?.encrypting ?? 'กำลังเข้ารหัส backup...';
    }
    if (status.contains('Done') || status.contains('เสร็จ')) {
      return l10n?.done ?? 'เสร็จสิ้น!';
    }
    if (status.contains('Reading') || status.contains('อ่าน')) {
      return l10n?.readingBackup ?? 'กำลังอ่านไฟล์ backup...';
    }
    if (status.contains('Decrypting') || status.contains('ถอดรหัส')) {
      return l10n?.decrypting ?? 'กำลังถอดรหัส backup...';
    }
    if (status.contains('Extracting') || status.contains('แตกไฟล์')) {
      return l10n?.extracting ?? 'กำลังแตกไฟล์...';
    }
    if (status.contains('Restoring vaults') || status.contains('restore vaults')) {
      return l10n?.restoringVaults ?? 'กำลัง restore vaults...';
    }
    if (status.contains('Restoring folders') || status.contains('restore folders')) {
      return l10n?.restoringFolders ?? 'กำลัง restore folders...';
    }
    if (status.contains('Restoring files') || status.contains('restore files')) {
      return l10n?.restoringFiles ?? 'กำลัง restore files...';
    }

    // Return original status if no match
    return status;
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    bool obscure = true;
    final l10n = S.of(context);

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n?.enterBackupPasswordPrompt ?? 'ใส่รหัสผ่าน Backup'),
          content: TextField(
            controller: controller,
            obscureText: obscure,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n?.password ?? 'รหัสผ่าน',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscure = !obscure),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(l10n?.ok ?? 'ตกลง'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showBackupInfoDialog(BackupInfo info) async {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final l10n = S.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.backup),
            const SizedBox(width: 8),
            Text(l10n?.backupInfoTitle ?? 'ข้อมูล Backup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(l10n?.createdAt ?? 'สร้างเมื่อ', dateFormat.format(info.createdAt)),
            _buildInfoRow(l10n?.device ?? 'อุปกรณ์', info.deviceName),
            _buildInfoRow(l10n?.vaultCount ?? 'จำนวน Vault', '${info.vaultCount}'),
            _buildInfoRow(l10n?.fileCount ?? 'จำนวนไฟล์', '${info.fileCount}'),
            _buildInfoRow(l10n?.folderCount ?? 'จำนวนโฟลเดอร์', '${info.folderCount}'),
            _buildInfoRow(
                l10n?.passwordProtected ?? 'รหัสผ่าน',
                info.isPasswordProtected
                    ? (l10n?.yes ?? 'มี')
                    : (l10n?.no ?? 'ไม่มี')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.duplicateSkipped ?? 'Vault ที่มีชื่อซ้ำจะถูกข้าม',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n?.restore ?? 'กู้คืน'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showBackupSuccessDialog(BackupResult result) async {
    final l10n = S.of(context);
    final size = await _backupService.getBackupFileSize(result.filePath!);
    final sizeText = _backupService.formatFileSize(size);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(l10n?.backupCreatedSuccess ?? 'สร้าง Backup สำเร็จ!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(l10n?.vaults ?? 'Vaults', '${result.vaultCount}'),
            _buildInfoRow(l10n?.files ?? 'ไฟล์', '${result.fileCount}'),
            _buildInfoRow(l10n?.folders ?? 'โฟลเดอร์', '${result.folderCount}'),
            _buildInfoRow(l10n?.fileSize ?? 'ขนาดไฟล์', sizeText),
            const SizedBox(height: 16),
            Text(
              l10n?.selectSaveMethod ?? 'เลือกวิธีบันทึกไฟล์ backup:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _backupService.deleteBackupFile(result.filePath!);
            },
            child: Text(l10n?.cancel ?? 'ยกเลิก'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final saved =
                  await _backupService.saveBackupToLocation(result.filePath!);
              if (saved != null) {
                _showSnackBar(l10n?.fileSaved ?? 'บันทึกไฟล์สำเร็จ');
              }
              await _backupService.deleteBackupFile(result.filePath!);
            },
            icon: const Icon(Icons.save),
            label: Text(l10n?.save ?? 'บันทึก'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _backupService.shareBackup(result.filePath!);
              await _backupService.deleteBackupFile(result.filePath!);
            },
            icon: const Icon(Icons.share),
            label: Text(l10n?.share ?? 'แชร์'),
          ),
        ],
      ),
    );
  }

  void _showRestoreSuccessDialog(RestoreResult result) {
    final l10n = S.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(l10n?.restoreSuccess ?? 'กู้คืนสำเร็จ!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(l10n?.vaultsRestored ?? 'Vaults ที่กู้คืน', '${result.vaultCount}'),
            _buildInfoRow(l10n?.filesRestored ?? 'ไฟล์ที่กู้คืน', '${result.fileCount}'),
            _buildInfoRow(l10n?.foldersRestored ?? 'โฟลเดอร์ที่กู้คืน', '${result.folderCount}'),
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n?.warnings ?? 'คำเตือน:',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ...result.warnings.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              Text(w, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.ok ?? 'ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}
