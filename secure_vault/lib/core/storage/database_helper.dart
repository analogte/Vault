import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vault.dart';
import '../models/encrypted_file.dart';
import '../models/file_folder.dart';
import '../models/recent_file.dart';
import '../models/file_tag.dart';
import '../utils/logger.dart';

/// Database helper for managing SQLite database
class DatabaseHelper {
  static const String _tag = 'DatabaseHelper';
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('secure_vault.db').timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Database initialization timeout');
        },
      );
      return _database!;
    } catch (e) {
      AppLogger.error('Database initialization error', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('getDatabasesPath timeout');
        },
      );
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 8, // Updated version for streaming encryption
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
        onOpen: (db) async {
          // Try to enable WAL mode for better write performance
          // Some Android versions (API 36+) may not support PRAGMA via execute
          try {
            await db.rawQuery('PRAGMA journal_mode=WAL');
            await db.rawQuery('PRAGMA synchronous=NORMAL');
          } catch (e) {
            // Fallback: WAL might already be enabled by default on newer Android
            AppLogger.log('PRAGMA commands not supported, using defaults', tag: _tag);
          }
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('openDatabase timeout');
        },
      );
    } catch (e) {
      AppLogger.error('_initDB error', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Vaults table
    await db.execute('''
      CREATE TABLE vaults (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        path TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL,
        last_accessed INTEGER,
        salt TEXT NOT NULL,
        encrypted_master_key TEXT NOT NULL,
        kdf_version TEXT DEFAULT 'pbkdf2',
        is_decoy INTEGER DEFAULT 0
      )
    ''');

    // Folders table
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vault_id INTEGER NOT NULL,
        encrypted_name TEXT NOT NULL,
        parent_folder_id INTEGER,
        created_at INTEGER NOT NULL,
        modified_at INTEGER,
        FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_folder_id) REFERENCES folders(id) ON DELETE CASCADE
      )
    ''');

    // Files table with trash and folder support
    await db.execute('''
      CREATE TABLE files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vault_id INTEGER NOT NULL,
        encrypted_name TEXT NOT NULL,
        encrypted_path TEXT NOT NULL,
        file_type TEXT,
        size INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        modified_at INTEGER,
        thumbnail_path TEXT,
        deleted_at INTEGER,
        folder_id INTEGER,
        is_chunked INTEGER DEFAULT 0,
        chunk_count INTEGER DEFAULT 0,
        FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE SET NULL
      )
    ''');

    // Thumbnails table
    await db.execute('''
      CREATE TABLE thumbnails (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_id INTEGER NOT NULL,
        thumbnail_data BLOB,
        FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE
      )
    ''');

    // Recent files table
    await db.execute('''
      CREATE TABLE recent_files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_id INTEGER NOT NULL,
        vault_id INTEGER NOT NULL,
        accessed_at INTEGER NOT NULL,
        FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE,
        FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for common queries
    await db.execute('CREATE INDEX idx_vault_id ON files(vault_id)');
    await db.execute('CREATE INDEX idx_file_type ON files(file_type)');
    await db.execute('CREATE INDEX idx_deleted_at ON files(deleted_at)');

    // Composite indexes for faster queries (most common query patterns)
    await db.execute('CREATE INDEX idx_vault_deleted ON files(vault_id, deleted_at)');
    await db.execute('CREATE INDEX idx_vault_type_deleted ON files(vault_id, file_type, deleted_at)');
    await db.execute('CREATE INDEX idx_created_at ON files(created_at DESC)');

    // Folder indexes
    await db.execute('CREATE INDEX idx_folders_vault ON folders(vault_id)');
    await db.execute('CREATE INDEX idx_folders_parent ON folders(parent_folder_id)');
    await db.execute('CREATE INDEX idx_files_folder ON files(folder_id)');

    // Recent files indexes
    await db.execute('CREATE INDEX idx_recent_vault ON recent_files(vault_id, accessed_at DESC)');
    await db.execute('CREATE INDEX idx_recent_file ON recent_files(file_id)');

    // Tags table
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vault_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color TEXT DEFAULT '#2196F3',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE
      )
    ''');

    // File-tag relationship table
    await db.execute('''
      CREATE TABLE file_tags (
        file_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (file_id, tag_id),
        FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
      )
    ''');

    // Tags indexes
    await db.execute('CREATE INDEX idx_tags_vault ON tags(vault_id)');
    await db.execute('CREATE INDEX idx_file_tags_file ON file_tags(file_id)');
    await db.execute('CREATE INDEX idx_file_tags_tag ON file_tags(tag_id)');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add deleted_at column for trash support
      await db.execute('ALTER TABLE files ADD COLUMN deleted_at INTEGER');
      await db.execute('CREATE INDEX idx_deleted_at ON files(deleted_at)');
    }
    if (oldVersion < 3) {
      // Add composite indexes for faster queries
      await db.execute('CREATE INDEX IF NOT EXISTS idx_vault_deleted ON files(vault_id, deleted_at)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_vault_type_deleted ON files(vault_id, file_type, deleted_at)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_created_at ON files(created_at DESC)');
    }
    if (oldVersion < 4) {
      // Add kdf_version and is_decoy columns for security enhancements
      await db.execute("ALTER TABLE vaults ADD COLUMN kdf_version TEXT DEFAULT 'pbkdf2'");
      await db.execute('ALTER TABLE vaults ADD COLUMN is_decoy INTEGER DEFAULT 0');
    }
    if (oldVersion < 5) {
      // Add folder support
      await db.execute('''
        CREATE TABLE IF NOT EXISTS folders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vault_id INTEGER NOT NULL,
          encrypted_name TEXT NOT NULL,
          parent_folder_id INTEGER,
          created_at INTEGER NOT NULL,
          modified_at INTEGER,
          FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE,
          FOREIGN KEY (parent_folder_id) REFERENCES folders(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('ALTER TABLE files ADD COLUMN folder_id INTEGER');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_folders_vault ON folders(vault_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_folders_parent ON folders(parent_folder_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_files_folder ON files(folder_id)');
    }
    if (oldVersion < 6) {
      // Add recent files support
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recent_files (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          file_id INTEGER NOT NULL,
          vault_id INTEGER NOT NULL,
          accessed_at INTEGER NOT NULL,
          FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE,
          FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_recent_vault ON recent_files(vault_id, accessed_at DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_recent_file ON recent_files(file_id)');
    }
    if (oldVersion < 7) {
      // Add tags support
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vault_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          color TEXT DEFAULT '#2196F3',
          created_at INTEGER NOT NULL,
          FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS file_tags (
          file_id INTEGER NOT NULL,
          tag_id INTEGER NOT NULL,
          PRIMARY KEY (file_id, tag_id),
          FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_tags_vault ON tags(vault_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_file_tags_file ON file_tags(file_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_file_tags_tag ON file_tags(tag_id)');
    }
    if (oldVersion < 8) {
      // Add streaming encryption support for large files
      await db.execute('ALTER TABLE files ADD COLUMN is_chunked INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE files ADD COLUMN chunk_count INTEGER DEFAULT 0');
    }
  }

  // Vault operations
  Future<int> createVault(Vault vault) async {
    try {
      final db = await database;
      return await db.insert('vaults', vault.toMap()).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Database insert timeout');
        },
      );
    } catch (e) {
      AppLogger.error('createVault error', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<Vault>> getAllVaults() async {
    final db = await database;
    final maps = await db.query('vaults', orderBy: 'created_at DESC');
    return maps.map((map) => Vault.fromMap(map)).toList();
  }

  Future<Vault?> getVault(int id) async {
    final db = await database;
    final maps = await db.query(
      'vaults',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Vault.fromMap(maps.first);
  }

  Future<Vault?> getVaultByPath(String path) async {
    final db = await database;
    final maps = await db.query(
      'vaults',
      where: 'path = ?',
      whereArgs: [path],
    );
    if (maps.isEmpty) return null;
    return Vault.fromMap(maps.first);
  }

  Future<int> updateVault(Vault vault) async {
    final db = await database;
    return await db.update(
      'vaults',
      vault.toMap(),
      where: 'id = ?',
      whereArgs: [vault.id],
    );
  }

  Future<int> deleteVault(int id) async {
    final db = await database;
    return await db.delete('vaults', where: 'id = ?', whereArgs: [id]);
  }

  // Folder operations
  Future<int> createFolder(FileFolder folder) async {
    final db = await database;
    return await db.insert('folders', folder.toMap());
  }

  Future<List<FileFolder>> getFoldersByVault(int vaultId, {int? parentFolderId}) async {
    final db = await database;

    // Get folders with file count
    final maps = await db.rawQuery('''
      SELECT f.*,
        (SELECT COUNT(*) FROM files WHERE folder_id = f.id AND deleted_at IS NULL) as file_count
      FROM folders f
      WHERE f.vault_id = ? AND f.parent_folder_id ${parentFolderId == null ? 'IS NULL' : '= ?'}
      ORDER BY f.created_at DESC
    ''', parentFolderId == null ? [vaultId] : [vaultId, parentFolderId]);

    return maps.map((map) => FileFolder.fromMap(map)).toList();
  }

  Future<FileFolder?> getFolder(int id) async {
    final db = await database;
    final maps = await db.query(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FileFolder.fromMap(maps.first);
  }

  Future<int> updateFolder(FileFolder folder) async {
    final db = await database;
    return await db.update(
      'folders',
      folder.toMap(),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    // Files in the folder will have folder_id set to NULL due to ON DELETE SET NULL
    return await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  // Move file to folder
  Future<int> moveFileToFolder(int fileId, int? folderId) async {
    final db = await database;
    return await db.update(
      'files',
      {'folder_id': folderId, 'modified_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  // File operations - exclude deleted files
  Future<int> createFile(EncryptedFile file) async {
    final db = await database;
    return await db.insert('files', file.toMap());
  }

  Future<List<EncryptedFile>> getFilesByVault(int vaultId) async {
    final db = await database;
    final maps = await db.query(
      'files',
      where: 'vault_id = ? AND deleted_at IS NULL',
      whereArgs: [vaultId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => EncryptedFile.fromMap(map)).toList();
  }

  Future<List<EncryptedFile>> getFilesByFolder(int vaultId, int? folderId) async {
    final db = await database;
    final maps = await db.query(
      'files',
      where: folderId == null
          ? 'vault_id = ? AND folder_id IS NULL AND deleted_at IS NULL'
          : 'vault_id = ? AND folder_id = ? AND deleted_at IS NULL',
      whereArgs: folderId == null ? [vaultId] : [vaultId, folderId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => EncryptedFile.fromMap(map)).toList();
  }

  Future<List<EncryptedFile>> getImageFilesByVault(int vaultId) async {
    final db = await database;
    final maps = await db.query(
      'files',
      where: 'vault_id = ? AND deleted_at IS NULL AND file_type IN (?, ?, ?, ?, ?, ?)',
      whereArgs: [vaultId, 'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => EncryptedFile.fromMap(map)).toList();
  }

  Future<EncryptedFile?> getFile(int id) async {
    final db = await database;
    final maps = await db.query(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return EncryptedFile.fromMap(maps.first);
  }

  Future<int> updateFile(EncryptedFile file) async {
    final db = await database;
    return await db.update(
      'files',
      file.toMap(),
      where: 'id = ?',
      whereArgs: [file.id],
    );
  }

  // Soft delete - move to trash
  Future<int> softDeleteFile(int id) async {
    final db = await database;
    return await db.update(
      'files',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hard delete - permanent
  Future<int> deleteFile(int id) async {
    final db = await database;
    return await db.delete('files', where: 'id = ?', whereArgs: [id]);
  }

  // Trash operations
  Future<List<EncryptedFile>> getTrashFiles() async {
    final db = await database;
    final maps = await db.query(
      'files',
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );
    return maps.map((map) => EncryptedFile.fromMap(map)).toList();
  }

  Future<List<EncryptedFile>> getTrashFilesByVault(int vaultId) async {
    final db = await database;
    final maps = await db.query(
      'files',
      where: 'vault_id = ? AND deleted_at IS NOT NULL',
      whereArgs: [vaultId],
      orderBy: 'deleted_at DESC',
    );
    return maps.map((map) => EncryptedFile.fromMap(map)).toList();
  }

  // Restore from trash
  Future<int> restoreFile(int id) async {
    final db = await database;
    return await db.update(
      'files',
      {'deleted_at': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Empty trash - delete files older than specified days
  Future<int> emptyTrash({int olderThanDays = 30}) async {
    final db = await database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: olderThanDays))
        .millisecondsSinceEpoch;

    return await db.delete(
      'files',
      where: 'deleted_at IS NOT NULL AND deleted_at < ?',
      whereArgs: [cutoffTime],
    );
  }

  // Get trash count
  Future<int> getTrashCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM files WHERE deleted_at IS NOT NULL',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Auto-cleanup expired trash (files older than 30 days)
  Future<void> cleanupExpiredTrash() async {
    final deleted = await emptyTrash(olderThanDays: 30);
    if (deleted > 0) {
      AppLogger.log('Cleaned up $deleted expired trash files', tag: _tag);
    }
  }

  // Recent files operations
  Future<void> trackFileAccess(int fileId, int vaultId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if file already exists in recent
    final existing = await db.query(
      'recent_files',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );

    if (existing.isNotEmpty) {
      // Update access time
      await db.update(
        'recent_files',
        {'accessed_at': now},
        where: 'file_id = ?',
        whereArgs: [fileId],
      );
    } else {
      // Insert new record
      await db.insert('recent_files', {
        'file_id': fileId,
        'vault_id': vaultId,
        'accessed_at': now,
      });

      // Keep only last 50 recent files per vault
      await _cleanupOldRecentFiles(vaultId, 50);
    }
  }

  Future<void> _cleanupOldRecentFiles(int vaultId, int keepCount) async {
    final db = await database;
    await db.execute('''
      DELETE FROM recent_files
      WHERE vault_id = ? AND id NOT IN (
        SELECT id FROM recent_files
        WHERE vault_id = ?
        ORDER BY accessed_at DESC
        LIMIT ?
      )
    ''', [vaultId, vaultId, keepCount]);
  }

  Future<List<EncryptedFile>> getRecentFiles(int vaultId, {int limit = 10}) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT f.* FROM files f
      INNER JOIN recent_files r ON f.id = r.file_id
      WHERE r.vault_id = ? AND f.deleted_at IS NULL
      ORDER BY r.accessed_at DESC
      LIMIT ?
    ''', [vaultId, limit]);

    return maps.map((map) => EncryptedFile.fromMap(map)).toList();
  }

  Future<void> clearRecentFiles(int vaultId) async {
    final db = await database;
    await db.delete(
      'recent_files',
      where: 'vault_id = ?',
      whereArgs: [vaultId],
    );
  }

  Future<void> removeFromRecent(int fileId) async {
    final db = await database;
    await db.delete(
      'recent_files',
      where: 'file_id = ?',
      whereArgs: [fileId],
    );
  }

  // Tag operations
  Future<int> createTag(FileTag tag) async {
    final db = await database;
    return await db.insert('tags', tag.toMap());
  }

  Future<List<FileTag>> getTagsByVault(int vaultId) async {
    final db = await database;
    final maps = await db.query(
      'tags',
      where: 'vault_id = ?',
      whereArgs: [vaultId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => FileTag.fromMap(map)).toList();
  }

  Future<FileTag?> getTag(int id) async {
    final db = await database;
    final maps = await db.query(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FileTag.fromMap(maps.first);
  }

  Future<int> updateTag(FileTag tag) async {
    final db = await database;
    return await db.update(
      'tags',
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<int> deleteTag(int id) async {
    final db = await database;
    return await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  // File-Tag assignment operations
  Future<void> addTagToFile(int fileId, int tagId) async {
    final db = await database;
    await db.insert(
      'file_tags',
      {'file_id': fileId, 'tag_id': tagId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeTagFromFile(int fileId, int tagId) async {
    final db = await database;
    await db.delete(
      'file_tags',
      where: 'file_id = ? AND tag_id = ?',
      whereArgs: [fileId, tagId],
    );
  }

  Future<List<FileTag>> getTagsForFile(int fileId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT t.* FROM tags t
      INNER JOIN file_tags ft ON t.id = ft.tag_id
      WHERE ft.file_id = ?
      ORDER BY t.name ASC
    ''', [fileId]);
    return maps.map((map) => FileTag.fromMap(map)).toList();
  }

  Future<List<EncryptedFile>> getFilesByTag(int tagId, int vaultId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT f.* FROM files f
      INNER JOIN file_tags ft ON f.id = ft.file_id
      WHERE ft.tag_id = ? AND f.vault_id = ? AND f.deleted_at IS NULL
      ORDER BY f.created_at DESC
    ''', [tagId, vaultId]);
    return maps.map((map) => EncryptedFile.fromMap(map)).toList();
  }

  Future<void> setTagsForFile(int fileId, List<int> tagIds) async {
    final db = await database;
    await db.transaction((txn) async {
      // Remove all existing tags
      await txn.delete('file_tags', where: 'file_id = ?', whereArgs: [fileId]);
      // Add new tags
      for (final tagId in tagIds) {
        await txn.insert('file_tags', {'file_id': fileId, 'tag_id': tagId});
      }
    });
  }

  // Storage statistics
  Future<Map<String, dynamic>> getStorageStats({int? vaultId}) async {
    final db = await database;

    // Build where clause
    final whereClause = vaultId != null
        ? 'WHERE vault_id = ? AND deleted_at IS NULL'
        : 'WHERE deleted_at IS NULL';
    final whereArgs = vaultId != null ? [vaultId] : <Object>[];

    // Total count and size
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count, COALESCE(SUM(size), 0) as total_size FROM files $whereClause',
      whereArgs,
    );

    // Size by file type
    final typeStats = await db.rawQuery('''
      SELECT
        file_type,
        COUNT(*) as count,
        COALESCE(SUM(size), 0) as size
      FROM files
      $whereClause
      GROUP BY file_type
      ORDER BY size DESC
    ''', whereArgs);

    // Trash stats
    final trashWhereClause = vaultId != null
        ? 'WHERE vault_id = ? AND deleted_at IS NOT NULL'
        : 'WHERE deleted_at IS NOT NULL';
    final trashResult = await db.rawQuery(
      'SELECT COUNT(*) as count, COALESCE(SUM(size), 0) as total_size FROM files $trashWhereClause',
      whereArgs,
    );

    // Folder count
    final folderWhereClause = vaultId != null ? 'WHERE vault_id = ?' : '';
    final folderResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM folders $folderWhereClause',
      whereArgs,
    );

    // Categorize file types
    final Map<String, Map<String, int>> byCategory = {
      'images': {'count': 0, 'size': 0},
      'videos': {'count': 0, 'size': 0},
      'documents': {'count': 0, 'size': 0},
      'audio': {'count': 0, 'size': 0},
      'other': {'count': 0, 'size': 0},
    };

    for (final row in typeStats) {
      final fileType = (row['file_type'] as String?)?.toLowerCase() ?? '';
      final count = (row['count'] as int?) ?? 0;
      final size = (row['size'] as int?) ?? 0;

      String category;
      if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic', 'heif'].contains(fileType)) {
        category = 'images';
      } else if (['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm'].contains(fileType)) {
        category = 'videos';
      } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'rtf', 'csv'].contains(fileType)) {
        category = 'documents';
      } else if (['mp3', 'wav', 'aac', 'flac', 'm4a', 'ogg', 'wma'].contains(fileType)) {
        category = 'audio';
      } else {
        category = 'other';
      }

      byCategory[category]!['count'] = byCategory[category]!['count']! + count;
      byCategory[category]!['size'] = byCategory[category]!['size']! + size;
    }

    return {
      'totalFiles': (countResult.first['count'] as int?) ?? 0,
      'totalSize': (countResult.first['total_size'] as int?) ?? 0,
      'trashFiles': (trashResult.first['count'] as int?) ?? 0,
      'trashSize': (trashResult.first['total_size'] as int?) ?? 0,
      'folderCount': (folderResult.first['count'] as int?) ?? 0,
      'byType': typeStats.map((row) => {
        'fileType': row['file_type'],
        'count': row['count'],
        'size': row['size'],
      }).toList(),
      'byCategory': byCategory,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
