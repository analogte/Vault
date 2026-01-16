# สถาปัตยกรรมระบบ Secure Vault

## 🤔 คำถามสำคัญ

### 1. ระบบสมัครใช้งาน
**คำตอบ**: ใช่ ควรมีระบบสมัครสมาชิกและเข้าสู่ระบบ

### 2. ระบบหลังบ้าน
**คำตอบ**: ต้องมี Backend API สำหรับ:
- จัดการผู้ใช้ (User Management)
- Authentication & Authorization
- Vault metadata sync (ถ้าต้องการ sync หลายอุปกรณ์)
- File metadata (ไม่ใช่ไฟล์จริง)

### 3. เก็บไฟล์
**คำตอบ**: **Hybrid Approach** (แนะนำ)
- **ไฟล์จริง**: เก็บในเครื่อง (Local Storage) - เข้ารหัสแล้ว
- **Metadata**: Sync กับ Cloud (Backend)
- **Cloud Backup**: Optional - ผู้ใช้เลือกได้

## 🏗️ สถาปัตยกรรมที่แนะนำ

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Mobile App (Flutter)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Auth        │  │  Vault        │  │  File        │ │
│  │  Module      │  │  Manager      │  │  Manager     │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
└─────────┼──────────────────┼──────────────────┼─────────┘
          │                  │                  │
          │ HTTPS           │ HTTPS            │
          │                  │                  │
┌─────────▼──────────────────▼──────────────────▼─────────┐
│              Backend API (Node.js/FastAPI)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Auth        │  │  Vault       │  │  File        │ │
│  │  Service     │  │  Service     │  │  Metadata    │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
└─────────┼──────────────────┼──────────────────┼─────────┘
          │                  │                  │
          │                  │                  │
┌─────────▼──────────────────▼──────────────────▼─────────┐
│                    Database (PostgreSQL/MongoDB)        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  Users       │  │  Vaults      │  │  Files       │ │
│  │  Table       │  │  Table       │  │  Metadata    │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              Local Storage (Device)                     │
│  ┌──────────────┐  ┌──────────────┐                    │
│  │  Encrypted   │  │  SQLite      │                    │
│  │  Files       │  │  (Cache)     │                    │
│  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│         Optional: Cloud Storage (S3/Google Cloud)       │
│  ┌──────────────┐                                      │
│  │  Encrypted   │  (Backup only, user choice)          │
│  │  Files       │                                      │
│  └──────────────┘                                      │
└─────────────────────────────────────────────────────────┘
```

## 📋 แนวทางที่แนะนำ

### Option 1: Local-First with Cloud Sync (แนะนำ) ⭐

**หลักการ**:
- ไฟล์จริงเก็บในเครื่อง (Local) - เข้ารหัสแล้ว
- Metadata sync กับ Cloud (Backend)
- Cloud backup เป็น optional

**ข้อดี**:
- ✅ เร็ว - ไม่ต้อง upload/download ไฟล์ทุกครั้ง
- ✅ ทำงาน offline ได้
- ✅ Privacy - ไฟล์ไม่ขึ้น cloud (ถ้าไม่ backup)
- ✅ ประหยัด bandwidth
- ✅ ประหยัด storage cost

**ข้อเสีย**:
- ❌ Sync หลายอุปกรณ์ต้อง backup เอง
- ❌ ถ้าเครื่องเสียอาจสูญหาย (ถ้าไม่ backup)

### Option 2: Full Cloud Storage

**หลักการ**:
- ไฟล์ทั้งหมดเก็บใน Cloud
- เข้ารหัสก่อน upload
- Download เมื่อต้องการดู

**ข้อดี**:
- ✅ Sync หลายอุปกรณ์อัตโนมัติ
- ✅ Backup อัตโนมัติ
- ✅ ไม่กลัวเครื่องเสีย

**ข้อเสีย**:
- ❌ ต้องมี internet
- ❌ ใช้ bandwidth เยอะ
- ❌ ใช้ storage cost เยอะ
- ❌ ช้ากว่า (ต้อง download)

### Option 3: Hybrid (แนะนำที่สุด) ⭐⭐⭐

**หลักการ**:
- ไฟล์เก็บในเครื่อง (Local) - default
- Metadata sync กับ Cloud
- Cloud backup เป็น optional (ผู้ใช้เลือกได้)

**ข้อดี**:
- ✅ เร็ว (local-first)
- ✅ ทำงาน offline ได้
- ✅ Sync metadata หลายอุปกรณ์
- ✅ Optional backup
- ✅ Privacy (ไฟล์ไม่ขึ้น cloud ถ้าไม่ backup)

## 🔐 ระบบ Authentication

### Flow

```
1. สมัครสมาชิก
   User → App → Backend API
   - Email/Username
   - Password (hashed with bcrypt)
   - Create user account

