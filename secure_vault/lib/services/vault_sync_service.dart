import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../core/models/vault.dart';
import '../core/models/vault_backend.dart';
import '../core/storage/database_helper.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Service for syncing vaults with backend
class VaultSyncService {
  final ApiService _apiService;
  final AuthService _authService;
  final DatabaseHelper _db = DatabaseHelper.instance;

  VaultSyncService(this._apiService, this._authService);

  /// Sync vaults from backend
  Future<void> syncFromBackend() async {
    if (!_authService.isLoggedIn) return;

    try {
      final vaultsData = await _apiService.getVaults();
      final appDir = await getApplicationDocumentsDirectory();

      for (final vaultData in vaultsData) {
        final vaultBackend = VaultBackend.fromJson(vaultData);
        
        // Check if vault exists locally
        final existingVault = await _db.getVaultByPath(
          path.join(appDir.path, 'vaults', vaultBackend.id),
        );

        if (existingVault == null) {
          // Create local vault directory
          final vaultDir = path.join(appDir.path, 'vaults', vaultBackend.id);
          final localVault = vaultBackend.toLocalVault(vaultDir);
          
          // Save to local database
          await _db.createVault(localVault);
        }
      }
    } catch (e) {
      // Handle sync errors silently or log them
      print('Sync error: $e');
    }
  }

  /// Sync vault to backend
  Future<void> syncToBackend(Vault vault) async {
    if (!_authService.isLoggedIn) return;
    if (_authService.currentUser == null) return;

    try {
      final vaultBackend = VaultBackend.fromLocalVault(
        vault,
        _authService.currentUser!.id,
      );

      // Create vault on backend
      await _apiService.createVault(
        name: vaultBackend.name,
        encryptedMasterKey: vaultBackend.encryptedMasterKey,
        salt: vaultBackend.salt,
      );
    } catch (e) {
      // Handle sync errors
      print('Sync to backend error: $e');
      rethrow;
    }
  }

  /// Update vault last accessed on backend
  Future<void> updateLastAccessed(String vaultId) async {
    if (!_authService.isLoggedIn) return;

    try {
      await _apiService.updateVault(
        vaultId,
        lastAccessed: DateTime.now(),
      );
    } catch (e) {
      // Handle errors silently
      print('Update last accessed error: $e');
    }
  }

  /// Delete vault from backend
  Future<void> deleteFromBackend(String vaultId) async {
    if (!_authService.isLoggedIn) return;

    try {
      await _apiService.deleteVault(vaultId);
    } catch (e) {
      // Handle errors silently
      print('Delete from backend error: $e');
    }
  }
}
