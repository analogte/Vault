import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../core/models/vault.dart';
import '../core/storage/database_helper.dart';
import '../core/encryption/key_manager.dart';
import '../core/utils/logger.dart';
import 'vault_sync_service.dart';

// Conditional import for IO operations
import 'vault_service_io.dart' if (dart.library.html) 'vault_service_io_stub.dart';

/// Service for managing vaults
class VaultService {
  static const String _tag = 'VaultService';
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
      AppLogger.log('Creating vault: $name', tag: _tag);

      // Generate salt and master key using secure crypto
      final salt = KeyManager.generateSalt();
      final masterKey = KeyManager.generateMasterKey();
      AppLogger.log('Generated salt and master key', tag: _tag);

      // Encrypt master key using Web Crypto API (fast even with 100k iterations)
      AppLogger.log('Starting master key encryption (PBKDF2 derivation)...', tag: _tag);
      final encryptedMasterKey = await KeyManager.encryptMasterKey(masterKey, password, salt);
      AppLogger.log('Encrypted master key completed', tag: _tag);

      // Create vault directory
      // Use conditional import to handle web vs mobile/desktop
      final vaultId = _uuid.v4();
      AppLogger.log('Creating vault directory for: $vaultId', tag: _tag);

      final vaultPath = await VaultServiceIO.createVaultDirectory(vaultId);
      AppLogger.log('Vault directory created: $vaultPath', tag: _tag);

      // Create vault model
      final vault = Vault(
        name: name,
        path: vaultPath,
        createdAt: DateTime.now(),
        salt: salt.toList(),
        encryptedMasterKey: encryptedMasterKey.toList(),
      );
      AppLogger.log('Vault model created', tag: _tag);

      // Save to database with timeout
      AppLogger.log('Saving vault to database...', tag: _tag);
      final id = await _db.createVault(vault).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.error('Database save timeout', tag: _tag);
          throw Exception('การบันทึกข้อมูลใช้เวลานานเกินไป');
        },
      );
      final createdVault = vault.copyWith(id: id);
      AppLogger.log('Vault saved to database with ID: $id', tag: _tag);

      // Sync to backend if available (non-blocking)
      if (_syncService != null) {
        AppLogger.log('Syncing vault to backend (background)...', tag: _tag);
        // Don't wait for sync - do it in background
        _syncService!.syncToBackend(createdVault).catchError((e) {
          // Log error but don't block
          AppLogger.error('Background sync failed (non-critical)', tag: _tag, error: e);
        });
      } else {
        AppLogger.log('No sync service available, skipping backend sync', tag: _tag);
      }

      AppLogger.log('Vault creation completed successfully', tag: _tag);
      return createdVault;
    } catch (e) {
      AppLogger.error('Error creating vault', tag: _tag, error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// Open vault with password
  Future<Uint8List?> openVault(Vault vault, String password) async {
    try {
      // Verify password and get master key using vault's KDF version
      final isValid = await KeyManager.verifyPassword(
        password,
        Uint8List.fromList(vault.encryptedMasterKey),
        Uint8List.fromList(vault.salt),
        kdfVersion: vault.kdfVersion,
      );

      if (!isValid) {
        return null;
      }

      // Decrypt master key using vault's KDF version
      final masterKey = await KeyManager.decryptMasterKey(
        Uint8List.fromList(vault.encryptedMasterKey),
        password,
        Uint8List.fromList(vault.salt),
        kdfVersion: vault.kdfVersion,
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

  /// Migrate vault from PBKDF2 to Argon2id
  Future<bool> migrateVaultToArgon2id(Vault vault, String password) async {
    try {
      AppLogger.log('Starting Argon2id migration for vault: ${vault.name}', tag: _tag);

      // Perform migration
      final migrationResult = await KeyManager.migrateToArgon2id(
        password,
        Uint8List.fromList(vault.encryptedMasterKey),
        Uint8List.fromList(vault.salt),
      );

      // Update vault with new encrypted key and kdfVersion
      final updatedVault = vault.copyWith(
        encryptedMasterKey: migrationResult.encryptedMasterKey.toList(),
        salt: migrationResult.salt.toList(),
        kdfVersion: migrationResult.kdfVersion,
      );

      await _db.updateVault(updatedVault);
      AppLogger.log('Argon2id migration completed for vault: ${vault.name}', tag: _tag);

      return true;
    } catch (e) {
      AppLogger.error('Argon2id migration failed', tag: _tag, error: e);
      return false;
    }
  }

  /// Get all vaults
  Future<List<Vault>> getAllVaults() async {
    AppLogger.log('Getting all vaults...', tag: _tag);

    // Sync from backend first if available (with timeout)
    if (_syncService != null) {
      try {
        AppLogger.log('Attempting to sync from backend...', tag: _tag);
        await _syncService!.syncFromBackend().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            AppLogger.log('Backend sync timeout - continuing with local vaults', tag: _tag);
            return;
          },
        );
        AppLogger.log('Backend sync completed', tag: _tag);
      } catch (e) {
        // Continue even if sync fails
        AppLogger.error('Sync failed (non-critical)', tag: _tag, error: e);
      }
    } else {
      AppLogger.log('No sync service available, loading local vaults only', tag: _tag);
    }

    // Get local vaults
    AppLogger.log('Loading local vaults from database...', tag: _tag);
    final vaults = await _db.getAllVaults();
    AppLogger.log('Found ${vaults.length} local vaults', tag: _tag);

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
    final newEncryptedMasterKey = await KeyManager.encryptMasterKey(
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
