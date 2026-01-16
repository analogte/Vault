# API Testing Guide

## 🚀 Server Endpoints

### Base URL
```
http://localhost:3000/api
```

## 📋 Endpoints

### 1. Health Check
```bash
GET /api/health
```

**Response:**
```json
{
  "status": "ok",
  "message": "Secure Vault API is running"
}
```

### 2. Register (สมัครสมาชิก)
```bash
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "username",
  "password": "password123"
}
```

**Response (Success):**
```json
{
  "message": "User created successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "username",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**Response (Error):**
```json
{
  "error": "User already exists"
}
```

### 3. Login (เข้าสู่ระบบ)
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Success):**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "username",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

**Response (Error):**
```json
{
  "error": "Invalid credentials"
}
```

## 🧪 Testing with cURL

### Health Check
```bash
curl http://localhost:3000/api/health
```

### Register
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "password123"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## 🧪 Testing with Postman

1. **Health Check**
   - Method: GET
   - URL: `http://localhost:3000/api/health`

2. **Register**
   - Method: POST
   - URL: `http://localhost:3000/api/auth/register`
   - Headers: `Content-Type: application/json`
   - Body (raw JSON):
     ```json
     {
       "email": "test@example.com",
       "username": "testuser",
       "password": "password123"
     }
     ```

3. **Login**
   - Method: POST
   - URL: `http://localhost:3000/api/auth/login`
   - Headers: `Content-Type: application/json`
   - Body (raw JSON):
     ```json
     {
       "email": "test@example.com",
       "password": "password123"
     }
     ```

## ✅ Expected Results

1. **Register** → ควรได้ token และ user data
2. **Login** → ควรได้ token และ user data
3. **Register ซ้ำ** → ควรได้ error "User already exists"
4. **Login ผิด password** → ควรได้ error "Invalid credentials"
