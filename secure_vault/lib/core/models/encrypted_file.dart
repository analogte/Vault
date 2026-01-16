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
    );
  }

  bool get isImage {
    if (fileType == null) return false;
    final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    return imageTypes.contains(fileType!.toLowerCase());
  }
}
