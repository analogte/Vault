# 🔐 Setup GitHub Secrets for CI/CD

เพื่อให้ GitHub Actions build APK ที่ signed ได้ คุณต้องตั้งค่า Secrets

---

## 📋 Secrets ที่ต้องสร้าง

ไปที่: **GitHub repo → Settings → Secrets and variables → Actions → New repository secret**

### 1. KEYSTORE_BASE64

**Value**: Keystore ที่ encode เป็น base64

วิธีสร้าง:
```bash
# macOS/Linux
base64 -i ~/Desktop/Backup-Mac-20260118/project\ เก็บรูปไฟล์\ นิรภัย/secure_vault/android/upload-keystore.jks | pbcopy

# หรือ
base64 ~/Desktop/Backup-Mac-20260118/project\ เก็บรูปไฟล์\ นิรภัย/secure_vault/android/upload-keystore.jks > keystore.txt
# แล้ว copy เนื้อหาจาก keystore.txt
```

จากนั้น paste ค่าที่ได้ลงใน Secret

---

### 2. KEYSTORE_PASSWORD

**Value**: `securevault2026`

---

### 3. KEY_PASSWORD

**Value**: `securevault2026`

---

### 4. KEY_ALIAS

**Value**: `upload`

---

## ✅ ตรวจสอบ Secrets

หลังจากสร้างครบแล้ว คุณควรมี 4 secrets:

- ✅ KEYSTORE_BASE64
- ✅ KEYSTORE_PASSWORD
- ✅ KEY_PASSWORD
- ✅ KEY_ALIAS

---

## 🚀 วิธีใช้งาน GitHub Actions

### 1. Build APK (Debug) - อัตโนมัติ

```bash
# Push code ขึ้น GitHub
git add .
git commit -m "Update code"
git push origin main

# GitHub Actions จะ build APK debug ให้อัตโนมัติ
# ดูผลได้ที่: Actions tab → Build APK workflow
# Download APK ได้จาก Artifacts
```

### 2. Release APK (Signed) - ใช้ Tag

```bash
# สร้าง tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# GitHub Actions จะ:
# 1. Build APK + AAB (signed)
# 2. สร้าง GitHub Release
# 3. อัปโหลด APK/AAB ไปที่ Release

# ดูได้ที่: Releases → Latest release
```

### 3. Manual Trigger

ไปที่: **Actions → Release APK → Run workflow**

---

## 📦 ไฟล์ที่จะได้

### จาก Build APK workflow:
- `app-debug.apk` (Artifacts, เก็บไว้ 7 วัน)

### จาก Release workflow:
- `app-release.apk` (สำหรับแจกจ่าย)
- `app-release.aab` (สำหรับ Play Store)

---

## 🔒 Security Best Practices

1. ✅ **อย่าแชร์ Secrets** - GitHub Secrets ปลอดภัย ไม่แสดงใน logs
2. ✅ **Backup Keystore** - เก็บ keystore ไว้ปลอดภัย
3. ✅ **ใช้ Branch Protection** - ป้องกันการ push ตรงไปที่ main
4. ✅ **Review Changes** - ตรวจสอบโค้ดก่อน merge

---

## 🐛 Troubleshooting

### Workflow ล้มเหลว

**ปัญหา**: Build failed
**วิธีแก้**: เช็ค logs ที่ Actions tab

**ปัญหา**: Keystore error
**วิธีแก้**: ตรวจสอบ Secrets ว่าถูกต้อง

**ปัญหา**: Flutter version
**วิธีแก้**: อัปเดต `flutter-version` ใน workflow

---

## 📚 เอกสารเพิ่มเติม

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Signing Android Apps](https://docs.flutter.dev/deployment/android#signing-the-app)

---

**Created**: 2026-01-20
