import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/vault_service.dart';
import 'open_vault_screen.dart';

class CreateVaultScreen extends StatefulWidget {
  const CreateVaultScreen({super.key});

  @override
  State<CreateVaultScreen> createState() => _CreateVaultScreenState();
}

class _CreateVaultScreenState extends State<CreateVaultScreen> {
  static const String _tag = 'CreateVaultScreen';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createVault() async {
    final l10n = S.of(context);

    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate name
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseEnterVaultName ?? 'กรุณากรอกชื่อ Vault'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.vaultNameMinLength ?? 'ชื่อ Vault ต้องมีอย่างน้อย 2 ตัวอักษร'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (name.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.vaultNameMaxLength ?? 'ชื่อ Vault ต้องไม่เกิน 50 ตัวอักษร'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate password
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseEnterPassword ?? 'กรุณากรอกรหัสผ่าน'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.passwordMinLength8 ?? 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password.length > 128) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.passwordMaxLength ?? 'รหัสผ่านต้องไม่เกิน 128 ตัวอักษร'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate password confirmation
    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseConfirmPassword ?? 'กรุณายืนยันรหัสผ่าน'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.passwordMismatch ?? 'รหัสผ่านไม่ตรงกัน'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final vaultService = Provider.of<VaultService>(context, listen: false);

      // Create vault with timeout
      final vault = await vaultService.createVault(
        name,
        password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(l10n?.vaultCreationTimeout ?? 'การสร้าง Vault ใช้เวลานานเกินไป กรุณาลองใหม่อีกครั้ง');
        },
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.vaultCreated ?? 'สร้าง Vault สำเร็จ'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to open vault screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OpenVaultScreen(vault: vault),
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Create vault error', tag: _tag, error: e, stackTrace: stackTrace);

      if (mounted) {
        setState(() => _isCreating = false);

        // Parse error message
        String errorMessage = l10n?.vaultCreationError ?? 'เกิดข้อผิดพลาดในการสร้าง Vault';
        final errorString = e.toString();

        if (errorString.contains('timeout') || errorString.contains('Timeout')) {
          errorMessage = l10n?.vaultCreationTimeout ?? 'การสร้าง Vault ใช้เวลานานเกินไป กรุณาลองใหม่อีกครั้ง';
        } else if (errorString.contains('directory') || errorString.contains('Directory')) {
          errorMessage = l10n?.directoryCreationError ?? 'ไม่สามารถสร้างโฟลเดอร์ได้ กรุณาตรวจสอบสิทธิ์การเข้าถึง';
        } else if (errorString.contains('database') || errorString.contains('Database') || errorString.contains('sqflite')) {
          errorMessage = l10n?.databaseError ?? 'เกิดข้อผิดพลาดในการบันทึกข้อมูล กรุณาลองใหม่อีกครั้ง';
        } else if (errorString.contains('network') || errorString.contains('Network')) {
          errorMessage = l10n?.networkError ?? 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
        } else if (errorString.contains('Exception: ')) {
          errorMessage = errorString.replaceAll('Exception: ', '');
        } else {
          errorMessage = errorString;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: l10n?.close ?? 'ปิด',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.createVault ?? 'สร้าง Vault'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
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
                          Icons.folder,
                          size: 80,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n?.vaultName ?? 'ชื่อ Vault',
                  hintText: l10n?.enterVaultName ?? 'เช่น ไฟล์ส่วนตัว, รูปภาพ',
                  prefixIcon: const Icon(Icons.folder),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n?.pleaseEnterVaultName ?? 'กรุณากรอกชื่อ Vault';
                  }
                  if (value.trim().length < 2) {
                    return l10n?.vaultNameMinLength ?? 'ชื่อ Vault ต้องมีอย่างน้อย 2 ตัวอักษร';
                  }
                  if (value.trim().length > 50) {
                    return l10n?.vaultNameMaxLength ?? 'ชื่อ Vault ต้องไม่เกิน 50 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n?.vaultPassword ?? 'รหัสผ่าน',
                  hintText: l10n?.passwordMinLengthHint ?? 'อย่างน้อย 8 ตัวอักษร',
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n?.pleaseEnterPassword ?? 'กรุณากรอกรหัสผ่าน';
                  }
                  if (value.length < 8) {
                    return l10n?.passwordMinLength8 ?? 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                  }
                  if (value.length > 128) {
                    return l10n?.passwordMaxLength ?? 'รหัสผ่านต้องไม่เกิน 128 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: l10n?.confirmPassword ?? 'ยืนยันรหัสผ่าน',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n?.pleaseConfirmPassword ?? 'กรุณายืนยันรหัสผ่าน';
                  }
                  if (value != _passwordController.text) {
                    return l10n?.passwordMismatch ?? 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isCreating ? null : _createVault,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n?.createVault ?? 'สร้าง Vault', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.vaultPasswordWarning ?? '⚠️ สำคัญ: จำรหัสผ่านให้ดี หากลืมรหัสผ่านจะไม่สามารถกู้คืนไฟล์ได้',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
