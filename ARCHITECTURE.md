# สถาปัตยกรรมแอปเก็บไฟล์/รูปที่เข้ารหัส

## ภาพรวม (Overview)

แอปพลิเคชันสำหรับเก็บไฟล์และรูปภาพที่เข้ารหัสแบบ client-side encryption โดยใช้แนวคิดจาก Cryptomator แต่เขียนโค้ดเองทั้งหมด

## เทคโนโลยี Stack

### Frontend
- **Flutter** (Dart) - Cross-platform mobile app
  - เหมาะสำหรับ iOS และ Android
  - Performance ดี
  - UI/UX สวยงาม

### Backend/Storage
- **Local Storage** - เก็บไฟล์เข้ารหัสในเครื่อง
- **Cloud Sync** (Optional) - รองรับการซิงค์กับ cloud storage
  - Google Drive
  - iCloud
  - Dropbox
  - OneDrive

### Encryption Libraries
- **pointycastle** (Dart) - AES-256 encryption
- **crypto** (Dart) - Hashing, key derivation
- **scrypt** - Key derivation function

## สถาปัตยกรรมระบบ

### 1. Encryption Layer (ชั้นเข้ารหัส)

```
┌─────────────────────────────────────┐
│      User Files (Plaintext)         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Encryption Engine                 │
│   - AES-256-GCM                     │
│   - File name encryption            │
│   - Metadata encryption             │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Encrypted Files (Ciphertext)      │
│   - .encrypted extension            │
│   - Encrypted metadata              │
└─────────────────────────────────────┘
```

### 2. Key Management (การจัดการคีย์)

```
Master Password
       │
       ▼
┌─────────────────────────────────────┐
│   Key Derivation (scrypt)           │
│   - Salt (unique per vault)         │
│   - Iterations: 16384               │
│   - Key length: 256 bits            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   Master Key (256-bit)              │
│   - Stored encrypted in vault       │
│   - Never stored in plaintext       │
└─────────────────────────────────────┘
```

### 3. Vault Structure (โครงสร้าง Vault)

```
vault/
├── vault.cryptomator (metadata)
│   ├── vault version
│   ├── salt
│   ├── encrypted master key
│   └── vault config
├── d/
│   ├── 00/
│   │   ├── 00/
│   │   │   └── encrypted_file.encrypted
│   │   └── 01/
│   └── 01/
└── metadata/
    └── encrypted_metadata.json
```

### 4. File Encryption Process

1. **Upload File**
   - User selects file/image
   - Generate random IV (Initialization Vector)
   - Encrypt file content with AES-256-GCM
   - Encrypt file name
   - Store encrypted file in vault structure
   - Save metadata (encrypted)

2. **Download/View File**
   - User requests file
   - Decrypt file name to find encrypted file
   - Decrypt file content
   - Display/return plaintext file

3. **Delete File**
   - Remove encrypted file from vault
   - Update metadata
   - Secure delete (overwrite if possible)

## โครงสร้าง Database

### SQLite Database Schema

```sql
-- Vaults table
CREATE TABLE vaults (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    path TEXT NOT NULL UNIQUE,
    created_at INTEGER NOT NULL,
    last_accessed INTEGER,
    salt BLOB NOT NULL,
    encrypted_master_key BLOB NOT NULL
);

-- Files metadata table
CREATE TABLE files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vault_id INTEGER NOT NULL,
    encrypted_name TEXT NOT NULL,
    encrypted_path TEXT NOT NULL,
    file_type TEXT,
    size INTEGER,
    created_at INTEGER NOT NULL,
    modified_at INTEGER,
    thumbnail_path TEXT,
    FOREIGN KEY (vault_id) REFERENCES vaults(id)
);

-- Thumbnails table (for images)
CREATE TABLE thumbnails (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_id INTEGER NOT NULL,
    thumbnail_data BLOB,
    FOREIGN KEY (file_id) REFERENCES files(id)
);
```

## Security Features

### 1. Encryption
- **Algorithm**: AES-256-GCM (Galois/Counter Mode)
- **Key Size**: 256 bits
- **IV**: Random 96-bit IV per file
- **Authentication**: Built-in GCM authentication tag

### 2. Key Derivation
- **Function**: scrypt
- **Salt**: Random 256-bit salt per vault
- **Iterations**: 16384 (configurable)
- **Memory Cost**: 8 (configurable)
- **Parallelism**: 1

### 3. File Name Encryption
- Encrypt file names using AES-256
- Store encrypted names in database
- Directory structure obfuscation

### 4. Metadata Protection
- All metadata encrypted
- No plaintext file names in storage
- Secure deletion support

## Application Architecture

### Layer Structure

```
┌─────────────────────────────────────┐
│   Presentation Layer (UI)           │
│   - Screens, Widgets               │
│   - State Management (Provider)     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Business Logic Layer              │
│   - Services                        │
│   - Use Cases                       │
│   - View Models                     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Data Layer                        │
│   - Repositories                    │
│   - Data Sources                    │
│   - Database                        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Encryption Layer                  │
│   - Crypto Service                  │
│   - Key Manager                     │
│   - Vault Manager                   │
└─────────────────────────────────────┘
```

## Features

### Core Features
1. ✅ Create/Open Vault
2. ✅ Upload Files/Images
3. ✅ View Files/Images
4. ✅ Delete Files
5. ✅ Search Files
6. ✅ Gallery View
7. ✅ Thumbnail Generation

### Advanced Features (Future)
1. Cloud Sync
2. File Sharing
3. Biometric Authentication
4. Auto-lock
5. File Versioning
6. Backup/Restore

## Performance Considerations

1. **Thumbnail Caching**: Cache thumbnails for fast gallery view
2. **Lazy Loading**: Load files on demand
3. **Background Encryption**: Encrypt files in background thread
4. **Memory Management**: Clear sensitive data from memory ASAP
5. **File Streaming**: Stream large files instead of loading all at once

## Security Best Practices

1. ✅ Never store passwords in plaintext
2. ✅ Wipe sensitive data from memory
3. ✅ Use secure random number generators
4. ✅ Validate all inputs
5. ✅ Protect against timing attacks
6. ✅ Secure file deletion
7. ✅ No logging of sensitive data