2. เข้าสู่ระบบ
   User → App → Backend API
   - Email/Username + Password
   - Verify password
   - Return JWT token

3. ใช้งานแอป
   App → Backend API (with JWT)
   - Store JWT in secure storage
   - Include JWT in API requests
   - Backend verify JWT

4. Vault Management
   - Create vault (metadata → Backend)
   - List vaults (from Backend)
   - Vault files (Local + Metadata sync)
```

### Security

- **Password**: Hash with bcrypt (ไม่เก็บ plaintext)
- **JWT**: สำหรับ authentication
- **HTTPS**: ทุก API calls
- **Token Refresh**: Refresh token mechanism

## 💾 Database Schema

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);
```

### Vaults Table
```sql
CREATE TABLE vaults (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    encrypted_master_key TEXT NOT NULL, -- Encrypted with user's key
    salt BYTEA NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_accessed TIMESTAMP,
    is_synced BOOLEAN DEFAULT FALSE
);
```

### Files Metadata Table
```sql
CREATE TABLE files_metadata (
    id UUID PRIMARY KEY,
    vault_id UUID REFERENCES vaults(id),
    encrypted_name TEXT NOT NULL,
    file_type VARCHAR(50),
    size BIGINT,
    encrypted_path TEXT, -- Local path on device
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    device_id VARCHAR(255), -- Which device this file is on
    is_backed_up BOOLEAN DEFAULT FALSE -- If backed up to cloud
);
```

## 🚀 Backend API Endpoints

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/refresh
POST /api/auth/logout
```

### Vaults
```
GET    /api/vaults              # List user's vaults
POST   /api/vaults              # Create vault
GET    /api/vaults/:id          # Get vault details
PUT    /api/vaults/:id          # Update vault
DELETE /api/vaults/:id          # Delete vault
POST   /api/vaults/:id/sync     # Sync vault metadata
```

### Files
```
GET    /api/vaults/:id/files    # List files metadata
POST   /api/vaults/:id/files    # Add file metadata
DELETE /api/files/:id           # Delete file metadata
POST   /api/files/:id/backup    # Backup file to cloud (optional)
```

## 📱 Mobile App Changes

### ต้องเพิ่ม:

1. **Auth Module**
   - Login Screen
   - Register Screen
   - JWT storage (flutter_secure_storage)
   - API client with JWT

2. **Backend Integration**
   - API service
   - Sync service
   - Error handling

3. **Storage Strategy**
   - Local storage (default)
   - Cloud backup (optional)
   - Sync metadata

## 🎯 Implementation Plan

### Phase 1: Authentication
1. สร้าง Backend API (Node.js/FastAPI)
2. User registration/login
3. JWT authentication
4. Mobile app integration

### Phase 2: Vault Sync
1. Vault metadata sync
2. Multi-device support
3. Conflict resolution

### Phase 3: Optional Cloud Backup
1. Cloud storage integration (S3/Google Cloud)
2. Backup/restore functionality
3. User choice (local/cloud/hybrid)

## 💡 คำแนะนำ

### สำหรับ MVP (Minimum Viable Product):
1. ✅ Local storage only (ไม่ต้อง backend)
2. ✅ ทำงาน offline ได้
3. ✅ เร็วและง่าย

### สำหรับ Production:
1. ✅ Backend API สำหรับ auth
2. ✅ Metadata sync
3. ✅ Optional cloud backup

### สำหรับ Scale:
1. ✅ Full cloud storage option
2. ✅ Multi-device sync
3. ✅ Advanced features

## 🔧 Technology Stack

### Backend Options:

**Option 1: Node.js + Express**
- ✅ JavaScript/TypeScript
- ✅ Fast development
- ✅ Large ecosystem

**Option 2: Python + FastAPI**
- ✅ Fast
- ✅ Modern
- ✅ Good for ML/AI (future)

**Option 3: Go + Gin**
- ✅ Fast
- ✅ Low memory
- ✅ Good for scale

### Database:
- **PostgreSQL** - สำหรับ production
- **MongoDB** - สำหรับ flexible schema
- **SQLite** - สำหรับ development

### Cloud Storage (Optional):
- **AWS S3**
- **Google Cloud Storage**
- **Azure Blob Storage**
