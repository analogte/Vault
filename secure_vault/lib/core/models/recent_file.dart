/// Model for tracking recently accessed files
class RecentFile {
  final int? id;
  final int fileId;
  final int vaultId;
  final DateTime accessedAt;

  RecentFile({
    this.id,
    required this.fileId,
    required this.vaultId,
    required this.accessedAt,
  });

  factory RecentFile.fromMap(Map<String, dynamic> map) {
    return RecentFile(
      id: map['id'] as int?,
      fileId: map['file_id'] as int,
      vaultId: map['vault_id'] as int,
      accessedAt: DateTime.fromMillisecondsSinceEpoch(map['accessed_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'file_id': fileId,
      'vault_id': vaultId,
      'accessed_at': accessedAt.millisecondsSinceEpoch,
    };
  }

  RecentFile copyWith({
    int? id,
    int? fileId,
    int? vaultId,
    DateTime? accessedAt,
  }) {
    return RecentFile(
      id: id ?? this.id,
      fileId: fileId ?? this.fileId,
      vaultId: vaultId ?? this.vaultId,
      accessedAt: accessedAt ?? this.accessedAt,
    );
  }
}
