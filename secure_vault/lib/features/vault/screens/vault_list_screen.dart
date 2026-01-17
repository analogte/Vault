import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/vault.dart';
import '../../../core/utils/logger.dart';
import '../../../services/vault_service.dart';
import '../../../services/biometric_service.dart';
import '../../settings/screens/settings_screen.dart';
import 'create_vault_screen.dart';
import 'open_vault_screen.dart';
import 'decoy_settings_screen.dart';

class VaultListScreen extends StatefulWidget {
  const VaultListScreen({super.key});

  @override
  State<VaultListScreen> createState() => _VaultListScreenState();
}

class _VaultListScreenState extends State<VaultListScreen> {
  static const String _tag = 'VaultListScreen';
  List<Vault> _vaults = [];
  bool _isLoading = true;
  final BiometricService _biometricService = BiometricService();
  String _biometricTypeName = '';

  @override
  void initState() {
    super.initState();
    _loadVaults();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final types = await _biometricService.getAvailableBiometrics();
    setState(() {
      _biometricTypeName = _biometricService.getBiometricTypeName(types);
    });
  }

  Future<void> _loadVaults() async {
    setState(() => _isLoading = true);

    try {
      AppLogger.log('Loading vaults...', tag: _tag);
      final vaultService = Provider.of<VaultService>(context, listen: false);

      final vaults = await vaultService.getAllVaults().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning('Loading vaults timeout - returning empty list', tag: _tag);
          return <Vault>[];
        },
      );

      AppLogger.log('Loaded ${vaults.length} vaults', tag: _tag);

      if (mounted) {
        setState(() {
          _vaults = vaults;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading vaults', tag: _tag, error: e);
      if (mounted) {
        setState(() {
          _vaults = [];
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการโหลด Vault: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteVault(Vault vault) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบ Vault'),
        content: Text(
            'คุณต้องการลบ "${vault.name}" ใช่หรือไม่?\n\nไฟล์ทั้งหมดจะถูกลบและไม่สามารถกู้คืนได้'),
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

    if (confirmed == true && mounted) {
      final vaultService = Provider.of<VaultService>(context, listen: false);
      final success = await vaultService.deleteVault(vault.id!);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบ Vault สำเร็จ')),
        );
        _loadVaults();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Vault'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'รีเฟรช',
            onPressed: _loadVaults,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'ตั้งค่า',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vaults.isEmpty
              ? _buildEmptyState()
              : _buildVaultList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateVaultScreen(),
            ),
          );
          if (result == true) {
            _loadVaults();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('สร้าง Vault'),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                size: 64,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ยินดีต้อนรับสู่ Secure Vault',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'เก็บรูปภาพและไฟล์ของคุณอย่างปลอดภัย\nด้วยการเข้ารหัส AES-256',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Features list
            _buildFeatureItem(Icons.shield, 'เข้ารหัส AES-256-GCM'),
            _buildFeatureItem(Icons.cloud_off, 'เก็บในเครื่องเท่านั้น'),
            if (_biometricTypeName.isNotEmpty)
              _buildFeatureItem(Icons.fingerprint, 'รองรับ $_biometricTypeName'),
            _buildFeatureItem(Icons.no_photography, 'ป้องกัน Screenshot'),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateVaultScreen(),
                  ),
                );
                if (result == true) {
                  _loadVaults();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('สร้าง Vault แรกของคุณ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildVaultList() {
    return RefreshIndicator(
      onRefresh: _loadVaults,
      child: ListView.builder(
        itemCount: _vaults.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final vault = _vaults[index];
          return _buildVaultCard(vault, index);
        },
      ),
    );
  }

  Widget _buildVaultCard(Vault vault, int index) {
    return FutureBuilder<bool>(
      future: vault.id != null
          ? _biometricService.isVaultBiometricEnabled(vault.id!)
          : Future.value(false),
      builder: (context, snapshot) {
        final hasBiometric = snapshot.data ?? false;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenVaultScreen(vault: vault),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.folder,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vault.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (hasBiometric)
                                Tooltip(
                                  message: '$_biometricTypeName เปิดใช้งาน',
                                  child: Icon(
                                    Icons.fingerprint,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'สร้างเมื่อ: ${_formatDate(vault.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (vault.lastAccessed != null)
                            Text(
                              'เข้าใช้ล่าสุด: ${_formatDate(vault.lastAccessed!)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'open',
                          child: Row(
                            children: [
                              Icon(Icons.lock_open),
                              SizedBox(width: 8),
                              Text('เปิด'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'decoy',
                          child: Row(
                            children: [
                              Icon(Icons.security),
                              SizedBox(width: 8),
                              Text('Decoy Vault'),
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
                        if (value == 'open') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OpenVaultScreen(vault: vault),
                            ),
                          );
                        } else if (value == 'decoy') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DecoySettingsScreen(vault: vault),
                            ),
                          );
                        } else if (value == 'delete') {
                          _deleteVault(vault);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
