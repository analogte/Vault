import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vault.dart';
import '../models/encrypted_file.dart';

/// Database helper for managing SQLite database
class DatabaseHelper {
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
      print('Database initialization error: $e');
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
        version: 1,
        onCreate: _createDB,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('openDatabase timeout');
        },
      );
    } catch (e) {
      print('_initDB error: $e');
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
        salt BLOB NOT NULL,
        encrypted_master_key BLOB NOT NULL
      )
    ''');

    // Files table
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

    // Create indexes
    await db.execute('CREATE INDEX idx_vault_id ON files(vault_id)');
    await db.execute('CREATE INDEX idx_file_type ON files(file_type)');
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
      print('createVault error: $e');
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

  // File operations
  Future<int> createFile(EncryptedFile file) async {
    final db = await database;
    return await db.insert('files', file.toMap());
  }

  Future<List<EncryptedFile>> getFilesByVault(int vaultId) async {
    final db = await database;
    final maps = await db.query(
      'files',
      where: 'vault_id = ?',
      whereArgs: [vaultId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => EncryptedFile.fromMap(map)).toList();
  }

  Future<List<EncryptedFile>> getImageFilesByVault(int vaultId) async {
    final db = await database;
    final maps = await db.query(
      'files',
      where: 'vault_id = ? AND file_type IN (?, ?, ?, ?, ?, ?)',
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

  Future<int> deleteFile(int id) async {
    final db = await database;
    return await db.delete('files', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
