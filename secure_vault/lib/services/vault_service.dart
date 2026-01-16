import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../core/models/vault.dart';
import '../core/storage/database_helper.dart';
import '../core/encryption/key_manager.dart';
import '../core/encryption/crypto_service.dart';

/// Service for managing vaults
class VaultService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  /// Create a new vault
  Future<Vault> createVault(String name, String password) async {
    // Generate salt and master key
    final salt = CryptoService.generateSalt();
    final masterKey = KeyManager.generateMasterKey();

    // Encrypt master key
    final encryptedMasterKey = KeyManager.encryptMasterKey(masterKey, password, salt);

    // Create vault directory
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory(path.join(appDir.path, 'vaults', _uuid.v4()));
    await vaultDir.create(recursive: true);

    // Create vault structure
    final dDir = Directory(path.join(vaultDir.path, 'd'));
    await dDir.create(recursive: true);

    // Create vault model
    final vault = Vault(
      name: name,
      path: vaultDir.path,
      createdAt: DateTime.now(),
      salt: salt.toList(),
      encryptedMasterKey: encryptedMasterKey.toList(),
    );

    // Save to database
    final id = await _db.createVault(vault);
    return vault.copyWith(id: id);
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

      return masterKey;
    } catch (e) {
      return null;
    }
  }

  /// Get all vaults
  Future<List<Vault>> getAllVaults() async {
    return await _db.getAllVaults();
  }

  /// Get vault by ID
  Future<Vault?> getVault(int id) async {
    return await _db.getVault(id);
  }

  /// Delete vault
  Future<bool> deleteVault(int id) async {
    final vault = await _db.getVault(id);
    if (vault == null) return false;

    // Delete vault directory
    try {
      final vaultDir = Directory(vault.path);
      if (await vaultDir.exists()) {
        await vaultDir.delete(recursive: true);
      }
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
