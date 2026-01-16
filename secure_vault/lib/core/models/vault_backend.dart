import 'dart:convert';
import 'vault.dart';

/// Vault model for backend API (with String IDs and base64 encoded data)
class VaultBackend {
  final String id;
  final String userId;
  final String name;
  final String encryptedMasterKey; // Base64 encoded
  final String salt; // Base64 encoded
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastAccessed;
  final bool isSynced;

  VaultBackend({
    required this.id,
    required this.userId,
    required this.name,
    required this.encryptedMasterKey,
    required this.salt,
    required this.createdAt,
    this.updatedAt,
    this.lastAccessed,
    required this.isSynced,
  });

  factory VaultBackend.fromJson(Map<String, dynamic> json) {
    return VaultBackend(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      encryptedMasterKey: json['encrypted_master_key'] as String,
      salt: json['salt'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastAccessed: json['last_accessed'] != null
          ? DateTime.parse(json['last_accessed'] as String)
          : null,
      isSynced: json['is_synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'encrypted_master_key': encryptedMasterKey,
      'salt': salt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_accessed': lastAccessed?.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  /// Convert to local Vault model
  Vault toLocalVault(String localPath) {
    // Decode base64 strings to List<int>
    final saltBytes = base64Decode(salt);
    final encryptedKeyBytes = base64Decode(encryptedMasterKey);
    
    return Vault(
      id: null, // Local ID will be set by database
      name: name,
      path: localPath,
      createdAt: createdAt,
      lastAccessed: lastAccessed,
      salt: saltBytes,
      encryptedMasterKey: encryptedKeyBytes,
    );
  }

  /// Create from local Vault model
  factory VaultBackend.fromLocalVault(Vault vault, String userId) {
    // Encode List<int> to base64 strings
    final saltBase64 = base64Encode(vault.salt);
    final encryptedKeyBase64 = base64Encode(vault.encryptedMasterKey);
    
    return VaultBackend(
      id: '', // Will be set by backend
      userId: userId,
      name: vault.name,
      encryptedMasterKey: encryptedKeyBase64,
      salt: saltBase64,
      createdAt: vault.createdAt,
      lastAccessed: vault.lastAccessed,
      isSynced: true,
    );
  }
}
