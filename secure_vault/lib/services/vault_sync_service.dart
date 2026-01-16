import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    if (!_authService.isLoggedIn) {
      print('Not logged in, skipping backend sync');
      return;
    }

    try {
      print('Fetching vaults from backend...');
      final vaultsData = await _apiService.getVaults().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Backend API timeout');
          throw Exception('Backend API timeout');
        },
      );
      
      print('Received ${vaultsData.length} vaults from backend');
      
      // On web, use virtual path; on mobile/desktop, get app directory
      String basePath;
      if (kIsWeb) {
        // On web, use virtual path
        basePath = 'vaults';
        print('Web platform: Using virtual path for sync');
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
          print('Error getting app directory: $e');
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
            print('Creating local vault for backend vault: ${vaultBackend.name}');
            final localVault = vaultBackend.toLocalVault(vaultPath);
            
            // Save to local database
            await _db.createVault(localVault);
            print('Created local vault: ${vaultBackend.name}');
          } else {
            print('Vault already exists locally: ${vaultBackend.name}');
          }
        } catch (e) {
          print('Error processing vault from backend: $e');
          // Continue with next vault
        }
      }
      
      print('Backend sync completed successfully');
    } catch (e) {
      // Handle sync errors - don't throw, just log
      print('Sync error (non-critical): $e');
      // Don't rethrow - allow app to continue with local vaults
    }
  }

  /// Sync vault to backend
  Future<void> syncToBackend(Vault vault) async {
    if (!_authService.isLoggedIn) {
      print('Not logged in, skipping sync');
      return;
    }
    if (_authService.currentUser == null) {
      print('No current user, skipping sync');
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
          print('Vault sync timeout');
          throw Exception('Sync timeout');
        },
      );
      
      print('Vault synced successfully');
    } catch (e) {
      // Log error but don't throw - allow local creation to succeed
      print('Sync to backend error (non-blocking): $e');
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
