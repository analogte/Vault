import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/utils/logger.dart';
import '../core/encryption/key_manager.dart';
import '../core/models/vault.dart';
import '../core/storage/database_helper.dart';

/// Service for managing decoy vaults
/// Decoy vaults show fake data when a special password is entered
/// This protects against forced unlocking situations
class DecoyVaultService {
  static const String _tag = 'DecoyVaultService';
  static final DecoyVaultService _instance = DecoyVaultService._internal();
  factory DecoyVaultService() => _instance;
  DecoyVaultService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _decoyPasswordHashPrefix = 'decoy_password_hash_';
  static const String _decoyEnabledPrefix = 'decoy_enabled_';
  static const String _panicModeKey = 'panic_mode_enabled';

  /// Check if decoy password is set for a vault
  Future<bool> hasDecoyPassword(int vaultId) async {
    final key = '$_decoyPasswordHashPrefix$vaultId';
    return await _storage.containsKey(key: key);
  }

  /// Set decoy password for a vault
  /// Returns the created decoy vault or null if failed
  Future<Vault?> setDecoyPassword(
    int realVaultId,
    String decoyPassword,
    String realVaultName,
  ) async {
    try {
      AppLogger.log('Setting decoy password for vault: $realVaultId', tag: _tag);

      // Hash the decoy password
      final passwordHash = KeyManager.hashPassword(decoyPassword);

      // Store decoy password hash
      final key = '$_decoyPasswordHashPrefix$realVaultId';
      await _storage.write(key: key, value: passwordHash);

      // Enable decoy for this vault
      await _storage.write(
        key: '$_decoyEnabledPrefix$realVaultId',
        value: 'true',
      );

      // Create decoy vault in database
      final decoyVault = await _createDecoyVault(realVaultId, realVaultName, decoyPassword);

      AppLogger.log('Decoy password set successfully', tag: _tag);
      return decoyVault;
    } catch (e) {
      AppLogger.error('Failed to set decoy password', tag: _tag, error: e);
      return null;
    }
  }

  /// Create a decoy vault in the database
  Future<Vault?> _createDecoyVault(
    int realVaultId,
    String realVaultName,
    String decoyPassword,
  ) async {
    try {
      // Generate new keys for decoy vault
      final salt = KeyManager.generateSalt();
      final masterKey = KeyManager.generateMasterKey();
      final encryptedMasterKey = await KeyManager.encryptMasterKey(
        masterKey,
        decoyPassword,
        salt,
        kdfVersion: KeyManager.kdfArgon2id,
      );

      // Create decoy vault
      final decoyVault = Vault(
        name: '$realVaultName (Decoy)',
        path: 'decoy_$realVaultId',
        createdAt: DateTime.now(),
        salt: salt.toList(),
        encryptedMasterKey: encryptedMasterKey.toList(),
        kdfVersion: KeyManager.kdfArgon2id,
        isDecoy: true,
      );

      // Save to database
      final id = await DatabaseHelper.instance.createVault(decoyVault);
      return decoyVault.copyWith(id: id);
    } catch (e) {
      AppLogger.error('Failed to create decoy vault', tag: _tag, error: e);
      return null;
    }
  }

