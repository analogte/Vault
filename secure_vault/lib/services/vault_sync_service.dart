import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../core/models/vault.dart';
import '../core/models/vault_backend.dart';
import '../core/storage/database_helper.dart';
import '../core/utils/logger.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Service for syncing vaults with backend
class VaultSyncService {
  static const String _tag = 'VaultSyncService';

  final ApiService _apiService;
  final AuthService _authService;
  final DatabaseHelper _db = DatabaseHelper.instance;

  VaultSyncService(this._apiService, this._authService);

  /// Sync vaults from backend
  Future<void> syncFromBackend() async {
    if (!_authService.isLoggedIn) {
      AppLogger.log('Not logged in, skipping backend sync', tag: _tag);
      return;
    }

    try {
      AppLogger.log('Fetching vaults from backend...', tag: _tag);
      final vaultsData = await _apiService.getVaults().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          AppLogger.log('Backend API timeout', tag: _tag);
          throw Exception('Backend API timeout');
        },
      );

      AppLogger.log('Received ${vaultsData.length} vaults from backend', tag: _tag);

      // On web, use virtual path; on mobile/desktop, get app directory
      String basePath;
      if (kIsWeb) {
        // On web, use virtual path
        basePath = 'vaults';
        AppLogger.log('Web platform: Using virtual path for sync', tag: _tag);
      } else {
        // Try to get app directory with timeout
        dynamic appDir;
        try {
          appDir = await getApplicationDocumentsDirectory().timeout(
            const Duration(seconds: 2),
          );
          // ignore: avoid_dynamic_calls
          basePath = appDir.path;
        } catch (e) {
          AppLogger.error('Error getting app directory', tag: _tag, error: e);
          // Continue without syncing - local vaults will still work
          return;
        }
      }

      for (final vaultData in vaultsData) {
        try {
          final vaultBackend = VaultBackend.fromJson(vaultData);

          // Use virtual path for web, actual path for mobile/desktop
          final vaultPath = kIsWeb
              ? 'vaults/${vaultBackend.id}'
              : path.join(basePath, 'vaults', vaultBackend.id);

          // Check if vault exists locally
          final existingVault = await _db.getVaultByPath(vaultPath);

          if (existingVault == null) {
            AppLogger.log('Creating local vault for backend vault: ${vaultBackend.name}', tag: _tag);
            final localVault = vaultBackend.toLocalVault(vaultPath);

            // Save to local database
            await _db.createVault(localVault);
            AppLogger.log('Created local vault: ${vaultBackend.name}', tag: _tag);
          } else {
            AppLogger.log('Vault already exists locally: ${vaultBackend.name}', tag: _tag);
          }
        } catch (e) {
          AppLogger.error('Error processing vault from backend', tag: _tag, error: e);
          // Continue with next vault
        }
      }

      AppLogger.log('Backend sync completed successfully', tag: _tag);
    } catch (e) {
      // Handle sync errors - don't throw, just log
      AppLogger.error('Sync error (non-critical)', tag: _tag, error: e);
      // Don't rethrow - allow app to continue with local vaults
    }
  }

  /// Sync vault to backend
  Future<void> syncToBackend(Vault vault) async {
    if (!_authService.isLoggedIn) {
      AppLogger.log('Not logged in, skipping sync', tag: _tag);
      return;
    }
    if (_authService.currentUser == null) {
      AppLogger.log('No current user, skipping sync', tag: _tag);
      return;
    }

    try {
      final vaultBackend = VaultBackend.fromLocalVault(
        vault,
        _authService.currentUser!.id,
      );

      // Create vault on backend with timeout
      await _apiService.createVault(
        name: vaultBackend.name,
        encryptedMasterKey: vaultBackend.encryptedMasterKey,
        salt: vaultBackend.salt,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.log('Vault sync timeout', tag: _tag);
          throw Exception('Sync timeout');
        },
      );

      AppLogger.log('Vault synced successfully', tag: _tag);
    } catch (e) {
      // Log error but don't throw - allow local creation to succeed
      AppLogger.error('Sync to backend error (non-blocking)', tag: _tag, error: e);
      // Don't rethrow - allow vault creation to succeed locally
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
      AppLogger.error('Update last accessed error', tag: _tag, error: e);
    }
  }

  /// Delete vault from backend
  Future<void> deleteFromBackend(String vaultId) async {
    if (!_authService.isLoggedIn) return;

    try {
      await _apiService.deleteVault(vaultId);
    } catch (e) {
      // Handle errors silently
      AppLogger.error('Delete from backend error', tag: _tag, error: e);
    }
  }
}
