# Secure Vault Backend API

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Setup Environment
```bash
# Copy .env.example to .env (if not exists)
# Edit .env with your configuration
```

### 3. Run Server
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

## 📁 Project Structure

```
backend/
├── src/
│   ├── index.js              # Main server file
│   ├── config/
│   │   └── database.js      # Database configuration
│   ├── models/
│   │   └── User.js          # User model
│   ├── routes/
│   │   └── auth.js          # Authentication routes
│   └── middleware/
│       └── auth.js          # JWT verification middleware
├── data/                     # SQLite database (auto-created)
├── .env                      # Environment variables
└── package.json
```

## 🔐 API Endpoints

### Authentication
- `POST /api/auth/register` - สมัครสมาชิก
- `POST /api/auth/login` - เข้าสู่ระบบ

### Health Check
- `GET /api/health` - ตรวจสอบสถานะ server

## 🧪 Testing

ดู `API_TEST.md` สำหรับวิธีทดสอบ API

### Quick Test
```bash
# Health check
curl http://localhost:3000/api/health

# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"password123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## 📊 Database

### Development
- ใช้ SQLite (auto-created in `data/` folder)
- ไม่ต้อง setup database server

### Production
- ใช้ PostgreSQL (configure in `.env`)

## 🔧 Configuration

### Environment Variables (.env)
```env
PORT=3000
NODE_ENV=development
JWT_SECRET=your-secret-key
DB_TYPE=sqlite
DB_PATH=./data/secure_vault.db
```

## ✅ Features

- ✅ User Registration
- ✅ User Login
- ✅ JWT Authentication
- ✅ Password Hashing (bcrypt)
- ✅ SQLite Database
- ✅ CORS enabled
- ✅ Error handling

## 🚧 TODO

- [ ] Vault routes
- [ ] File metadata routes
- [ ] JWT refresh token
- [ ] Password reset
- [ ] Email verification
- [ ] Rate limiting
- [ ] Input validation middleware
