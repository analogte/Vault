import 'dart:convert';
import 'dart:typed_data';

/// Vault model representing an encrypted storage container
class Vault {
  final int? id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime? lastAccessed;
  final List<int> salt;
  final List<int> encryptedMasterKey;
  final String kdfVersion; // 'pbkdf2' or 'argon2id'
  final bool isDecoy; // Decoy vault feature

  Vault({
    this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    this.lastAccessed,
    required this.salt,
    required this.encryptedMasterKey,
    this.kdfVersion = 'pbkdf2', // Default to PBKDF2 for backward compatibility
    this.isDecoy = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_accessed': lastAccessed?.millisecondsSinceEpoch,
      // Store as base64 strings for web compatibility
      'salt': base64Encode(Uint8List.fromList(salt)),
      'encrypted_master_key': base64Encode(Uint8List.fromList(encryptedMasterKey)),
      'kdf_version': kdfVersion,
      'is_decoy': isDecoy ? 1 : 0,
    };
  }

  factory Vault.fromMap(Map<String, dynamic> map) {
    // Handle both base64 string (web) and List<int>/Uint8List (native)
    List<int> parseSalt(dynamic value) {
      if (value is String) {
        return base64Decode(value);
      } else if (value is Uint8List) {
        return value.toList();
      } else if (value is List) {
        return List<int>.from(value);
      }
      throw ArgumentError('Invalid salt format: ${value.runtimeType}');
    }

    return Vault(
      id: map['id'] as int?,
      name: map['name'] as String,
      path: map['path'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lastAccessed: map['last_accessed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_accessed'] as int)
          : null,
      salt: parseSalt(map['salt']),
      encryptedMasterKey: parseSalt(map['encrypted_master_key']),
      kdfVersion: map['kdf_version'] as String? ?? 'pbkdf2',
      isDecoy: map['is_decoy'] == 1 || map['is_decoy'] == true,
    );
  }

  Vault copyWith({
    int? id,
    String? name,
    String? path,
    DateTime? createdAt,
    DateTime? lastAccessed,
    List<int>? salt,
    List<int>? encryptedMasterKey,
    String? kdfVersion,
    bool? isDecoy,
  }) {
    return Vault(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      salt: salt ?? this.salt,
      encryptedMasterKey: encryptedMasterKey ?? this.encryptedMasterKey,
      kdfVersion: kdfVersion ?? this.kdfVersion,
      isDecoy: isDecoy ?? this.isDecoy,
    );
  }

  /// Check if vault uses Argon2id KDF
  bool get usesArgon2id => kdfVersion == 'argon2id';

  /// Check if vault uses PBKDF2 KDF
  bool get usesPbkdf2 => kdfVersion == 'pbkdf2';
}
