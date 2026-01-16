import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/vault.dart';
import '../../../services/vault_service.dart';
import '../../file_manager/screens/file_manager_screen.dart';

class OpenVaultScreen extends StatefulWidget {
  final Vault vault;

  const OpenVaultScreen({super.key, required this.vault});

  @override
  State<OpenVaultScreen> createState() => _OpenVaultScreenState();
}

class _OpenVaultScreenState extends State<OpenVaultScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isOpening = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openVault() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'กรุณากรอกรหัสผ่าน');
      return;
    }

    setState(() {
      _isOpening = true;
      _errorMessage = null;
    });

    try {
      final vaultService = Provider.of<VaultService>(context, listen: false);
      final masterKey = await vaultService.openVault(
        widget.vault,
        _passwordController.text,
      );

      if (masterKey == null) {
        setState(() {
          _errorMessage = 'รหัสผ่านไม่ถูกต้อง';
          _isOpening = false;
        });
        return;
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
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
        _isOpening = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vault.name),
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
              'กรุณากรอกรหัสผ่านเพื่อเปิด Vault',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน',
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
                  : const Text('เปิด Vault', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
