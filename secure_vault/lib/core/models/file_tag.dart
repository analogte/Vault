/// Model for file tags/labels
class FileTag {
  final int? id;
  final int vaultId;
  final String name;
  final String color;
  final DateTime createdAt;

  FileTag({
    this.id,
    required this.vaultId,
    required this.name,
    this.color = '#2196F3',
    required this.createdAt,
  });

  factory FileTag.fromMap(Map<String, dynamic> map) {
    return FileTag(
      id: map['id'] as int?,
      vaultId: map['vault_id'] as int,
      name: map['name'] as String,
      color: (map['color'] as String?) ?? '#2196F3',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'vault_id': vaultId,
      'name': name,
      'color': color,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  FileTag copyWith({
    int? id,
    int? vaultId,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return FileTag(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Parse color string to Color
  int get colorValue {
    try {
      return int.parse(color.replaceFirst('#', '0xFF'));
    } catch (e) {
      return 0xFF2196F3; // Default blue
    }
  }

  /// Predefined colors for tags
  static const List<String> predefinedColors = [
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#795548', // Brown
    '#9E9E9E', // Grey
    '#607D8B', // Blue Grey
  ];
}

/// Represents a tag assigned to a file
class FileTagAssignment {
  final int fileId;
  final int tagId;

  FileTagAssignment({
    required this.fileId,
    required this.tagId,
  });

  factory FileTagAssignment.fromMap(Map<String, dynamic> map) {
    return FileTagAssignment(
      fileId: map['file_id'] as int,
      tagId: map['tag_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'file_id': fileId,
      'tag_id': tagId,
    };
  }
}
