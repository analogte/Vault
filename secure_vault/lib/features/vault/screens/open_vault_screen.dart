import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/vault.dart';
import '../../../core/encryption/key_manager.dart';
import '../../../services/vault_service.dart';
import '../../../services/biometric_service.dart';
import '../../../services/security_service.dart';
import '../../file_manager/screens/file_manager_screen.dart';
import '../../../l10n/app_localizations.dart';

class OpenVaultScreen extends StatefulWidget {
  final Vault vault;

  const OpenVaultScreen({super.key, required this.vault});

  @override
  State<OpenVaultScreen> createState() => _OpenVaultScreenState();
}

class _OpenVaultScreenState extends State<OpenVaultScreen> {
  final _passwordController = TextEditingController();
  final _biometricService = BiometricService();
  final _securityService = SecurityService();

  bool _obscurePassword = true;
  bool _isOpening = false;
  String? _errorMessage;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricTypeName = 'Biometric';

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = widget.vault.id != null
        ? await _biometricService.isVaultBiometricEnabled(widget.vault.id!)
        : false;
    final types = await _biometricService.getAvailableBiometrics();

    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = enabled;
      _biometricTypeName = _biometricService.getBiometricTypeName(types);
    });

    // Auto-trigger biometric if enabled
    if (enabled && available) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _openWithBiometric();
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openWithBiometric() async {
    if (!_biometricEnabled || widget.vault.id == null) return;

    setState(() {
      _isOpening = true;
      _errorMessage = null;
    });

    try {
      final password =
          await _biometricService.authenticateAndGetPassword(widget.vault.id!);

      if (password == null) {
        setState(() {
          _isOpening = false;
        });
        return;
      }

      await _openVaultWithPassword(password);
    } catch (e) {
      final l10n = S.of(context);
      setState(() {
        _errorMessage = l10n?.biometricAuthFailed ?? 'การยืนยันตัวตนล้มเหลว';
        _isOpening = false;
      });
    }
  }

  Future<void> _openVault() async {
    final l10n = S.of(context);
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = l10n?.pleaseEnterPassword ?? 'กรุณากรอกรหัสผ่าน');
      return;
    }

    setState(() {
      _isOpening = true;
      _errorMessage = null;
    });

    await _openVaultWithPassword(_passwordController.text);
  }

  Future<void> _openVaultWithPassword(String password) async {
    final l10n = S.of(context);
    try {
      final vaultService = Provider.of<VaultService>(context, listen: false);
      final masterKey = await vaultService.openVault(widget.vault, password);

      if (masterKey == null) {
        setState(() {
          _errorMessage = l10n?.wrongPassword ?? 'รหัสผ่านไม่ถูกต้อง';
          _isOpening = false;
        });
        return;
      }

      // Set current vault in security service
      if (widget.vault.id != null) {
        _securityService.setCurrentVault(widget.vault.id);
        _securityService.unlock();
      }

      // Ask to enable biometric if not enabled and available
      if (_biometricAvailable &&
          !_biometricEnabled &&
          widget.vault.id != null &&
          mounted) {
        final shouldEnable = await _showEnableBiometricDialog();
        if (shouldEnable) {
          await _biometricService.enableVaultBiometric(
            widget.vault.id!,
            password,
          );
        }
      }

      // Check if vault needs Argon2id migration
      if (KeyManager.shouldMigrate(widget.vault.kdfVersion) && mounted) {
        final shouldMigrate = await _showMigrationDialog();
        if (shouldMigrate && widget.vault.id != null) {
          await _performMigration(password, vaultService);
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FileManagerScreen(
              vault: widget.vault,
              masterKey: masterKey,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${l10n?.errorOccurred ?? 'เกิดข้อผิดพลาด'}: $e';
        _isOpening = false;
      });
    }
  }

  Future<bool> _showMigrationDialog() async {
    final l10n = S.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.security_update,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n?.upgradeSecurityTitle ?? 'อัปเกรดความปลอดภัย'),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.upgradeSecurityDescription ?? 'Vault นี้ใช้ PBKDF2 ซึ่งเป็นมาตรฐานเก่า\n\nแนะนำให้อัปเกรดเป็น Argon2id ซึ่ง:',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n?.gpuAttackResistant ?? 'ทนทานต่อการโจมตีด้วย GPU')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n?.asicAttackResistant ?? 'ทนทานต่อการโจมตีด้วย ASIC')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n?.latestSecurityStandard ?? 'มาตรฐานความปลอดภัยล่าสุด')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.passwordRemainsNote ?? 'หมายเหตุ: รหัสผ่านจะยังคงเหมือนเดิม',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n?.upgradeLater ?? 'ไว้ทีหลัง'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.upgrade),
                label: Text(l10n?.upgradeNow ?? 'อัปเกรด'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _performMigration(
    String password,
    VaultService vaultService,
  ) async {
    final l10n = S.of(context);
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Text(l10n?.upgradingProgress ?? 'กำลังอัปเกรด...'),
          ],
        ),
      ),
    );

    try {
      await vaultService.migrateVaultToArgon2id(widget.vault, password);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.upgradeToArgon2idSuccess ?? 'อัปเกรดเป็น Argon2id สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.upgradeToArgon2idFailed ?? 'อัปเกรดล้มเหลว'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showEnableBiometricDialog() async {
    final l10n = S.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n?.enableBiometricQuestion ?? 'เปิดใช้งาน Biometric?'),
                ),
              ],
            ),
            content: Text(
              l10n?.enableBiometricDescription(_biometricTypeName) ??
              'ต้องการใช้ $_biometricTypeName เพื่อปลดล็อค Vault นี้ในครั้งถัดไปหรือไม่?\n\nคุณยังสามารถใช้รหัสผ่านได้เหมือนเดิม',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n?.doNotUse ?? 'ไม่ใช้'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.fingerprint),
                label: Text(l10n?.enable ?? 'เปิดใช้งาน'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vault.name),
        actions: [
          if (_biometricEnabled && widget.vault.id != null)
            IconButton(
              icon: const Icon(Icons.fingerprint_outlined),
              tooltip: l10n?.biometricSettings ?? 'ตั้งค่า Biometric',
              onPressed: _showBiometricSettings,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 80,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              l10n?.enterPasswordToOpen ?? 'กรุณากรอกรหัสผ่านเพื่อเปิด Vault',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Biometric button (if enabled)
            if (_biometricEnabled && _biometricAvailable) ...[
              OutlinedButton.icon(
                onPressed: _isOpening ? null : _openWithBiometric,
                icon: const Icon(Icons.fingerprint, size: 28),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                label: Text(
                  l10n?.biometricUnlock(_biometricTypeName) ?? 'ปลดล็อคด้วย $_biometricTypeName',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n?.orDivider ?? 'หรือ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: l10n?.password ?? 'รหัสผ่าน',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              onSubmitted: (_) => _openVault(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isOpening ? null : _openVault,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isOpening
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n?.openVaultButton ?? 'เปิด Vault', style: const TextStyle(fontSize: 16)),
            ),

            // Enable biometric hint
            if (_biometricAvailable && !_biometricEnabled) ...[
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.fingerprint,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(l10n?.biometricAvailableHint(_biometricTypeName) ?? '$_biometricTypeName พร้อมใช้งาน'),
                  subtitle: Text(
                    l10n?.biometricFirstTimeHint ?? 'เปิด Vault ด้วยรหัสผ่านครั้งแรก แล้วระบบจะถามว่าต้องการเปิดใช้งานหรือไม่',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBiometricSettings() {
    final l10n = S.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: Text(l10n?.biometricEnabledForVault(_biometricTypeName) ?? '$_biometricTypeName เปิดใช้งานอยู่'),
              subtitle: Text(l10n?.forThisVault ?? 'สำหรับ Vault นี้'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                l10n?.disableBiometric ?? 'ปิดใช้งาน Biometric',
                style: const TextStyle(color: Colors.red),
              ),
              subtitle: Text(l10n?.requirePasswordEveryTime ?? 'ต้องใช้รหัสผ่านทุกครั้ง'),
              onTap: () async {
                Navigator.pop(context);
                if (widget.vault.id != null) {
                  await _biometricService
                      .disableVaultBiometric(widget.vault.id!);
                  setState(() => _biometricEnabled = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n?.biometricDisabled ?? 'ปิดใช้งาน Biometric แล้ว')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
