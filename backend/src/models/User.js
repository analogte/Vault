const { getDatabase } = require('../config/database');
const { v4: uuidv4 } = require('uuid');

class User {
  static async findByEmail(email) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      db.get(
        'SELECT * FROM users WHERE email = ?',
        [email],
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

  static async findById(id) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      db.get(
        'SELECT * FROM users WHERE id = ?',
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

  static async create({ email, username, passwordHash }) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      const id = uuidv4();
      const now = new Date().toISOString();

      db.run(
        `INSERT INTO users (id, email, username, password_hash, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [id, email, username || null, passwordHash, now, now],
        function(err) {
          if (err) {
            reject(err);
          } else {
            // Get the created user
            db.get(
              'SELECT * FROM users WHERE id = ?',
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

  static async updateLastLogin(userId) {
    return new Promise((resolve, reject) => {
      const db = getDatabase();
      const now = new Date().toISOString();

      db.run(
        'UPDATE users SET last_login = ?, updated_at = ? WHERE id = ?',
        [now, now, userId],
        (err) => {
          if (err) {
            reject(err);
          } else {
            resolve();
          }
        }
      );
    });
  }

  static toSafeObject(user) {
    if (!user) return null;
    // SQLite returns snake_case, convert to camelCase
    const safeUser = {
      id: user.id,
      email: user.email,
      username: user.username,
      created_at: user.created_at,
      updated_at: user.updated_at,
      last_login: user.last_login,
      is_active: user.is_active === 1,
    };
    return safeUser;
  }
}

module.exports = User;
