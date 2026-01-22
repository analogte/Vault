import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../core/utils/logger.dart';

/// Service for managing biometric authentication
class BiometricService {
  static const String _tag = 'BiometricService';
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricVaultsKey = 'biometric_vaults'; // vault_id -> encrypted_password

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    if (kIsWeb) return false;

    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      AppLogger.error('isDeviceSupported error', tag: _tag, error: e);
      return false;
    }
  }

  /// Check if biometrics are enrolled on the device
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;

    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      AppLogger.error('canCheckBiometrics error', tag: _tag, error: e);
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];

    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.error('getAvailableBiometrics error', tag: _tag, error: e);
      return [];
    }
  }

  /// Check if biometric is available and ready to use
  Future<bool> isBiometricAvailable() async {
    final isSupported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    final biometrics = await getAvailableBiometrics();

    return isSupported && canCheck && biometrics.isNotEmpty;
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String localizedReason = 'ยืนยันตัวตนเพื่อเปิด Vault',
    bool biometricOnly = false,
  }) async {
    if (kIsWeb) return false;

    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      AppLogger.error('authenticate error: ${e.code} - ${e.message}', tag: _tag, error: e);
      return false;
    }
  }

  /// Check if biometric is enabled globally
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Enable/disable biometric globally
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Check if biometric is enabled for a specific vault
  Future<bool> isVaultBiometricEnabled(int vaultId) async {
    try {
      final vaultsJson = await _storage.read(key: _biometricVaultsKey);
      if (vaultsJson == null) return false;

      final vaults = json.decode(vaultsJson) as Map<String, dynamic>;
      return vaults.containsKey(vaultId.toString());
    } catch (e) {
      return false;
    }
  }

  /// Enable biometric for a vault (stores encrypted password)
  Future<void> enableVaultBiometric(int vaultId, String password) async {
    try {
      Map<String, dynamic> vaults = {};

      final vaultsJson = await _storage.read(key: _biometricVaultsKey);
      if (vaultsJson != null) {
        vaults = json.decode(vaultsJson) as Map<String, dynamic>;
      }

      // Store password (already encrypted by secure storage)
      vaults[vaultId.toString()] = base64Encode(utf8.encode(password));

      await _storage.write(key: _biometricVaultsKey, value: json.encode(vaults));
      await setBiometricEnabled(true);

      AppLogger.log('Biometric enabled for vault $vaultId', tag: _tag);
    } catch (e) {
      AppLogger.error('enableVaultBiometric error', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Disable biometric for a vault
  Future<void> disableVaultBiometric(int vaultId) async {
    try {
      final vaultsJson = await _storage.read(key: _biometricVaultsKey);
      if (vaultsJson == null) return;

      final vaults = json.decode(vaultsJson) as Map<String, dynamic>;
      vaults.remove(vaultId.toString());

      await _storage.write(key: _biometricVaultsKey, value: json.encode(vaults));

      AppLogger.log('Biometric disabled for vault $vaultId', tag: _tag);
    } catch (e) {
      AppLogger.error('disableVaultBiometric error', tag: _tag, error: e);
    }
  }

  /// Get stored password for vault after biometric authentication
  Future<String?> getVaultPassword(int vaultId) async {
    try {
      final vaultsJson = await _storage.read(key: _biometricVaultsKey);
      if (vaultsJson == null) return null;

      final vaults = json.decode(vaultsJson) as Map<String, dynamic>;
      final encodedPassword = vaults[vaultId.toString()];

      if (encodedPassword == null) return null;

      return utf8.decode(base64Decode(encodedPassword));
    } catch (e) {
      AppLogger.error('getVaultPassword error', tag: _tag, error: e);
      return null;
    }
  }

  /// Authenticate and get vault password
  Future<String?> authenticateAndGetPassword(int vaultId) async {
    // First check if biometric is enabled for this vault
    final isEnabled = await isVaultBiometricEnabled(vaultId);
    if (!isEnabled) {
      AppLogger.log('Biometric not enabled for vault $vaultId', tag: _tag);
      return null;
    }

    // Authenticate
    final authenticated = await authenticate(
      localizedReason: 'ยืนยันตัวตนด้วยลายนิ้วมือหรือ Face ID เพื่อเปิด Vault',
    );

    if (!authenticated) {
      AppLogger.log('Authentication failed', tag: _tag);
      return null;
    }

    // Get password
    return await getVaultPassword(vaultId);
  }

  /// Clear all biometric data
  Future<void> clearAll() async {
    await _storage.delete(key: _biometricEnabledKey);
    await _storage.delete(key: _biometricVaultsKey);
  }

  /// Get biometric type name for display
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'ลายนิ้วมือ';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (types.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Biometric';
  }
}
