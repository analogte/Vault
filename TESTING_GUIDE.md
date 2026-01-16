# 🧪 คู่มือทดสอบระบบ Secure Vault

## ✅ ระบบพร้อมทดสอบแล้ว!

### สิ่งที่ทำเสร็จทั้งหมด:
- ✅ Backend API (Authentication + Vault CRUD)
- ✅ Mobile App (Login/Register + Vault Management + File Management)
- ✅ Vault Sync กับ Backend
- ✅ Logout Functionality

## 🚀 วิธีเริ่มต้น

### Step 1: Start Backend
```bash
cd backend
npm run dev
```

**ตรวจสอบว่า server รัน:**
```bash
curl http://localhost:3000/api/health
```

ควรได้: `{"status":"ok","message":"Secure Vault API is running"}`

### Step 2: Start Mobile App
```bash
cd secure_vault
flutter run
```

**เลือก platform:**
- `flutter run -d chrome` (Web)
- `flutter run -d macos` (macOS)
- `flutter run -d android` (Android)
- `flutter run -d ios` (iOS)

## 📋 Testing Scenarios

### Scenario 1: สมัครสมาชิกใหม่

1. เปิดแอป → จะเห็น Splash Screen
2. ไปที่ Login Screen
3. กด "สมัครสมาชิก"
4. กรอกข้อมูล:
   - Email: `user1@test.com`
   - Username: `user1` (optional)
   - Password: `password123`
   - Confirm Password: `password123`
5. กด "สมัครสมาชิก"
6. ✅ ควรไปที่ VaultListScreen

### Scenario 2: เข้าสู่ระบบ

1. เปิดแอป (ถ้ายังไม่ login)
2. กรอก:
   - Email: `user1@test.com`
   - Password: `password123`
3. กด "เข้าสู่ระบบ"
4. ✅ ควรไปที่ VaultListScreen

### Scenario 3: สร้าง Vault

1. ใน VaultListScreen
2. กดปุ่ม "สร้าง Vault"
3. กรอกข้อมูล:
   - ชื่อ Vault: `My Photos`
   - รหัสผ่าน: `vaultpass123`
   - ยืนยันรหัสผ่าน: `vaultpass123`
4. กด "สร้าง Vault"
5. ✅ ควรสร้าง vault และ sync กับ backend
6. ✅ ควรไปที่ OpenVaultScreen

### Scenario 4: เปิด Vault

1. ใน VaultListScreen
2. กดที่ Vault "My Photos"
3. กรอกรหัสผ่าน: `vaultpass123`
4. กด "เปิด Vault"
5. ✅ ควรไปที่ FileManagerScreen

### Scenario 5: อัปโหลดไฟล์

1. ใน FileManagerScreen
2. กดปุ่ม + (เลือกรูปภาพ) หรือ 📎 (เลือกไฟล์)
3. เลือกไฟล์/รูปภาพ
4. ✅ ไฟล์ควรถูกเข้ารหัสและเก็บในเครื่อง
5. ✅ ควรเห็นในรายการไฟล์

### Scenario 6: ดูแกลเลอรี

1. ใน FileManagerScreen
2. กด Tab "แกลเลอรี"
3. ✅ ควรเห็นรูปภาพทั้งหมดในรูปแบบ masonry grid
4. กดที่รูปภาพ
5. ✅ ควรเปิด Image Viewer แบบเต็มหน้าจอ
6. ✅ สามารถ zoom ได้ (pinch to zoom)

### Scenario 7: ลบไฟล์

1. ใน FileManagerScreen
2. Tab "ไฟล์ทั้งหมด"
3. กดที่ไฟล์ → เลือก "ลบ" จากเมนู
4. ยืนยันการลบ
5. ✅ ไฟล์ควรถูกลบ

### Scenario 8: ลบ Vault

1. ใน VaultListScreen
2. กดที่ Vault → เลือก "ลบ" จากเมนู
3. ยืนยันการลบ
4. ✅ Vault ควรถูกลบ (ทั้ง local และ backend)

### Scenario 9: Logout

1. ใน VaultListScreen
2. กดที่เมนู (3 dots) มุมขวาบน
3. เลือก "ออกจากระบบ"
4. ยืนยัน
5. ✅ ควรกลับไปที่ Login Screen

### Scenario 10: Auto-login

1. Login เข้าแอป
2. ปิดแอป
3. เปิดแอปใหม่
4. ✅ ควร auto-login และไปที่ VaultListScreen ทันที

## 🔍 ตรวจสอบ Backend

### ตรวจสอบ Users
```bash
# ดู users ใน database
sqlite3 backend/data/secure_vault.db "SELECT id, email, username FROM users;"
```

### ตรวจสอบ Vaults
```bash
# ดู vaults ใน database
sqlite3 backend/data/secure_vault.db "SELECT id, user_id, name, created_at FROM vaults;"
```

### Test API ด้วย cURL

#### Register
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"password123"}'
```

#### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

#### Get Vaults (ต้องมี token)
```bash
# ใช้ token จาก login response
curl -X GET http://localhost:3000/api/vaults \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## ⚠️ Troubleshooting

### Backend ไม่รัน
```bash
# ตรวจสอบว่า port 3000 ว่าง
lsof -i :3000

# Kill process ถ้าจำเป็น
kill -9 <PID>
```

### Mobile App ไม่เชื่อมต่อ Backend
1. ตรวจสอบ baseUrl ใน `lib/main.dart`
2. สำหรับ Android Emulator: ใช้ `http://10.0.2.2:3000`
3. สำหรับ Real Device: ใช้ IP address ของคอมพิวเตอร์
4. ตรวจสอบ firewall settings

### Vault ไม่ sync
1. ตรวจสอบว่า login แล้ว
2. ตรวจสอบ backend logs
3. ตรวจสอบ network connection

### Files ไม่แสดง
1. ตรวจสอบ permissions
2. ตรวจสอบว่า vault เปิดอยู่
3. ตรวจสอบ database

## ✅ Expected Results

### Backend
- ✅ Server รันที่ port 3000
- ✅ Database สร้างอัตโนมัติ
- ✅ API endpoints ทำงานได้

### Mobile App
- ✅ Login/Register ทำงาน
- ✅ Vault สร้างและ sync ได้
- ✅ ไฟล์เข้ารหัสและเก็บได้
- ✅ Gallery view ทำงาน
- ✅ Logout ทำงาน

## 🎯 Success Criteria

ระบบจะถือว่าทำงานได้ถ้า:
1. ✅ Register/Login สำเร็จ
2. ✅ สร้าง Vault ได้
3. ✅ เปิด Vault ด้วยรหัสผ่านได้
4. ✅ อัปโหลดไฟล์ได้
5. ✅ ดูไฟล์/รูปภาพได้
6. ✅ ลบไฟล์ได้
7. ✅ Logout ได้
8. ✅ Auto-login ทำงาน

## 🎉 พร้อมทดสอบแล้ว!

ลองทดสอบตาม scenarios ด้านบนได้เลย!
