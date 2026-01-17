import 'package:flutter/material.dart';
import '../../../services/decoy_vault_service.dart';
import '../../../core/models/vault.dart';
import '../../../widgets/secure_text_field.dart';

/// Screen for managing decoy vault settings
/// Allows users to set up a decoy password that shows fake vault
class DecoySettingsScreen extends StatefulWidget {
  final Vault vault;

  const DecoySettingsScreen({
    super.key,
    required this.vault,
  });

  @override
  State<DecoySettingsScreen> createState() => _DecoySettingsScreenState();
}

class _DecoySettingsScreenState extends State<DecoySettingsScreen> {
  final _decoyService = DecoyVaultService();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _hasDecoyPassword = false;
  bool _decoyEnabled = false;
  Vault? _decoyVault;

  @override
  void initState() {
    super.initState();
    _loadDecoyStatus();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadDecoyStatus() async {
    if (widget.vault.id == null) return;

    setState(() => _isLoading = true);

    try {
      final hasDecoy = await _decoyService.hasDecoyPassword(widget.vault.id!);
      final decoyEnabled = await _decoyService.isDecoyEnabled(widget.vault.id!);
      final decoyVault = await _decoyService.getDecoyVault(widget.vault.id!);

      setState(() {
        _hasDecoyPassword = hasDecoy;
        _decoyEnabled = decoyEnabled;
        _decoyVault = decoyVault;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupDecoyPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.vault.id == null) return;

    setState(() => _isLoading = true);

    try {
      final decoyVault = await _decoyService.setDecoyPassword(
        widget.vault.id!,
        _passwordController.text,
        widget.vault.name,
      );

      if (decoyVault != null) {
        setState(() {
          _hasDecoyPassword = true;
          _decoyEnabled = true;
          _decoyVault = decoyVault;
        });

        _passwordController.clear();
        _confirmPasswordController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ตั้งค่า Decoy Vault สำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to create decoy vault');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeDecoyPassword() async {
    if (widget.vault.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text(
          'คุณต้องการลบ Decoy Vault หรือไม่?\n\n'
          'ข้อมูลใน Decoy Vault จะถูกลบทั้งหมด',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _decoyService.removeDecoyPassword(widget.vault.id!);

      setState(() {
        _hasDecoyPassword = false;
        _decoyEnabled = false;
        _decoyVault = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบ Decoy Vault สำเร็จ'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decoy Vault'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  _buildInfoCard(),
                  const SizedBox(height: 24),

                  // Current Status
                  _buildStatusCard(),
                  const SizedBox(height: 24),

                  // Setup or Remove
                  if (_hasDecoyPassword)
                    _buildManageSection()
                  else
                    _buildSetupSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Decoy Vault คืออะไร?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Decoy Vault เป็นฟีเจอร์ความปลอดภัยที่ช่วยปกป้องข้อมูลของคุณ '
              'ในกรณีที่ถูกบังคับให้เปิด Vault\n\n'
              '• ตั้งรหัสผ่านปลอม (Decoy Password)\n'
              '• เมื่อใส่รหัสปลอม จะแสดง Vault ปลอมที่มีข้อมูลไม่สำคัญ\n'
              '• รหัสผ่านจริงยังคงเปิด Vault จริงได้ตามปกติ',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สถานะปัจจุบัน',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _hasDecoyPassword
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: _hasDecoyPassword ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _hasDecoyPassword
                      ? 'Decoy Vault เปิดใช้งานแล้ว'
                      : 'ยังไม่ได้ตั้งค่า Decoy Vault',
                  style: TextStyle(
                    color: _hasDecoyPassword ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            if (_decoyVault != null) ...[
              const SizedBox(height: 8),
              Text(
                'Decoy Vault: ${_decoyVault!.name}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSetupSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ตั้งค่า Decoy Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'รหัสผ่านนี้จะใช้เปิด Vault ปลอม',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              SecurePasswordField(
                controller: _passwordController,
                labelText: 'Decoy Password',
                hintText: 'ใส่รหัสผ่านปลอม',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่รหัสผ่าน';
                  }
                  if (value.length < 4) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SecurePasswordField(
                controller: _confirmPasswordController,
                labelText: 'ยืนยัน Decoy Password',
                hintText: 'ใส่รหัสผ่านปลอมอีกครั้ง',
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              PasswordStrengthIndicator(
                password: _passwordController.text,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _setupDecoyPassword,
                  icon: const Icon(Icons.security),
                  label: const Text('ตั้งค่า Decoy Vault'),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber,
                        color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'อย่าใช้รหัสผ่านเดียวกับ Vault จริง!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageSection() {
    return Column(
      children: [
        // Toggle Enable/Disable
        Card(
          child: SwitchListTile(
            title: const Text('เปิดใช้งาน Decoy Vault'),
            subtitle: Text(
              _decoyEnabled
                  ? 'Decoy password จะใช้งานได้'
                  : 'Decoy password จะไม่ทำงาน',
            ),
            value: _decoyEnabled,
            onChanged: (value) async {
              if (widget.vault.id != null) {
                await _decoyService.setDecoyEnabled(widget.vault.id!, value);
                setState(() => _decoyEnabled = value);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        // Change Decoy Password
        Card(
          child: ListTile(
            leading: const Icon(Icons.password),
            title: const Text('เปลี่ยน Decoy Password'),
            subtitle: const Text('ตั้งรหัสผ่านปลอมใหม่'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(),
          ),
        ),
        const SizedBox(height: 16),

        // Remove Decoy
        Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
            title: Text(
              'ลบ Decoy Vault',
              style: TextStyle(color: Colors.red.shade700),
            ),
            subtitle: const Text('ลบรหัสผ่านปลอมและ Vault ปลอม'),
            trailing: Icon(Icons.chevron_right, color: Colors.red.shade700),
            onTap: _removeDecoyPassword,
          ),
        ),
        const SizedBox(height: 24),

        // How to use
        _buildHowToUseCard(),
      ],
    );
  }

  Widget _buildHowToUseCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'วิธีใช้งาน',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStep('1', 'เมื่อเปิด Vault ใส่รหัสผ่านปลอมแทนรหัสจริง'),
            const SizedBox(height: 8),
            _buildStep('2', 'ระบบจะเปิด Decoy Vault ที่มีข้อมูลปลอม'),
            const SizedBox(height: 8),
            _buildStep('3', 'ใช้รหัสผ่านจริงเพื่อเปิด Vault จริง'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เปลี่ยน Decoy Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SecurePasswordField(
                controller: newPasswordController,
                labelText: 'รหัสผ่านใหม่',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่รหัสผ่าน';
                  }
                  if (value.length < 4) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SecurePasswordField(
                controller: confirmController,
                labelText: 'ยืนยันรหัสผ่าน',
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              newPasswordController.dispose();
              confirmController.dispose();
              Navigator.pop(context);
            },
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);

                // Remove old and set new
                if (widget.vault.id != null) {
                  await _decoyService.removeDecoyPassword(widget.vault.id!);
                  await _decoyService.setDecoyPassword(
                    widget.vault.id!,
                    newPasswordController.text,
                    widget.vault.name,
                  );
                  await _loadDecoyStatus();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('เปลี่ยนรหัสผ่านสำเร็จ'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }

                newPasswordController.dispose();
                confirmController.dispose();
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
}
