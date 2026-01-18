import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/vault.dart';
import '../../../core/utils/logger.dart';
import '../../../services/vault_service.dart';
import '../../../services/biometric_service.dart';
import '../../../l10n/app_localizations.dart';
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

        final l10n = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n?.errorOccurred ?? 'An error occurred'}: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteVault(Vault vault) async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = S.of(dialogContext);
        return AlertDialog(
          title: Text(dialogL10n?.deleteVault ?? 'Delete Vault'),
          content: Text(
              '${dialogL10n?.permanentDeleteWarning ?? 'This action cannot be undone.'}\n\n"${vault.name}"'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogL10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(dialogL10n?.delete ?? 'Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final vaultService = Provider.of<VaultService>(context, listen: false);
      final success = await vaultService.deleteVault(vault.id!);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.vaultDeleted ?? 'Vault deleted successfully')),
        );
        _loadVaults();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appName ?? 'Secure Vault'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadVaults,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n?.settings ?? 'Settings',
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
        label: Text(l10n?.createVault ?? 'Create Vault'),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = S.of(context);
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
              l10n?.appName ?? 'Secure Vault',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.appTagline ?? 'Keep your files safe',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Features list
            _buildFeatureItem(Icons.shield, l10n?.encryptionAES ?? 'AES-256-GCM'),
            _buildFeatureItem(Icons.cloud_off, l10n?.storageNoServer ?? 'No data sent to server'),
            if (_biometricTypeName.isNotEmpty)
              _buildFeatureItem(Icons.fingerprint, l10n?.biometricSubtitle ?? 'Biometric unlock'),
            _buildFeatureItem(Icons.no_photography, l10n?.screenshotPrevention ?? 'Screenshot Prevention'),

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
              label: Text(l10n?.createFirstVault ?? 'Create your first vault'),
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
    final l10n = S.of(context);
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
                                  message: l10n?.biometricGeneric ?? 'Biometric',
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
                            '${l10n?.created ?? 'Created'}: ${_formatDate(vault.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (vault.lastAccessed != null)
                            Text(
                              '${l10n?.modified ?? 'Modified'}: ${_formatDate(vault.lastAccessed!)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (menuContext) {
                        final menuL10n = S.of(menuContext);
                        return [
                          PopupMenuItem(
                            value: 'open',
                            child: Row(
                              children: [
                                const Icon(Icons.lock_open),
                                const SizedBox(width: 8),
                                Text(menuL10n?.openVault ?? 'Open'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'decoy',
                            child: Row(
                              children: [
                                const Icon(Icons.security),
                                const SizedBox(width: 8),
                                Text(menuL10n?.decoyVault ?? 'Decoy Vault'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(menuL10n?.delete ?? 'Delete', style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ];
                      },
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
