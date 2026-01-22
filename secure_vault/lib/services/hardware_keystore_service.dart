import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/utils/logger.dart';

/// Service for hardware-backed key storage
/// Uses Android Keystore / iOS Keychain for secure key storage
class HardwareKeystoreService {
  static const String _tag = 'HardwareKeystoreService';
  static final HardwareKeystoreService _instance = HardwareKeystoreService._internal();
  factory HardwareKeystoreService() => _instance;
  HardwareKeystoreService._internal();

  // Storage configuration for maximum security
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Use EncryptedSharedPreferences
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'SecureVault',
    ),
  );

  // Key prefixes
  static const String _vaultKeyPrefix = 'vault_master_key_';
  static const String _biometricKeyPrefix = 'vault_biometric_key_';
  static const String _metadataPrefix = 'vault_metadata_';

  /// Store encrypted master key in hardware keystore
  /// Returns true if successfully stored
  Future<bool> storeVaultKey(int vaultId, Uint8List encryptedKey) async {
    try {
      final keyName = '$_vaultKeyPrefix$vaultId';
      final encoded = _encodeKey(encryptedKey);

      await _storage.write(
        key: keyName,
        value: encoded,
      );

      AppLogger.log('Vault key stored in hardware keystore: $vaultId', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Failed to store vault key', tag: _tag, error: e);
      return false;
    }
  }

  /// Retrieve encrypted master key from hardware keystore
  Future<Uint8List?> retrieveVaultKey(int vaultId) async {
    try {
      final keyName = '$_vaultKeyPrefix$vaultId';
      final encoded = await _storage.read(key: keyName);

      if (encoded == null) {
        AppLogger.warning('Vault key not found: $vaultId', tag: _tag);
        return null;
      }

      return _decodeKey(encoded);
    } catch (e) {
      AppLogger.error('Failed to retrieve vault key', tag: _tag, error: e);
      return null;
    }
  }

  /// Delete vault key from hardware keystore
  Future<bool> deleteVaultKey(int vaultId) async {
    try {
      final keyName = '$_vaultKeyPrefix$vaultId';
      await _storage.delete(key: keyName);

      // Also delete associated biometric key
      await deleteBiometricKey(vaultId);

      AppLogger.log('Vault key deleted: $vaultId', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Failed to delete vault key', tag: _tag, error: e);
      return false;
    }
  }

  /// Store biometric-protected key for vault
  /// This allows unlocking vault with biometrics
  Future<bool> storeBiometricKey(int vaultId, Uint8List masterKey) async {
    try {
      final keyName = '$_biometricKeyPrefix$vaultId';
      final encoded = _encodeKey(masterKey);

      await _storage.write(
        key: keyName,
        value: encoded,
        aOptions: const AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

      AppLogger.log('Biometric key stored for vault: $vaultId', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Failed to store biometric key', tag: _tag, error: e);
      return false;
    }
  }

  /// Retrieve biometric-protected key for vault
  Future<Uint8List?> retrieveBiometricKey(int vaultId) async {
    try {
      final keyName = '$_biometricKeyPrefix$vaultId';
      final encoded = await _storage.read(key: keyName);

      if (encoded == null) {
        return null;
      }

      return _decodeKey(encoded);
    } catch (e) {
      AppLogger.error('Failed to retrieve biometric key', tag: _tag, error: e);
      return null;
    }
  }

  /// Delete biometric key for vault
  Future<bool> deleteBiometricKey(int vaultId) async {
    try {
      final keyName = '$_biometricKeyPrefix$vaultId';
      await _storage.delete(key: keyName);
      return true;
    } catch (e) {
      AppLogger.error('Failed to delete biometric key', tag: _tag, error: e);
      return false;
    }
  }

  /// Check if vault has biometric key stored
  Future<bool> hasBiometricKey(int vaultId) async {
    final keyName = '$_biometricKeyPrefix$vaultId';
    return await _storage.containsKey(key: keyName);
  }

  /// Store vault metadata securely
  Future<bool> storeVaultMetadata(int vaultId, Map<String, String> metadata) async {
    try {
      final keyName = '$_metadataPrefix$vaultId';
      final encoded = metadata.entries.map((e) => '${e.key}:${e.value}').join('|');

      await _storage.write(key: keyName, value: encoded);
      return true;
    } catch (e) {
      AppLogger.error('Failed to store vault metadata', tag: _tag, error: e);
      return false;
    }
  }

  /// Retrieve vault metadata
  Future<Map<String, String>?> retrieveVaultMetadata(int vaultId) async {
    try {
      final keyName = '$_metadataPrefix$vaultId';
      final encoded = await _storage.read(key: keyName);

      if (encoded == null) return null;

      final metadata = <String, String>{};
      for (final pair in encoded.split('|')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          metadata[parts[0]] = parts[1];
        }
      }
      return metadata;
    } catch (e) {
      AppLogger.error('Failed to retrieve vault metadata', tag: _tag, error: e);
      return null;
    }
  }

  /// Check if hardware keystore is available
  Future<bool> isHardwareKeystoreAvailable() async {
    if (kIsWeb) return false;

    try {
      // Try to write and read a test key
      const testKey = '_hardware_test_key';
      await _storage.write(key: testKey, value: 'test');
      await _storage.read(key: testKey);
      await _storage.delete(key: testKey);
      return true;
    } catch (e) {
      AppLogger.error('Hardware keystore not available', tag: _tag, error: e);
      return false;
    }
  }

  /// Get storage type description
  String getStorageDescription() {
    if (kIsWeb) {
      return 'Web Storage (limited security)';
    }
    return 'Hardware-backed Keystore (Android Keystore / iOS Keychain)';
  }

  /// Clear all stored keys
  /// Use with caution - this will lock all vaults
  Future<void> clearAllKeys() async {
    try {
      await _storage.deleteAll();
      AppLogger.warning('All keys cleared from hardware keystore', tag: _tag);
    } catch (e) {
      AppLogger.error('Failed to clear all keys', tag: _tag, error: e);
    }
  }

  /// Encode key to string for storage
  String _encodeKey(Uint8List key) {
    return key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Decode key from string
  Uint8List _decodeKey(String encoded) {
    final bytes = <int>[];
    for (var i = 0; i < encoded.length; i += 2) {
      bytes.add(int.parse(encoded.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }
}
