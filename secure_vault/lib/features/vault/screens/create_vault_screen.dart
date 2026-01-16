import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/vault_service.dart';
import 'open_vault_screen.dart';

class CreateVaultScreen extends StatefulWidget {
  const CreateVaultScreen({super.key});

  @override
  State<CreateVaultScreen> createState() => _CreateVaultScreenState();
}

class _CreateVaultScreenState extends State<CreateVaultScreen> {
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
        const SnackBar(
          content: Text('❌ กรุณากรอกชื่อ Vault'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ ชื่อ Vault ต้องมีอย่างน้อย 2 ตัวอักษร'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (name.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ ชื่อ Vault ต้องไม่เกิน 50 ตัวอักษร'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate password
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ กรุณากรอกรหัสผ่าน'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password.length > 128) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ รหัสผ่านต้องไม่เกิน 128 ตัวอักษร'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate password confirmation
    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ กรุณายืนยันรหัสผ่าน'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ รหัสผ่านไม่ตรงกัน กรุณากรอกใหม่อีกครั้ง'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
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
          throw Exception('การสร้าง Vault ใช้เวลานานเกินไป กรุณาลองใหม่อีกครั้ง');
        },
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ สร้าง Vault สำเร็จ'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
      print('Create vault error: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() => _isCreating = false);
        
        // Parse error message
        String errorMessage = 'เกิดข้อผิดพลาดในการสร้าง Vault';
        final errorString = e.toString();
        
        if (errorString.contains('timeout') || errorString.contains('Timeout')) {
          errorMessage = '⏱️ การสร้าง Vault ใช้เวลานานเกินไป กรุณาลองใหม่อีกครั้ง';
        } else if (errorString.contains('directory') || errorString.contains('Directory')) {
          errorMessage = '❌ ไม่สามารถสร้างโฟลเดอร์ได้ กรุณาตรวจสอบสิทธิ์การเข้าถึง';
        } else if (errorString.contains('database') || errorString.contains('Database') || errorString.contains('sqflite')) {
          errorMessage = '❌ เกิดข้อผิดพลาดในการบันทึกข้อมูล: $errorString\nกรุณาลองใหม่อีกครั้ง หรือ refresh หน้าเว็บ';
        } else if (errorString.contains('network') || errorString.contains('Network')) {
          errorMessage = '❌ ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
        } else if (errorString.contains('Exception: ')) {
          errorMessage = errorString.replaceAll('Exception: ', '');
        } else {
          errorMessage = '❌ $errorString';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'ปิด',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้าง Vault ใหม่'),
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
                decoration: const InputDecoration(
                  labelText: 'ชื่อ Vault',
                  hintText: 'เช่น ไฟล์ส่วนตัว, รูปภาพ',
                  prefixIcon: Icon(Icons.folder),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อ Vault';
                  }
                  if (value.trim().length < 2) {
                    return 'ชื่อ Vault ต้องมีอย่างน้อย 2 ตัวอักษร';
                  }
                  if (value.trim().length > 50) {
                    return 'ชื่อ Vault ต้องไม่เกิน 50 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  hintText: 'อย่างน้อย 8 ตัวอักษร',
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
                    return 'กรุณากรอกรหัสผ่าน';
                  }
                  if (value.length < 8) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
                  }
                  if (value.length > 128) {
                    return 'รหัสผ่านต้องไม่เกิน 128 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'ยืนยันรหัสผ่าน',
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
                    return 'กรุณายืนยันรหัสผ่าน';
                  }
                  if (value != _passwordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
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
                    : const Text('สร้าง Vault', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              const Text(
                '⚠️ สำคัญ: จำรหัสผ่านให้ดี หากลืมรหัสผ่านจะไม่สามารถกู้คืนไฟล์ได้',
                style: TextStyle(
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