  /// Remove decoy password for a vault
  Future<bool> removeDecoyPassword(int vaultId) async {
    try {
      await _storage.delete(key: '$_decoyPasswordHashPrefix$vaultId');
      await _storage.delete(key: '$_decoyEnabledPrefix$vaultId');

      // Delete decoy vault from database
      final decoyVault = await _findDecoyVault(vaultId);
      if (decoyVault != null && decoyVault.id != null) {
        await DatabaseHelper.instance.deleteVault(decoyVault.id!);
      }

      AppLogger.log('Decoy password removed for vault: $vaultId', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Failed to remove decoy password', tag: _tag, error: e);
      return false;
    }
  }

  /// Find decoy vault for a real vault
  Future<Vault?> _findDecoyVault(int realVaultId) async {
    final vaults = await DatabaseHelper.instance.getAllVaults();
    return vaults.where((v) => v.path == 'decoy_$realVaultId' && v.isDecoy).firstOrNull;
  }

  /// Check if entered password is the decoy password
  Future<bool> isDecoyPassword(int vaultId, String password) async {
    try {
      final key = '$_decoyPasswordHashPrefix$vaultId';
      final storedHash = await _storage.read(key: key);

      if (storedHash == null) return false;

      final enteredHash = KeyManager.hashPassword(password);
      return storedHash == enteredHash;
    } catch (e) {
      return false;
    }
  }

  /// Check if decoy feature is enabled for a vault
  Future<bool> isDecoyEnabled(int vaultId) async {
    final value = await _storage.read(key: '$_decoyEnabledPrefix$vaultId');
    return value == 'true';
  }

  /// Enable/disable decoy for a vault
  Future<void> setDecoyEnabled(int vaultId, bool enabled) async {
    await _storage.write(
      key: '$_decoyEnabledPrefix$vaultId',
      value: enabled.toString(),
    );
  }

  /// Get decoy vault for a real vault
  /// Returns null if no decoy vault exists
  Future<Vault?> getDecoyVault(int realVaultId) async {
    return _findDecoyVault(realVaultId);
  }

  /// Check if a vault is a decoy vault
  bool isDecoyVault(Vault vault) {
    return vault.isDecoy;
  }

  /// Get all decoy vaults
  Future<List<Vault>> getAllDecoyVaults() async {
    final vaults = await DatabaseHelper.instance.getAllVaults();
    return vaults.where((v) => v.isDecoy).toList();
  }

  /// Get all real vaults (non-decoy)
  Future<List<Vault>> getAllRealVaults() async {
    final vaults = await DatabaseHelper.instance.getAllVaults();
    return vaults.where((v) => !v.isDecoy).toList();
  }

  // === Panic Mode Feature ===
  // Panic mode allows quick vault lockdown in emergency situations

  /// Enable panic mode
  /// This can be triggered by a specific gesture or sequence
  Future<void> enablePanicMode() async {
    await _storage.write(key: _panicModeKey, value: 'true');
    AppLogger.warning('PANIC MODE ENABLED', tag: _tag);
  }

  /// Disable panic mode
  Future<void> disablePanicMode() async {
    await _storage.delete(key: _panicModeKey);
    AppLogger.log('Panic mode disabled', tag: _tag);
  }

  /// Check if panic mode is enabled
  Future<bool> isPanicModeEnabled() async {
    final value = await _storage.read(key: _panicModeKey);
    return value == 'true';
  }

  /// Execute panic mode actions
  /// This could:
  /// - Show only decoy vaults
  /// - Hide real vaults
  /// - Clear session data
  Future<void> executePanicMode() async {
    try {
      AppLogger.warning('Executing panic mode...', tag: _tag);

      // In panic mode, the app will:
      // 1. Only show decoy vaults to the user
      // 2. Hide all real vaults
      // 3. Clear any cached decryption keys from memory

      await enablePanicMode();

      // Additional actions can be added here:
      // - Clear clipboard
      // - Lock all open vaults
      // - Reset auto-lock timer

    } catch (e) {
      AppLogger.error('Panic mode execution failed', tag: _tag, error: e);
    }
  }

  /// Check if should show vault in current mode
  /// In panic mode, only decoy vaults are shown
  Future<bool> shouldShowVault(Vault vault) async {
    final isPanic = await isPanicModeEnabled();
    if (isPanic) {
      // In panic mode, only show decoy vaults
      return vault.isDecoy;
    }
    // Normal mode - show real vaults, hide decoys
    return !vault.isDecoy;
  }

  /// Filter vaults based on current mode
  Future<List<Vault>> filterVaultsForDisplay(List<Vault> vaults) async {
    final isPanic = await isPanicModeEnabled();
    if (isPanic) {
      // Panic mode - show only decoys
      return vaults.where((v) => v.isDecoy).toList();
    }
    // Normal mode - show only real vaults
    return vaults.where((v) => !v.isDecoy).toList();
  }
}

/// Extension on nullable Iterable for firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
