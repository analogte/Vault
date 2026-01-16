const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

// สำหรับ development ใช้ SQLite
// สำหรับ production ใช้ PostgreSQL

let db = null;

const initDatabase = () => {
  return new Promise((resolve, reject) => {
    const dbPath = path.join(__dirname, '../../data');
    
    // สร้าง directory ถ้ายังไม่มี
    if (!fs.existsSync(dbPath)) {
      fs.mkdirSync(dbPath, { recursive: true });
    }

    const dbFile = path.join(dbPath, 'secure_vault.db');
    
    db = new sqlite3.Database(dbFile, (err) => {
      if (err) {
        console.error('Error opening database:', err);
        reject(err);
        return;
      }
      console.log('✅ Connected to SQLite database');
      createTables().then(resolve).catch(reject);
    });
  });
};

const createTables = () => {
  return new Promise((resolve, reject) => {
    db.serialize(() => {
      // Users table
      db.run(`
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          username TEXT UNIQUE,
          password_hash TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          last_login DATETIME,
          is_active INTEGER DEFAULT 1
        )
      `, (err) => {
        if (err) {
          console.error('Error creating users table:', err);
          reject(err);
          return;
        }
      });

      // Vaults table
      db.run(`
        CREATE TABLE IF NOT EXISTS vaults (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          encrypted_master_key TEXT NOT NULL,
          salt TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          last_accessed DATETIME,
          is_synced INTEGER DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      `, (err) => {
        if (err) {
          console.error('Error creating vaults table:', err);
          reject(err);
          return;
        }
      });

      // Files metadata table
      db.run(`
        CREATE TABLE IF NOT EXISTS files_metadata (
          id TEXT PRIMARY KEY,
          vault_id TEXT NOT NULL,
          encrypted_name TEXT NOT NULL,
          file_type TEXT,
          size INTEGER,
          encrypted_path TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          device_id TEXT,
          is_backed_up INTEGER DEFAULT 0,
          FOREIGN KEY (vault_id) REFERENCES vaults(id) ON DELETE CASCADE
        )
      `, (err) => {
        if (err) {
          console.error('Error creating files_metadata table:', err);
          reject(err);
          return;
        }
        console.log('✅ Database tables created');
        resolve();
      });

      // Create indexes
      db.run('CREATE INDEX IF NOT EXISTS idx_vaults_user_id ON vaults(user_id)');
      db.run('CREATE INDEX IF NOT EXISTS idx_files_vault_id ON files_metadata(vault_id)');
      db.run('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    });
  });
};

const getDatabase = () => {
  if (!db) {
    throw new Error('Database not initialized. Call initDatabase() first.');
  }
  return db;
};

const closeDatabase = () => {
  return new Promise((resolve, reject) => {
    if (db) {
      db.close((err) => {
        if (err) {
          reject(err);
        } else {
          console.log('Database connection closed');
          resolve();
        }
      });
    } else {
      resolve();
    }
  });
};

module.exports = {
  initDatabase,
  getDatabase,
  closeDatabase,
};
