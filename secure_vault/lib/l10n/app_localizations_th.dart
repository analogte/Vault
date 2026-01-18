// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class STh extends S {
  STh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'Secure Vault';

  @override
  String get appTagline => 'เก็บไฟล์ของคุณอย่างปลอดภัย';

  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get securityCheck => 'ตรวจสอบความปลอดภัย...';

  @override
  String get enterPin => 'กรุณาใส่รหัส PIN';

  @override
  String get enteringApp => 'กำลังเข้าสู่แอป...';

  @override
  String get version => 'เวอร์ชัน';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get security => 'ความปลอดภัย';

  @override
  String get data => 'ข้อมูล';

  @override
  String get about => 'เกี่ยวกับ';

  @override
  String get account => 'บัญชี';

  @override
  String biometricUnlock(String type) {
    return 'ปลดล็อคด้วย $type';
  }

  @override
  String get biometricSubtitle => 'ใช้ลายนิ้วมือหรือ Face ID เพื่อเปิด Vault';

  @override
  String get autoLock => 'ล็อคอัตโนมัติ';

  @override
  String autoLockEnabled(String time) {
    return 'ล็อค Vault หลังจากไม่ใช้งาน $time';
  }

  @override
  String get autoLockDisabled => 'ปิดใช้งาน';

  @override
  String get lockTimeout => 'ระยะเวลาล็อค';

  @override
  String get selectAutoLockTimeout => 'เลือกระยะเวลาล็อคอัตโนมัติ';

  @override
  String get lockOnBackground => 'ล็อคเมื่อออกจากแอป';

  @override
  String get lockOnBackgroundSubtitle =>
      'ล็อค Vault ทันทีเมื่อสลับไปใช้แอปอื่น';

  @override
  String get screenshotPrevention => 'ป้องกันการ Screenshot';

  @override
  String get screenshotPreventionSubtitle => 'ป้องกันการจับภาพหน้าจอในแอป';

  @override
  String get restartRequired => 'การเปลี่ยนแปลงจะมีผลหลังจากรีสตาร์ทแอป';

  @override
  String get clipboardAutoClear => 'ล้าง Clipboard อัตโนมัติ';

  @override
  String clipboardAutoClearEnabled(int seconds) {
    return 'ล้าง Clipboard หลังคัดลอก $seconds วินาที';
  }

  @override
  String get clipboardTimeout => 'ระยะเวลาล้าง Clipboard';

  @override
  String get selectClipboardTimeout => 'เลือกระยะเวลาล้าง Clipboard';

  @override
  String get securityStatus => 'สถานะความปลอดภัย';

  @override
  String get deviceStatus => 'สถานะอุปกรณ์';

  @override
  String get deviceSecure => 'อุปกรณ์ปลอดภัย';

  @override
  String get deviceRooted => 'อุปกรณ์ถูก Root/Jailbreak';

  @override
  String get developerModeEnabled => 'Developer Mode เปิดอยู่';

  @override
  String get securityDetails => 'รายละเอียดความปลอดภัย';

  @override
  String get appIntegrity => 'ความสมบูรณ์ของแอป';

  @override
  String get appIntegritySafe => 'แอปทำงานในสภาพแวดล้อมปลอดภัย';

  @override
  String appIntegrityWarnings(int count) {
    return 'พบ $count คำเตือน';
  }

  @override
  String get rootJailbreak => 'Root/Jailbreak';

  @override
  String get developerMode => 'Developer Mode';

  @override
  String get emulator => 'Emulator';

  @override
  String get externalStorage => 'แอปติดตั้งบน External Storage';

  @override
  String get debugMode => 'Debug Mode';

  @override
  String get detected => 'พบ';

  @override
  String get notDetected => 'ไม่พบ';

  @override
  String get warnings => 'คำเตือน';

  @override
  String get trash => 'ถังขยะ';

  @override
  String get trashSubtitle => 'ดูและกู้คืนไฟล์ที่ลบ';

  @override
  String get backup => 'สำรองข้อมูล';

  @override
  String get backupSubtitle => 'Export/Import ข้อมูลทั้งหมด';

  @override
  String get versionInfo => 'เวอร์ชัน';

  @override
  String get securityFeatures => 'ฟีเจอร์ความปลอดภัย';

  @override
  String get securityFeaturesSubtitle => 'AES-256-GCM + Argon2id (หรือ PBKDF2)';

  @override
  String get privacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get privacyPolicySubtitle =>
      'ข้อมูลถูกเข้ารหัสและเก็บในเครื่องของคุณเท่านั้น';

  @override
  String get appLockSettings => 'ตั้งค่าการล็อคแอป';

  @override
  String get pinEnabled => 'เปิดใช้งาน PIN แล้ว';

  @override
  String get pinNotSet => 'ยังไม่ได้ตั้งค่า PIN';

  @override
  String get lockAppNow => 'ล็อคแอปตอนนี้';

  @override
  String get lockAppNowSubtitle => 'ล็อคแอปและแสดงหน้า PIN';

  @override
  String get encryption => 'การเข้ารหัส';

  @override
  String get encryptionAES => 'AES-256-GCM (มาตรฐานทหาร)';

  @override
  String get encryptionArgon2 =>
      'Argon2id Key Derivation (ทนทานต่อ GPU attack)';

  @override
  String get encryptionPBKDF2 =>
      'PBKDF2 100,000 iterations (สำหรับ vault เก่า)';

  @override
  String get protection => 'การป้องกัน';

  @override
  String get protectionRoot => 'ตรวจจับ Root/Jailbreak';

  @override
  String get protectionEmulator => 'ตรวจจับ Emulator และ Debug mode';

  @override
  String get protectionScreenshot => 'ป้องกันการ Screenshot';

  @override
  String get protectionClipboard => 'ล้าง Clipboard อัตโนมัติ';

  @override
  String get protectionBackground => 'ล็อคเมื่อออกจากแอป';

  @override
  String get storage => 'การจัดเก็บ';

  @override
  String get storageKeystore => 'Hardware Keystore (Android/iOS)';

  @override
  String get storageEncrypted => 'Encrypted Shared Preferences';

  @override
  String get storageNoServer => 'ไม่ส่งข้อมูลไปยัง server';

  @override
  String get specialFeatures => 'ฟีเจอร์พิเศษ';

  @override
  String get featureSecureKeyboard => 'Secure Keyboard (ไม่บันทึกการพิมพ์)';

  @override
  String get featureDecoyVault => 'Decoy Vault (vault ปลอม)';

  @override
  String get featureObfuscation => 'Code Obfuscation';

  @override
  String get privacyTitle => 'ความเป็นส่วนตัว';

  @override
  String get privacyInfo1 => 'ไฟล์ทั้งหมดถูกเข้ารหัสด้วย AES-256-GCM';

  @override
  String get privacyInfo2 => 'รหัสผ่านถูกประมวลผลด้วย PBKDF2 100,000 รอบ';

  @override
  String get privacyInfo3 => 'ข้อมูลทั้งหมดเก็บในเครื่องของคุณเท่านั้น';

  @override
  String get privacyInfo4 => 'ไม่มีการส่งข้อมูลไปยัง server';

  @override
  String get privacyInfo5 => 'ไม่มีการติดตามหรือวิเคราะห์พฤติกรรม';

  @override
  String get privacyInfo6 => 'ไม่มีโฆษณา';

  @override
  String get privacyWarning => 'หากลืมรหัสผ่าน จะไม่สามารถกู้คืนข้อมูลได้';

  @override
  String get understood => 'เข้าใจแล้ว';

  @override
  String get securityWarning => 'คำเตือนความปลอดภัย';

  @override
  String get unsafeEnvironment => 'ตรวจพบสภาพแวดล้อมที่อาจไม่ปลอดภัย:';

  @override
  String get appStillUsable =>
      'แอปยังสามารถใช้งานได้ แต่ข้อมูลอาจมีความเสี่ยง\nแนะนำให้ใช้งานบนอุปกรณ์ที่ไม่ได้ Root/Jailbreak';

  @override
  String get exitApp => 'ออกจากแอป';

  @override
  String get continueAnyway => 'ดำเนินการต่อ';

  @override
  String seconds(int count) {
    return '$count วินาที';
  }

  @override
  String minutes(int count) {
    return '$count นาที';
  }

  @override
  String hours(int count) {
    return '$count ชั่วโมง';
  }

  @override
  String get close => 'ปิด';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get ok => 'ตกลง';

  @override
  String get save => 'บันทึก';

  @override
  String get delete => 'ลบ';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get share => 'แชร์';

  @override
  String get restore => 'กู้คืน';

  @override
  String get pinLock => 'ล็อค PIN';

  @override
  String get enterPinToUnlock => 'ใส่ PIN เพื่อปลดล็อค';

  @override
  String get enterCurrentPin => 'ใส่ PIN ปัจจุบัน';

  @override
  String get enterNewPin => 'ใส่ PIN ใหม่';

  @override
  String get confirmNewPin => 'ยืนยัน PIN ใหม่';

  @override
  String get createPin => 'สร้าง PIN';

  @override
  String get changePin => 'เปลี่ยน PIN';

  @override
  String get wrongPin => 'PIN ไม่ถูกต้อง';

  @override
  String get pinMismatch => 'PIN ไม่ตรงกัน';

  @override
  String get pinChanged => 'เปลี่ยน PIN สำเร็จ';

  @override
  String get pinCreated => 'สร้าง PIN สำเร็จ';

  @override
  String get forgotPin => 'ลืม PIN?';

  @override
  String useBiometric(String type) {
    return 'ใช้ $type';
  }

  @override
  String attemptsRemaining(int count) {
    return 'เหลืออีก $count ครั้ง';
  }

  @override
  String get tooManyAttempts => 'ลองผิดมากเกินไป';

  @override
  String tryAgainIn(int seconds) {
    return 'ลองใหม่ใน $seconds วินาที';
  }

  @override
  String get enableAppLock => 'เปิดใช้งานล็อคแอป';

  @override
  String get enableAppLockSubtitle => 'ต้องใส่ PIN เมื่อเปิดแอป';

  @override
  String get biometricForAppLock => 'ไบโอเมตริกสำหรับล็อคแอป';

  @override
  String biometricForAppLockSubtitle(String type) {
    return 'ใช้ $type แทน PIN';
  }

  @override
  String get autoLockTimeout => 'ระยะเวลาล็อคอัตโนมัติ';

  @override
  String lockAfterBackground(String time) {
    return 'ล็อคหลังจากอยู่ในพื้นหลัง $time';
  }

  @override
  String get immediately => 'ทันที';

  @override
  String get setupPin => 'ตั้งค่า PIN';

  @override
  String get resetPin => 'รีเซ็ต PIN';

  @override
  String get setPinFirst => 'กรุณาตั้งค่า PIN ก่อน';

  @override
  String get backupTitle => 'สำรองข้อมูล';

  @override
  String get backupInfo => 'เกี่ยวกับการสำรองข้อมูล';

  @override
  String get backupInfo1 => 'ไฟล์ Backup จะรวม Vaults, Folders และไฟล์ทั้งหมด';

  @override
  String get backupInfo2 => 'ไฟล์ยังคงเข้ารหัสอยู่ ปลอดภัยแม้แชร์ไป Cloud';

  @override
  String get backupInfo3 => 'สามารถตั้งรหัสผ่านเพิ่มเติมเพื่อความปลอดภัย';

  @override
  String get backupInfo4 => 'แนะนำให้สำรองข้อมูลเป็นประจำ';

  @override
  String get createBackup => 'สร้าง Backup';

  @override
  String get setBackupPassword => 'ตั้งรหัสผ่าน Backup';

  @override
  String get setBackupPasswordSubtitle =>
      'เข้ารหัสไฟล์ backup ด้วยรหัสผ่านเพิ่มเติม';

  @override
  String get password => 'รหัสผ่าน';

  @override
  String get enterBackupPassword => 'ใส่รหัสผ่านสำหรับ backup';

  @override
  String get creating => 'กำลังสร้าง...';

  @override
  String get restoreFromBackup => 'กู้คืนจาก Backup';

  @override
  String get selectBackupFile => 'เลือกไฟล์ .svbackup เพื่อกู้คืน';

  @override
  String get duplicateVaultWarning =>
      'หาก Vault ที่กู้คืนมีชื่อซ้ำกับที่มีอยู่ ระบบจะข้ามการกู้คืน vault นั้น';

  @override
  String get selectBackupFileButton => 'เลือกไฟล์ Backup';

  @override
  String get restoring => 'กำลังกู้คืน...';

  @override
  String get backupCreatedSuccess => 'สร้าง Backup สำเร็จ!';

  @override
  String get vaults => 'Vaults';

  @override
  String get files => 'ไฟล์';

  @override
  String get folders => 'โฟลเดอร์';

  @override
  String get fileSize => 'ขนาดไฟล์';

  @override
  String get selectSaveMethod => 'เลือกวิธีบันทึกไฟล์ backup:';

  @override
  String get restoreSuccess => 'กู้คืนสำเร็จ!';

  @override
  String get vaultsRestored => 'Vaults ที่กู้คืน';

  @override
  String get filesRestored => 'ไฟล์ที่กู้คืน';

  @override
  String get foldersRestored => 'โฟลเดอร์ที่กู้คืน';

  @override
  String get enterBackupPasswordPrompt => 'ใส่รหัสผ่าน Backup';

  @override
  String get backupInfoTitle => 'ข้อมูล Backup';

  @override
  String get createdAt => 'สร้างเมื่อ';

  @override
  String get device => 'อุปกรณ์';

  @override
  String get vaultCount => 'จำนวน Vault';

  @override
  String get fileCount => 'จำนวนไฟล์';

  @override
  String get folderCount => 'จำนวนโฟลเดอร์';

  @override
  String get passwordProtected => 'รหัสผ่าน';

  @override
  String get yes => 'มี';

  @override
  String get no => 'ไม่มี';

  @override
  String get duplicateSkipped => 'Vault ที่มีชื่อซ้ำจะถูกข้าม';

  @override
  String get noVaultsToBackup => 'ไม่มี Vault ที่จะ backup';

  @override
  String get backupFailed => 'การสร้าง backup ล้มเหลว';

  @override
  String get fileNotFound => 'ไม่พบไฟล์ backup';

  @override
  String get wrongPasswordOrCorrupt => 'รหัสผ่านไม่ถูกต้องหรือไฟล์เสียหาย';

  @override
  String get backupCorruptOrNeedsPassword =>
      'ไฟล์ backup เสียหายหรือต้องใส่รหัสผ่าน';

  @override
  String get invalidBackupNoMetadata =>
      'ไฟล์ backup ไม่ถูกต้อง (ไม่พบ metadata)';

  @override
  String get invalidBackupNoVaults =>
      'ไฟล์ backup ไม่ถูกต้อง (ไม่พบข้อมูล vaults)';

  @override
  String get invalidBackupNoFiles =>
      'ไฟล์ backup ไม่ถูกต้อง (ไม่พบข้อมูล files)';

  @override
  String get backupNeedsPassword => 'ไฟล์ backup นี้ต้องใส่รหัสผ่าน';

  @override
  String get restoreFailed => 'การ restore ล้มเหลว';

  @override
  String vaultReplaced(String name) {
    return 'Vault \"$name\" ถูกแทนที่';
  }

  @override
  String vaultSkipped(String name) {
    return 'ข้าม Vault \"$name\" เนื่องจากมีอยู่แล้ว';
  }

  @override
  String get folderSkippedNoVault => 'ข้าม folder เนื่องจากไม่พบ vault';

  @override
  String get fileSkippedNoVault => 'ข้าม file เนื่องจากไม่พบ vault';

  @override
  String encryptedFileNotFound(int id) {
    return 'ไม่พบไฟล์ encrypted สำหรับ file ID $id';
  }

  @override
  String get passwordMinLength => 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';

  @override
  String get pleaseEnterPassword => 'กรุณาใส่รหัสผ่าน';

  @override
  String get fileSaved => 'บันทึกไฟล์สำเร็จ';

  @override
  String get preparing => 'กำลังเตรียมข้อมูล...';

  @override
  String get creatingBackupFile => 'กำลังสร้างไฟล์ backup...';

  @override
  String get backingUpVaults => 'กำลัง backup vaults...';

  @override
  String get backingUpFileData => 'กำลัง backup ข้อมูลไฟล์...';

  @override
  String get backingUpEncryptedFiles => 'กำลัง backup encrypted files...';

  @override
  String backingUpFile(int current, int total) {
    return 'กำลัง backup ไฟล์ ($current/$total)...';
  }

  @override
  String get compressing => 'กำลังบีบอัดข้อมูล...';

  @override
  String get encrypting => 'กำลังเข้ารหัส backup...';

  @override
  String get done => 'เสร็จสิ้น!';

  @override
  String get readingBackup => 'กำลังอ่านไฟล์ backup...';

  @override
  String get decrypting => 'กำลังถอดรหัส backup...';

  @override
  String get extracting => 'กำลังแตกไฟล์...';

  @override
  String get restoringVaults => 'กำลัง restore vaults...';

  @override
  String get restoringFolders => 'กำลัง restore folders...';

  @override
  String get restoringFiles => 'กำลัง restore files...';

  @override
  String restoringFile(int current, int total) {
    return 'กำลัง restore ไฟล์ ($current/$total)...';
  }

  @override
  String get vaultList => 'Vaults ของฉัน';

  @override
  String get createVault => 'สร้าง Vault';

  @override
  String get openVault => 'เปิด Vault';

  @override
  String get deleteVault => 'ลบ Vault';

  @override
  String get vaultName => 'ชื่อ Vault';

  @override
  String get vaultPassword => 'รหัสผ่าน Vault';

  @override
  String get confirmPassword => 'ยืนยันรหัสผ่าน';

  @override
  String get enterVaultName => 'เช่น ไฟล์ส่วนตัว, รูปภาพ';

  @override
  String get enterVaultPassword => 'ใส่รหัสผ่าน vault';

  @override
  String get passwordMismatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get vaultCreated => 'สร้าง Vault สำเร็จ';

  @override
  String get vaultDeleted => 'ลบ Vault สำเร็จ';

  @override
  String get enterPasswordToOpen => 'ใส่รหัสผ่านเพื่อเปิด vault';

  @override
  String get wrongPassword => 'รหัสผ่านไม่ถูกต้อง';

  @override
  String get noVaults => 'ยังไม่มี vault';

  @override
  String get createFirstVault => 'สร้าง vault แรกของคุณเพื่อเริ่มต้น';

  @override
  String get pleaseEnterVaultName => 'กรุณากรอกชื่อ Vault';

  @override
  String get vaultNameMinLength => 'ชื่อ Vault ต้องมีอย่างน้อย 2 ตัวอักษร';

  @override
  String get vaultNameMaxLength => 'ชื่อ Vault ต้องไม่เกิน 50 ตัวอักษร';

  @override
  String get passwordMinLengthHint => 'อย่างน้อย 8 ตัวอักษร';

  @override
  String get passwordMinLength8 => 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';

  @override
  String get passwordMaxLength => 'รหัสผ่านต้องไม่เกิน 128 ตัวอักษร';

  @override
  String get pleaseConfirmPassword => 'กรุณายืนยันรหัสผ่าน';

  @override
  String get vaultPasswordWarning =>
      'สำคัญ: จำรหัสผ่านให้ดี หากลืมรหัสผ่านจะไม่สามารถกู้คืนไฟล์ได้';

  @override
  String get vaultCreationTimeout =>
      'การสร้าง Vault ใช้เวลานานเกินไป กรุณาลองใหม่อีกครั้ง';

  @override
  String get vaultCreationError => 'เกิดข้อผิดพลาดในการสร้าง Vault';

  @override
  String get directoryCreationError =>
      'ไม่สามารถสร้างโฟลเดอร์ได้ กรุณาตรวจสอบสิทธิ์การเข้าถึง';

  @override
  String get databaseError =>
      'เกิดข้อผิดพลาดในการบันทึกข้อมูล กรุณาลองใหม่อีกครั้ง';

  @override
  String get networkError =>
      'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';

  @override
  String get fileManager => 'จัดการไฟล์';

  @override
  String get addFiles => 'เพิ่มไฟล์';

  @override
  String get addImages => 'เพิ่มรูปภาพ';

  @override
  String get takePhoto => 'ถ่ายรูป';

  @override
  String get createFolder => 'สร้างโฟลเดอร์';

  @override
  String get folderName => 'ชื่อโฟลเดอร์';

  @override
  String get enterFolderName => 'ใส่ชื่อโฟลเดอร์';

  @override
  String get folderCreated => 'สร้างโฟลเดอร์สำเร็จ';

  @override
  String get deleteFolder => 'ลบโฟลเดอร์';

  @override
  String get folderDeleted => 'ลบโฟลเดอร์สำเร็จ';

  @override
  String get moveToFolder => 'ย้ายไปโฟลเดอร์';

  @override
  String get root => 'หน้าหลัก';

  @override
  String get moveTo => 'ย้ายไป';

  @override
  String get movedToFolder => 'ย้ายไปโฟลเดอร์สำเร็จ';

  @override
  String get search => 'ค้นหา';

  @override
  String get searchFiles => 'ค้นหาไฟล์...';

  @override
  String get noFilesFound => 'ไม่พบไฟล์';

  @override
  String get noFoldersFound => 'ไม่พบโฟลเดอร์';

  @override
  String get sortBy => 'เรียงตาม';

  @override
  String get sortNewest => 'ล่าสุด';

  @override
  String get sortOldest => 'เก่าสุด';

  @override
  String get sortNameAZ => 'ชื่อ ก-ฮ';

  @override
  String get sortNameZA => 'ชื่อ ฮ-ก';

  @override
  String get sortSizeSmall => 'ขนาด: เล็กสุด';

  @override
  String get sortSizeLarge => 'ขนาด: ใหญ่สุด';

  @override
  String get filterBy => 'กรองตาม';

  @override
  String get filterAll => 'ทั้งหมด';

  @override
  String get filterImages => 'รูปภาพ';

  @override
  String get filterDocuments => 'เอกสาร';

  @override
  String get filterVideos => 'วิดีโอ';

  @override
  String get filterAudio => 'เสียง';

  @override
  String get selectAll => 'เลือกทั้งหมด';

  @override
  String get deselectAll => 'ยกเลิกทั้งหมด';

  @override
  String selectedCount(int count) {
    return 'เลือก $count รายการ';
  }

  @override
  String get deleteSelected => 'ลบที่เลือก';

  @override
  String get moveSelected => 'ย้ายที่เลือก';

  @override
  String get downloadSelected => 'ดาวน์โหลดที่เลือก';

  @override
  String get fileDeleted => 'ลบไฟล์แล้ว';

  @override
  String get fileRestored => 'กู้คืนไฟล์แล้ว';

  @override
  String get movedToTrash => 'ย้ายไปถังขยะแล้ว';

  @override
  String get permanentDelete => 'ลบถาวร';

  @override
  String get permanentDeleteWarning =>
      'การดำเนินการนี้ไม่สามารถย้อนกลับได้ ไฟล์จะถูกลบถาวร';

  @override
  String daysRemaining(int count) {
    return 'เหลืออีก $count วัน';
  }

  @override
  String get emptyTrash => 'ล้างถังขยะ';

  @override
  String get emptyTrashWarning =>
      'นี่จะลบไฟล์ทั้งหมดในถังขยะอย่างถาวร การดำเนินการนี้ไม่สามารถย้อนกลับได้';

  @override
  String get trashEmpty => 'ถังขยะว่างเปล่า';

  @override
  String get restoreAll => 'กู้คืนทั้งหมด';

  @override
  String get allRestored => 'กู้คืนไฟล์ทั้งหมดแล้ว';

  @override
  String get trashEmptied => 'ล้างถังขยะแล้ว';

  @override
  String get fileDetails => 'รายละเอียดไฟล์';

  @override
  String get fileName => 'ชื่อไฟล์';

  @override
  String get fileType => 'ประเภทไฟล์';

  @override
  String get created => 'สร้างเมื่อ';

  @override
  String get modified => 'แก้ไขเมื่อ';

  @override
  String get size => 'ขนาด';

  @override
  String get download => 'ดาวน์โหลด';

  @override
  String get downloadComplete => 'ดาวน์โหลดสำเร็จ';

  @override
  String get decoyVault => 'Decoy Vault';

  @override
  String get decoyVaultSubtitle => 'สร้าง vault ปลอมด้วยรหัสผ่านต่างกัน';

  @override
  String get decoyVaultEnabled => 'เปิดใช้งาน Decoy Vault แล้ว';

  @override
  String get decoyVaultPassword => 'รหัสผ่าน Decoy';

  @override
  String get decoyVaultInfo => 'ใส่รหัสผ่าน decoy เพื่อเปิด vault ปลอม';

  @override
  String get decoyVaultWhatIs => 'Decoy Vault คืออะไร?';

  @override
  String get decoyVaultDescription =>
      'Decoy Vault เป็นฟีเจอร์ความปลอดภัยที่ช่วยปกป้องข้อมูลของคุณ ในกรณีที่ถูกบังคับให้เปิด Vault\n\n- ตั้งรหัสผ่านปลอม (Decoy Password)\n- เมื่อใส่รหัสปลอม จะแสดง Vault ปลอมที่มีข้อมูลไม่สำคัญ\n- รหัสผ่านจริงยังคงเปิด Vault จริงได้ตามปกติ';

  @override
  String get currentStatus => 'สถานะปัจจุบัน';

  @override
  String get decoyVaultActive => 'Decoy Vault เปิดใช้งานแล้ว';

  @override
  String get decoyVaultNotSet => 'ยังไม่ได้ตั้งค่า Decoy Vault';

  @override
  String get setupDecoyPassword => 'ตั้งค่า Decoy Password';

  @override
  String get decoyPasswordHint => 'รหัสผ่านนี้จะใช้เปิด Vault ปลอม';

  @override
  String get enterDecoyPassword => 'ใส่รหัสผ่านปลอม';

  @override
  String get confirmDecoyPassword => 'ยืนยัน Decoy Password';

  @override
  String get enterDecoyPasswordAgain => 'ใส่รหัสผ่านปลอมอีกครั้ง';

  @override
  String get setupDecoyVault => 'ตั้งค่า Decoy Vault';

  @override
  String get decoyPasswordWarning => 'อย่าใช้รหัสผ่านเดียวกับ Vault จริง!';

  @override
  String get enableDecoyVault => 'เปิดใช้งาน Decoy Vault';

  @override
  String get decoyPasswordWillWork => 'Decoy password จะใช้งานได้';

  @override
  String get decoyPasswordWillNotWork => 'Decoy password จะไม่ทำงาน';

  @override
  String get changeDecoyPassword => 'เปลี่ยน Decoy Password';

  @override
  String get setNewDecoyPassword => 'ตั้งรหัสผ่านปลอมใหม่';

  @override
  String get deleteDecoyVault => 'ลบ Decoy Vault';

  @override
  String get deleteDecoyVaultSubtitle => 'ลบรหัสผ่านปลอมและ Vault ปลอม';

  @override
  String get howToUse => 'วิธีใช้งาน';

  @override
  String get decoyStep1 => 'เมื่อเปิด Vault ใส่รหัสผ่านปลอมแทนรหัสจริง';

  @override
  String get decoyStep2 => 'ระบบจะเปิด Decoy Vault ที่มีข้อมูลปลอม';

  @override
  String get decoyStep3 => 'ใช้รหัสผ่านจริงเพื่อเปิด Vault จริง';

  @override
  String get confirmDelete => 'ยืนยันการลบ';

  @override
  String get deleteDecoyVaultConfirm =>
      'คุณต้องการลบ Decoy Vault หรือไม่?\n\nข้อมูลใน Decoy Vault จะถูกลบทั้งหมด';

  @override
  String get decoyVaultSetupSuccess => 'ตั้งค่า Decoy Vault สำเร็จ';

  @override
  String get decoyVaultDeleteSuccess => 'ลบ Decoy Vault สำเร็จ';

  @override
  String get passwordChangedSuccess => 'เปลี่ยนรหัสผ่านสำเร็จ';

  @override
  String get newPassword => 'รหัสผ่านใหม่';

  @override
  String get language => 'ภาษา';

  @override
  String get selectLanguage => 'เลือกภาษา';

  @override
  String get languageChanged => 'เปลี่ยนภาษาแล้ว';

  @override
  String get error => 'ข้อผิดพลาด';

  @override
  String get errorOccurred => 'เกิดข้อผิดพลาด';

  @override
  String get tryAgain => 'ลองอีกครั้ง';

  @override
  String get success => 'สำเร็จ';

  @override
  String get biometricFingerprint => 'ลายนิ้วมือ';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricIris => 'ม่านตา';

  @override
  String get biometricGeneric => 'ไบโอเมตริก';

  @override
  String get unlock => 'ปลดล็อค';

  @override
  String get setupPinTitle => 'ตั้งค่า PIN';

  @override
  String get confirmPinTitle => 'ยืนยัน PIN';

  @override
  String get confirmNewPinTitle => 'ยืนยัน PIN ใหม่';

  @override
  String get enterCurrentPinTitle => 'ใส่ PIN ปัจจุบัน';

  @override
  String get verifyIdentity => 'ยืนยันตัวตน';

  @override
  String get enter6DigitPinToUnlock => 'ใส่รหัส PIN 6 หลักเพื่อเปิดแอป';

  @override
  String get enter6DigitPinToSetup => 'สร้างรหัส PIN 6 หลักเพื่อความปลอดภัย';

  @override
  String get enterPinAgainToConfirm => 'ใส่รหัส PIN อีกครั้งเพื่อยืนยัน';

  @override
  String get enterNewPinAgain => 'ใส่รหัส PIN ใหม่อีกครั้ง';

  @override
  String get enterYourCurrentPin => 'ใส่รหัส PIN ปัจจุบันของคุณ';

  @override
  String get enterPinToContinue => 'ใส่รหัส PIN เพื่อดำเนินการต่อ';

  @override
  String get pinSetupSuccess => 'ตั้งค่า PIN สำเร็จ';

  @override
  String get pinSetupFailed => 'ไม่สามารถตั้งค่า PIN ได้';

  @override
  String get pinUsedToUnlock => 'PIN จะถูกใช้เพื่อปลดล็อคแอปทุกครั้ง';

  @override
  String waitMinutes(int minutes) {
    return 'รอ $minutes นาที แล้วลองใหม่';
  }

  @override
  String get authenticationSection => 'การยืนยันตัวตน';

  @override
  String get appProtected => 'แอปได้รับการปกป้อง';

  @override
  String get appNotLocked => 'แอปยังไม่ได้ล็อค';

  @override
  String get yourDataIsSafe => 'ข้อมูลของคุณปลอดภัย';

  @override
  String get setupPinForSecurity => 'ตั้งค่า PIN เพื่อความปลอดภัย';

  @override
  String get create6DigitPin => 'สร้างรหัส PIN 6 หลักเพื่อล็อคแอป';

  @override
  String get pinIsSet => 'PIN ถูกตั้งค่าแล้ว';

  @override
  String get appWillBeLocked => 'แอปจะถูกล็อคทุกครั้งที่เปิด';

  @override
  String get enabled => 'เปิดใช้งาน';

  @override
  String get disableAppLock => 'ปิดการล็อคแอป';

  @override
  String get disableAppLockConfirm => 'ปิดการล็อคแอป?';

  @override
  String get disableAppLockWarning =>
      'การปิดการล็อคแอปจะทำให้ทุกคนสามารถเข้าถึงข้อมูลในแอปได้ คุณแน่ใจหรือไม่?';

  @override
  String get disableLock => 'ปิดการล็อค';

  @override
  String get appLockDisabled => 'ปิดการล็อคแอปแล้ว';

  @override
  String get enterPinToConfirm => 'ใส่ PIN เพื่อยืนยัน';

  @override
  String get verifyCurrentPin => 'ยืนยัน PIN เดิม';

  @override
  String get enterCurrentPinToChange => 'ใส่ PIN ปัจจุบันเพื่อเปลี่ยน';

  @override
  String get setNewPin => 'ตั้ง PIN ใหม่';

  @override
  String get createNew6DigitPin => 'สร้างรหัส PIN 6 หลักใหม่';

  @override
  String get verifyPinTitle => 'ยืนยัน PIN';

  @override
  String get enterPinToDisableLock => 'ใส่ PIN เพื่อปิดการล็อคแอป';

  @override
  String unlockAppWith(Object type) {
    return 'ปลดล็อคแอปด้วย $type';
  }

  @override
  String enableBiometricToUnlock(Object type) {
    return 'เปิดใช้ $type เพื่อปลดล็อคแอป';
  }

  @override
  String biometricEnabled(Object type) {
    return 'เปิดใช้ $type แล้ว';
  }

  @override
  String lockAfterInactivity(Object time) {
    return 'ล็อคแอปหลังไม่ใช้งาน $time';
  }

  @override
  String get selectLockAfter => 'ล็อคอัตโนมัติหลังจาก';

  @override
  String get securityTips => 'เคล็ดลับความปลอดภัย';

  @override
  String get securityTip1 => 'ใช้ PIN ที่ไม่ซ้ำกับแอปอื่น';

  @override
  String get securityTip2 => 'หลีกเลี่ยง PIN ที่เดาง่าย เช่น 123456';

  @override
  String get securityTip3 => 'เปิดใช้ Biometric เพื่อความสะดวก';

  @override
  String get securityTip4 => 'ตั้งค่าล็อคอัตโนมัติเพื่อความปลอดภัย';

  @override
  String authenticateToEnable(Object type) {
    return 'ยืนยันตัวตนเพื่อเปิดใช้ $type';
  }

  @override
  String get biometricAuthFailed => 'การยืนยันตัวตนล้มเหลว';

  @override
  String get biometricSettings => 'ตั้งค่า Biometric';

  @override
  String biometricEnabledForVault(String type) {
    return '$type เปิดใช้งานอยู่';
  }

  @override
  String get forThisVault => 'สำหรับ Vault นี้';

  @override
  String get disableBiometric => 'ปิดใช้งาน Biometric';

  @override
  String get requirePasswordEveryTime => 'ต้องใช้รหัสผ่านทุกครั้ง';

  @override
  String get biometricDisabled => 'ปิดใช้งาน Biometric แล้ว';

  @override
  String get enableBiometricQuestion => 'เปิดใช้งาน Biometric?';

  @override
  String enableBiometricDescription(String type) {
    return 'ต้องการใช้ $type เพื่อปลดล็อค Vault นี้ในครั้งถัดไปหรือไม่?\n\nคุณยังสามารถใช้รหัสผ่านได้เหมือนเดิม';
  }

  @override
  String get doNotUse => 'ไม่ใช้';

  @override
  String get enable => 'เปิดใช้งาน';

  @override
  String biometricAvailableHint(String type) {
    return '$type พร้อมใช้งาน';
  }

  @override
  String get biometricFirstTimeHint =>
      'เปิด Vault ด้วยรหัสผ่านครั้งแรก แล้วระบบจะถามว่าต้องการเปิดใช้งานหรือไม่';

  @override
  String get orDivider => 'หรือ';

  @override
  String get upgradeSecurityTitle => 'อัปเกรดความปลอดภัย';

  @override
  String get upgradeSecurityDescription =>
      'Vault นี้ใช้ PBKDF2 ซึ่งเป็นมาตรฐานเก่า\n\nแนะนำให้อัปเกรดเป็น Argon2id ซึ่ง:';

  @override
  String get gpuAttackResistant => 'ทนทานต่อการโจมตีด้วย GPU';

  @override
  String get asicAttackResistant => 'ทนทานต่อการโจมตีด้วย ASIC';

  @override
  String get latestSecurityStandard => 'มาตรฐานความปลอดภัยล่าสุด';

  @override
  String get passwordRemainsNote => 'หมายเหตุ: รหัสผ่านจะยังคงเหมือนเดิม';

  @override
  String get upgradeLater => 'ไว้ทีหลัง';

  @override
  String get upgradeNow => 'อัปเกรด';

  @override
  String get upgradingProgress => 'กำลังอัปเกรด...';

  @override
  String get upgradeToArgon2idSuccess => 'อัปเกรดเป็น Argon2id สำเร็จ';

  @override
  String get upgradeToArgon2idFailed => 'อัปเกรดล้มเหลว';

  @override
  String get openVaultButton => 'เปิด Vault';

  @override
  String get onboardingWelcome => 'ยินดีต้อนรับสู่';

  @override
  String get onboardingGetStarted => 'เริ่มต้นใช้งาน';

  @override
  String get onboardingFeature1Title => 'เข้ารหัสระดับทหาร';

  @override
  String get onboardingFeature1Desc =>
      'ไฟล์ทุกไฟล์ถูกเข้ารหัส AES-256\nแม้แต่เราก็ไม่สามารถเข้าถึงข้อมูลของคุณได้';

  @override
  String get onboardingFeature2Title => 'เก็บในเครื่องเท่านั้น';

  @override
  String get onboardingFeature2Desc =>
      'ไม่มีการส่งข้อมูลไปยังเซิร์ฟเวอร์\nข้อมูลอยู่ในเครื่องของคุณเท่านั้น';

  @override
  String get onboardingFeature3Title => 'ปกป้องหลายชั้น';

  @override
  String get onboardingFeature3Desc =>
      'PIN, ไบโอเมตริก และ\nป้องกันการแคปหน้าจอ';

  @override
  String get onboardingFeature4Title => 'จัดการง่าย';

  @override
  String get onboardingFeature4Desc =>
      'สร้างตู้เซฟได้หลายอัน\nแต่ละอันมีรหัสผ่านแยกกัน';

  @override
  String get onboardingSecurityWarningTitle => 'กรุณาอ่านให้เข้าใจ';

  @override
  String get onboardingNoRecovery => 'ไม่มีระบบกู้รหัสผ่าน';

  @override
  String get onboardingNoRecoveryDesc =>
      'หากคุณลืมรหัส PIN หรือรหัส Vault ข้อมูลจะไม่สามารถกู้คืนได้อีก';

  @override
  String get onboardingRecommendations => 'คำแนะนำ:';

  @override
  String get onboardingRecommend1 => 'จดรหัสผ่านเก็บไว้ในที่ปลอดภัย';

  @override
  String get onboardingRecommend2 => 'ใช้รหัสผ่านที่คุณจำได้';

  @override
  String get onboardingRecommend3 => 'สำรองข้อมูลเป็นประจำ';

  @override
  String get onboardingUnderstandRisk => 'ฉันเข้าใจและยอมรับความเสี่ยงนี้';

  @override
  String get onboardingTermsTitle => 'ข้อตกลงการใช้งาน';

  @override
  String get onboardingTerms1 =>
      'ข้อมูลทั้งหมดถูกเข้ารหัสและเก็บในเครื่องเท่านั้น';

  @override
  String get onboardingTerms2 => 'เราไม่เก็บรหัสผ่านของคุณ';

  @override
  String get onboardingTerms3 =>
      'หากลืมรหัสผ่าน เราไม่สามารถช่วยกู้คืนข้อมูลได้';

  @override
  String get onboardingTerms4 => 'คุณมีหน้าที่รับผิดชอบในการจำรหัสผ่านของคุณ';

  @override
  String get onboardingTerms5 => 'แนะนำให้สำรองข้อมูลเป็นประจำ';

  @override
  String get onboardingAcceptTerms => 'ยอมรับข้อตกลง';

  @override
  String get onboardingAcceptPrivacy => 'ยอมรับนโยบายความเป็นส่วนตัว';

  @override
  String get onboardingAcceptAndContinue => 'ยอมรับและดำเนินการต่อ';

  @override
  String get onboardingSetupPinTitle => 'ตั้งค่า PIN';

  @override
  String get onboardingSetupPinDesc =>
      'PIN นี้จะใช้เปิดแอปทุกครั้งที่เข้าใช้งาน';

  @override
  String get onboardingEnter6DigitPin => 'กรอก PIN 6 หลัก';

  @override
  String get onboardingConfirmPinDesc => 'กรอก PIN อีกครั้งเพื่อยืนยัน';

  @override
  String onboardingBiometricTitle(String type) {
    return 'เปิดใช้ $type?';
  }

  @override
  String onboardingBiometricDesc(String type) {
    return 'ใช้ $type แทน PIN เพื่อความสะดวก\n\n(คุณยังต้องจำ PIN ไว้เผื่อกรณีฉุกเฉิน)';
  }

  @override
  String onboardingEnableBiometric(String type) {
    return 'เปิดใช้ $type';
  }

  @override
  String get onboardingSkipForNow => 'ข้ามไปก่อน';

  @override
  String get onboardingCompleteTitle => 'พร้อมใช้งานแล้ว!';

  @override
  String get onboardingCompleteTip1 => 'สร้าง Vault แรกเพื่อเริ่มเก็บไฟล์';

  @override
  String get onboardingCompleteTip2 => 'แต่ละ Vault มีรหัสผ่านแยกกัน';

  @override
  String get onboardingCompleteTip3 => 'สำรองข้อมูลได้ในหน้าตั้งค่า';

  @override
  String get onboardingStartUsing => 'เริ่มต้นใช้งาน';

  @override
  String get onboardingTips => 'เคล็ดลับ:';

  @override
  String get next => 'ถัดไป';

  @override
  String get skip => 'ข้าม';

  @override
  String get back => 'กลับ';

  @override
  String get largeFileWarning => 'คำเตือนไฟล์ขนาดใหญ่';

  @override
  String largeFileWarningMessage(int count, String size) {
    return 'คุณเลือก $count ไฟล์ที่มีขนาดใหญ่กว่า $size ไฟล์ขนาดใหญ่ต้องใช้ RAM มาก และอาจทำให้แอปค้างหรือปิดตัว';
  }

  @override
  String get largeFilesList => 'ไฟล์ขนาดใหญ่:';

  @override
  String estimatedRamUsage(String size) {
    return 'RAM ที่ต้องใช้โดยประมาณ: $size';
  }

  @override
  String get proceedAnyway => 'ดำเนินการต่อ';

  @override
  String get removeAndContinue => 'ลบไฟล์ใหญ่ออก';

  @override
  String get skipLargeFiles => 'ข้ามไฟล์ใหญ่และอัปโหลดเฉพาะไฟล์เล็ก';

  @override
  String get deleteOriginalTitle => 'ลบไฟล์ต้นฉบับ?';

  @override
  String deleteOriginalMessage(int count) {
    return 'อัปโหลด $count ไฟล์สำเร็จ คุณต้องการลบไฟล์ต้นฉบับจากเครื่องเพื่อประหยัดพื้นที่หรือไม่?';
  }

  @override
  String get deleteOriginalWarning =>
      'การดำเนินการนี้จะลบไฟล์ต้นฉบับจากแกลเลอรี/โฟลเดอร์อย่างถาวร';

  @override
  String get keepOriginals => 'เก็บไว้';

  @override
  String get deleteOriginals => 'ลบต้นฉบับ';

  @override
  String originalsDeleted(int count) {
    return 'ลบไฟล์ต้นฉบับ $count ไฟล์แล้ว';
  }

  @override
  String get originalsDeleteFailed => 'ไม่สามารถลบไฟล์ต้นฉบับบางไฟล์ได้';

  @override
  String get takeVideo => 'ถ่ายวิดีโอ';

  @override
  String get recentFiles => 'ไฟล์ล่าสุด';

  @override
  String get fileOpened => 'เปิดไฟล์แล้ว';

  @override
  String get theme => 'ธีม';

  @override
  String get themeSystem => 'ตามระบบ';

  @override
  String get themeLight => 'สว่าง';

  @override
  String get themeDark => 'มืด';

  @override
  String get selectTheme => 'เลือกธีม';

  @override
  String get themeChanged => 'เปลี่ยนธีมแล้ว';

  @override
  String get storageStats => 'สถิติพื้นที่จัดเก็บ';

  @override
  String get byCategory => 'ตามประเภท';

  @override
  String get images => 'รูปภาพ';

  @override
  String get videos => 'วิดีโอ';

  @override
  String get documents => 'เอกสาร';

  @override
  String get audio => 'เสียง';

  @override
  String get other => 'อื่นๆ';

  @override
  String get totalFiles => 'ไฟล์ทั้งหมด';

  @override
  String get totalSize => 'ขนาดทั้งหมด';

  @override
  String get tags => 'แท็ก';

  @override
  String get manageTags => 'จัดการแท็ก';

  @override
  String get createTag => 'สร้างแท็ก';

  @override
  String get tagName => 'ชื่อแท็ก';

  @override
  String get selectColor => 'เลือกสี';

  @override
  String get tagCreated => 'สร้างแท็กแล้ว';

  @override
  String get tagDeleted => 'ลบแท็กแล้ว';

  @override
  String get noTags => 'ยังไม่มีแท็ก';

  @override
  String get filterByTag => 'กรองตามแท็ก';
}
