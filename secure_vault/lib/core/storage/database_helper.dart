import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vault.dart';
import '../models/encrypted_file.dart';
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
        version: 4, // Updated version for security enhancements
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

    // Files table with trash support
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
        FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE
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

    // Create indexes for common queries
    await db.execute('CREATE INDEX idx_vault_id ON files(vault_id)');
    await db.execute('CREATE INDEX idx_file_type ON files(file_type)');
    await db.execute('CREATE INDEX idx_deleted_at ON files(deleted_at)');

    // Composite indexes for faster queries (most common query patterns)
    await db.execute('CREATE INDEX idx_vault_deleted ON files(vault_id, deleted_at)');
    await db.execute('CREATE INDEX idx_vault_type_deleted ON files(vault_id, file_type, deleted_at)');
    await db.execute('CREATE INDEX idx_created_at ON files(created_at DESC)');
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

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
