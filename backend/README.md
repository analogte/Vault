# Secure Vault Backend API

## 🚀 Quick Start

### Option 1: Node.js + Express (แนะนำ)
```bash
npm init -y
npm install express bcrypt jsonwebtoken pg dotenv cors
npm install -D nodemon typescript @types/node @types/express
```

### Option 2: Python + FastAPI
```bash
pip install fastapi uvicorn sqlalchemy psycopg2-binary python-jose bcrypt
```

## 📁 Structure

```
backend/
├── src/
│   ├── routes/
│   │   ├── auth.js          # Authentication routes
│   │   ├── vaults.js        # Vault routes
│   │   └── files.js          # File metadata routes
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── vaultController.js
│   │   └── fileController.js
│   ├── models/
│   │   ├── User.js
│   │   ├── Vault.js
│   │   └── File.js
│   ├── middleware/
│   │   └── auth.js          # JWT verification
│   ├── config/
│   │   └── database.js      # DB connection
│   └── utils/
│       └── jwt.js            # JWT helpers
├── .env
└── package.json
```

## 🔐 API Endpoints

### Authentication
- `POST /api/auth/register` - สมัครสมาชิก
- `POST /api/auth/login` - เข้าสู่ระบบ
- `POST /api/auth/refresh` - Refresh token
- `POST /api/auth/logout` - ออกจากระบบ

### Vaults
- `GET /api/vaults` - รายการ vaults
- `POST /api/vaults` - สร้าง vault
- `GET /api/vaults/:id` - ดู vault
- `PUT /api/vaults/:id` - แก้ไข vault
- `DELETE /api/vaults/:id` - ลบ vault

### Files (Metadata only)
- `GET /api/vaults/:id/files` - รายการไฟล์
- `POST /api/vaults/:id/files` - เพิ่มไฟล์ metadata
- `DELETE /api/files/:id` - ลบไฟล์ metadata
