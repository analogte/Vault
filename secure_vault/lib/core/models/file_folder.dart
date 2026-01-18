/// File folder model for organizing files within vaults
class FileFolder {
  final int? id;
  final int vaultId;
  final String encryptedName;
  final int? parentFolderId;
  final DateTime createdAt;
  final DateTime? modifiedAt;

  // Computed fields (not stored in DB)
  int fileCount;

  FileFolder({
    this.id,
    required this.vaultId,
    required this.encryptedName,
    this.parentFolderId,
    required this.createdAt,
    this.modifiedAt,
    this.fileCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vault_id': vaultId,
      'encrypted_name': encryptedName,
      'parent_folder_id': parentFolderId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'modified_at': modifiedAt?.millisecondsSinceEpoch,
    };
  }

  factory FileFolder.fromMap(Map<String, dynamic> map) {
    return FileFolder(
      id: map['id'] as int?,
      vaultId: map['vault_id'] as int,
      encryptedName: map['encrypted_name'] as String,
      parentFolderId: map['parent_folder_id'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      modifiedAt: map['modified_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['modified_at'] as int)
          : null,
      fileCount: map['file_count'] as int? ?? 0,
    );
  }

  FileFolder copyWith({
    int? id,
    int? vaultId,
    String? encryptedName,
    int? parentFolderId,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? fileCount,
  }) {
    return FileFolder(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      encryptedName: encryptedName ?? this.encryptedName,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      fileCount: fileCount ?? this.fileCount,
    );
  }
}
