import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../core/models/vault.dart';
import '../core/storage/database_helper.dart';
import '../core/encryption/key_manager.dart';
import '../core/encryption/crypto_service.dart';
import 'vault_sync_service.dart';

// Conditional import for IO operations
import 'vault_service_io.dart' if (dart.library.html) 'vault_service_io_stub.dart';

/// Service for managing vaults
class VaultService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _uuid = const Uuid();
  VaultSyncService? _syncService;

  /// Set sync service
  void setSyncService(VaultSyncService syncService) {
    _syncService = syncService;
  }

  /// Create a new vault
  Future<Vault> createVault(String name, String password) async {
    try {
      print('Creating vault: $name');
      
      // Generate salt and master key
      final salt = CryptoService.generateSalt();
      final masterKey = KeyManager.generateMasterKey();
      print('Generated salt and master key');

      // Encrypt master key (this may take a few seconds due to PBKDF2)
      print('Starting master key encryption (PBKDF2 derivation)...');
      final encryptedMasterKey = KeyManager.encryptMasterKey(masterKey, password, salt);
      print('Encrypted master key completed');

      // Create vault directory
      // Use conditional import to handle web vs mobile/desktop
      final vaultId = _uuid.v4();
      print('Creating vault directory for: $vaultId');
      
      final vaultPath = await VaultServiceIO.createVaultDirectory(vaultId);
      print('Vault directory created: $vaultPath');

      // Create vault model
      final vault = Vault(
        name: name,
        path: vaultPath,
        createdAt: DateTime.now(),
        salt: salt.toList(),
        encryptedMasterKey: encryptedMasterKey.toList(),
      );
      print('Vault model created');

      // Save to database with timeout
      print('Saving vault to database...');
      final id = await _db.createVault(vault).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Database save timeout');
          throw Exception('การบันทึกข้อมูลใช้เวลานานเกินไป');
        },
      );
      final createdVault = vault.copyWith(id: id);
      print('Vault saved to database with ID: $id');

      // Sync to backend if available (non-blocking)
      if (_syncService != null) {
        print('Syncing vault to backend (background)...');
        // Don't wait for sync - do it in background
        _syncService!.syncToBackend(createdVault).catchError((e) {
          // Log error but don't block
          print('Background sync failed (non-critical): $e');
        });
      } else {
        print('No sync service available, skipping backend sync');
      }

      print('Vault creation completed successfully');
      return createdVault;
    } catch (e) {
      print('Error creating vault: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Open vault with password
  Future<Uint8List?> openVault(Vault vault, String password) async {
    try {
      // Verify password and get master key
      final isValid = KeyManager.verifyPassword(
        password,
        Uint8List.fromList(vault.encryptedMasterKey),
        Uint8List.fromList(vault.salt),
      );

      if (!isValid) {
        return null;
      }

      // Decrypt master key
      final masterKey = KeyManager.decryptMasterKey(
        Uint8List.fromList(vault.encryptedMasterKey),
        password,
        Uint8List.fromList(vault.salt),
      );

      // Update last accessed
      final updatedVault = vault.copyWith(lastAccessed: DateTime.now());
      await _db.updateVault(updatedVault);

      // Update last accessed on backend if available
      if (_syncService != null && vault.id != null) {
        // Try to get vault ID from backend (would need to store mapping)
        // For now, skip backend update
      }

      return masterKey;
    } catch (e) {
      return null;
    }
  }

  /// Get all vaults
  Future<List<Vault>> getAllVaults() async {
    print('Getting all vaults...');
    
    // Sync from backend first if available (with timeout)
    if (_syncService != null) {
      try {
        print('Attempting to sync from backend...');
        await _syncService!.syncFromBackend().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('Backend sync timeout - continuing with local vaults');
            return;
          },
        );
        print('Backend sync completed');
      } catch (e) {
        // Continue even if sync fails
        print('Sync failed (non-critical): $e');
      }
    } else {
      print('No sync service available, loading local vaults only');
    }
    
    // Get local vaults
    print('Loading local vaults from database...');
    final vaults = await _db.getAllVaults();
    print('Found ${vaults.length} local vaults');
    
    return vaults;
  }

  /// Get vault by ID
  Future<Vault?> getVault(int id) async {
    return await _db.getVault(id);
  }

  /// Delete vault
  Future<bool> deleteVault(int id) async {
    final vault = await _db.getVault(id);
    if (vault == null) return false;

    // Delete from backend if available
    if (_syncService != null) {
      // Try to delete from backend (would need vault ID mapping)
      // For now, skip backend delete
    }

    // Delete vault directory
    try {
      // Delete vault directory (works on all platforms via conditional import)
      await VaultServiceIO.deleteVaultDirectory(vault.path);
    } catch (e) {
      // Continue even if directory deletion fails
    }

    // Delete from database
    await _db.deleteVault(id);
    return true;
  }

  /// Change vault password
  Future<bool> changePassword(Vault vault, String oldPassword, String newPassword) async {
    // Verify old password
    final masterKey = await openVault(vault, oldPassword);
    if (masterKey == null) return false;

    // Encrypt master key with new password
    final newEncryptedMasterKey = KeyManager.encryptMasterKey(
      masterKey,
      newPassword,
      Uint8List.fromList(vault.salt),
    );

    // Update vault
    final updatedVault = vault.copyWith(
      encryptedMasterKey: newEncryptedMasterKey.toList(),
    );
    await _db.updateVault(updatedVault);

    return true;
  }
}
