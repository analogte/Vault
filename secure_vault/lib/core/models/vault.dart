/// Vault model representing an encrypted storage container
class Vault {
  final int? id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime? lastAccessed;
  final List<int> salt;
  final List<int> encryptedMasterKey;

  Vault({
    this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    this.lastAccessed,
    required this.salt,
    required this.encryptedMasterKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_accessed': lastAccessed?.millisecondsSinceEpoch,
      'salt': salt,
      'encrypted_master_key': encryptedMasterKey,
    };
  }

  factory Vault.fromMap(Map<String, dynamic> map) {
    return Vault(
      id: map['id'] as int?,
      name: map['name'] as String,
      path: map['path'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lastAccessed: map['last_accessed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_accessed'] as int)
          : null,
      salt: List<int>.from(map['salt'] as List),
      encryptedMasterKey: List<int>.from(map['encrypted_master_key'] as List),
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
  }) {
    return Vault(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      salt: salt ?? this.salt,
      encryptedMasterKey: encryptedMasterKey ?? this.encryptedMasterKey,
    );
  }
}
