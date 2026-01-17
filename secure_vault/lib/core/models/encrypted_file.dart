/// Encrypted file model
class EncryptedFile {
  final int? id;
  final int vaultId;
  final String encryptedName;
  final String encryptedPath;
  final String? fileType;
  final int size;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final String? thumbnailPath;
  final DateTime? deletedAt;

  EncryptedFile({
    this.id,
    required this.vaultId,
    required this.encryptedName,
    required this.encryptedPath,
    this.fileType,
    required this.size,
    required this.createdAt,
    this.modifiedAt,
    this.thumbnailPath,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vault_id': vaultId,
      'encrypted_name': encryptedName,
      'encrypted_path': encryptedPath,
      'file_type': fileType,
      'size': size,
      'created_at': createdAt.millisecondsSinceEpoch,
      'modified_at': modifiedAt?.millisecondsSinceEpoch,
      'thumbnail_path': thumbnailPath,
      'deleted_at': deletedAt?.millisecondsSinceEpoch,
    };
  }

  factory EncryptedFile.fromMap(Map<String, dynamic> map) {
    return EncryptedFile(
      id: map['id'] as int?,
      vaultId: map['vault_id'] as int,
      encryptedName: map['encrypted_name'] as String,
      encryptedPath: map['encrypted_path'] as String,
      fileType: map['file_type'] as String?,
      size: map['size'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      modifiedAt: map['modified_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['modified_at'] as int)
          : null,
      thumbnailPath: map['thumbnail_path'] as String?,
      deletedAt: map['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deleted_at'] as int)
          : null,
    );
  }

  bool get isImage {
    if (fileType == null) return false;
    final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    return imageTypes.contains(fileType!.toLowerCase());
  }

  bool get isDeleted => deletedAt != null;

  /// Days remaining before permanent deletion (30 days in trash)
  int? get daysUntilPermanentDeletion {
    if (deletedAt == null) return null;
    final deleteDate = deletedAt!.add(const Duration(days: 30));
    final remaining = deleteDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  EncryptedFile copyWith({
    int? id,
    int? vaultId,
    String? encryptedName,
    String? encryptedPath,
    String? fileType,
    int? size,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? thumbnailPath,
    DateTime? deletedAt,
  }) {
    return EncryptedFile(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      encryptedName: encryptedName ?? this.encryptedName,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      fileType: fileType ?? this.fileType,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
