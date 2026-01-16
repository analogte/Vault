const { getDatabase } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

class Vault {
  static async findByUserId(userId) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      db.all(
        'SELECT * FROM vaults WHERE user_id = ? ORDER BY created_at DESC',
        [userId],
        (err, rows) => {
          if (err) {
            reject(err);
          } else {
            resolve(rows);
          }
        }
      );
    });
  }

  static async findById(id) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      db.get(
        'SELECT * FROM vaults WHERE id = ?',
        [id],
        (err, row) => {
          if (err) {
            reject(err);
          } else {
            resolve(row);
          }
        }
      );
    });
  }

  static async create({ userId, name, encryptedMasterKey, salt }) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      const id = uuidv4();
      const now = new Date().toISOString();

      db.run(
        `INSERT INTO vaults (id, user_id, name, encrypted_master_key, salt, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [id, userId, name, encryptedMasterKey, salt, now, now],
        function(err) {
          if (err) {
            reject(err);
          } else {
            // Get the created vault
            db.get(
              'SELECT * FROM vaults WHERE id = ?',
              [id],
              (err, row) => {
                if (err) {
                  reject(err);
                } else {
                  resolve(row);
                }
              }
            );
          }
        }
      );
    });
  }

  static async update(id, { name, lastAccessed }) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      const now = new Date().toISOString();
      const updates = [];
      const values = [];

      if (name !== undefined) {
        updates.push('name = ?');
        values.push(name);
      }
      if (lastAccessed !== undefined) {
        updates.push('last_accessed = ?');
        values.push(lastAccessed);
      }

      updates.push('updated_at = ?');
      values.push(now);
      values.push(id);

      db.run(
        `UPDATE vaults SET ${updates.join(', ')} WHERE id = ?`,
        values,
        function(err) {
          if (err) {
            reject(err);
          } else {
            resolve({ changes: this.changes });
          }
        }
      );
    });
  }

  static async delete(id) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      db.run(
        'DELETE FROM vaults WHERE id = ?',
        [id],
        function(err) {
          if (err) {
            reject(err);
          } else {
            resolve({ changes: this.changes });
          }
        }
      );
    });
  }

  static toSafeObject(vault) {
    if (!vault) return null;
    return {
      id: vault.id,
      user_id: vault.user_id,
      name: vault.name,
      encrypted_master_key: vault.encrypted_master_key,
      salt: vault.salt,
      created_at: vault.created_at,
      updated_at: vault.updated_at,
      last_accessed: vault.last_accessed,
      is_synced: vault.is_synced === 1,
    };
  }
}

module.exports = Vault;
