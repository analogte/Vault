// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class SId extends S {
  SId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Secure Vault';

  @override
  String get appTagline => 'Jaga file Anda dengan aman';

  @override
  String get loading => 'Memuat...';

  @override
  String get securityCheck => 'Memeriksa keamanan...';

  @override
  String get enterPin => 'Silakan masukkan PIN';

  @override
  String get enteringApp => 'Memasuki aplikasi...';

  @override
  String get version => 'Versi';

  @override
  String get settings => 'Pengaturan';

  @override
  String get security => 'Keamanan';

  @override
  String get data => 'Data';

  @override
  String get about => 'Tentang';

  @override
  String get account => 'Akun';

  @override
  String biometricUnlock(String type) {
    return 'Buka kunci dengan $type';
  }

  @override
  String get biometricSubtitle =>
      'Gunakan sidik jari atau Face ID untuk membuka Vault';

  @override
  String get autoLock => 'Kunci Otomatis';

  @override
  String autoLockEnabled(String time) {
    return 'Kunci Vault setelah $time tidak aktif';
  }

  @override
  String get autoLockDisabled => 'Dinonaktifkan';

  @override
  String get lockTimeout => 'Waktu Kunci';

  @override
  String get selectAutoLockTimeout => 'Pilih waktu kunci otomatis';

  @override
  String get lockOnBackground => 'Kunci saat keluar aplikasi';

  @override
  String get lockOnBackgroundSubtitle =>
      'Kunci Vault segera saat beralih ke aplikasi lain';

  @override
  String get screenshotPrevention => 'Cegah Screenshot';

  @override
  String get screenshotPreventionSubtitle =>
      'Cegah pengambilan layar di aplikasi';

  @override
  String get restartRequired => 'Perubahan akan berlaku setelah restart';

  @override
  String get clipboardAutoClear => 'Hapus Clipboard Otomatis';

  @override
  String clipboardAutoClearEnabled(int seconds) {
    return 'Hapus clipboard setelah menyalin $seconds detik';
  }

  @override
  String get clipboardTimeout => 'Waktu Hapus Clipboard';

  @override
  String get selectClipboardTimeout => 'Pilih waktu hapus clipboard';

  @override
  String get securityStatus => 'Status Keamanan';

  @override
  String get deviceStatus => 'Status Perangkat';

  @override
  String get deviceSecure => 'Perangkat aman';

  @override
  String get deviceRooted => 'Perangkat telah di-Root/Jailbreak';

  @override
  String get developerModeEnabled => 'Mode Pengembang aktif';

  @override
  String get securityDetails => 'Detail Keamanan';

  @override
  String get appIntegrity => 'Integritas Aplikasi';

  @override
  String get appIntegritySafe => 'Aplikasi berjalan di lingkungan aman';

  @override
  String appIntegrityWarnings(int count) {
    return 'Ditemukan $count peringatan';
  }

  @override
  String get rootJailbreak => 'Root/Jailbreak';

  @override
  String get developerMode => 'Mode Pengembang';

  @override
  String get emulator => 'Emulator';

  @override
  String get externalStorage => 'Aplikasi terinstal di Penyimpanan Eksternal';

  @override
  String get debugMode => 'Mode Debug';

  @override
  String get detected => 'Terdeteksi';

  @override
  String get notDetected => 'Tidak Terdeteksi';

  @override
  String get warnings => 'Peringatan';

  @override
  String get trash => 'Sampah';

  @override
  String get trashSubtitle => 'Lihat dan pulihkan file yang dihapus';

  @override
  String get backup => 'Backup';

  @override
  String get backupSubtitle => 'Ekspor/Impor semua data';

  @override
  String get versionInfo => 'Versi';

  @override
  String get securityFeatures => 'Fitur Keamanan';

  @override
  String get securityFeaturesSubtitle => 'AES-256-GCM + Argon2id (atau PBKDF2)';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get privacyPolicySubtitle =>
      'Data dienkripsi dan disimpan secara lokal saja';

  @override
  String get appLockSettings => 'Pengaturan Kunci Aplikasi';

  @override
  String get pinEnabled => 'PIN aktif';

  @override
  String get pinNotSet => 'PIN belum diatur';

  @override
  String get lockAppNow => 'Kunci Aplikasi Sekarang';

  @override
  String get lockAppNowSubtitle => 'Kunci aplikasi dan tampilkan layar PIN';

  @override
  String get encryption => 'Enkripsi';

  @override
  String get encryptionAES => 'AES-256-GCM (Standar militer)';

  @override
  String get encryptionArgon2 => 'Argon2id Key Derivation (Tahan serangan GPU)';

  @override
  String get encryptionPBKDF2 => 'PBKDF2 100.000 iterasi (untuk vault lama)';

  @override
  String get protection => 'Perlindungan';

  @override
  String get protectionRoot => 'Deteksi Root/Jailbreak';

  @override
  String get protectionEmulator => 'Deteksi Emulator dan mode Debug';

  @override
  String get protectionScreenshot => 'Cegah Screenshot';

  @override
  String get protectionClipboard => 'Hapus Clipboard otomatis';

  @override
  String get protectionBackground => 'Kunci saat di background';

  @override
  String get storage => 'Penyimpanan';

  @override
  String get storageKeystore => 'Hardware Keystore (Android/iOS)';

  @override
  String get storageEncrypted => 'Encrypted Shared Preferences';

  @override
  String get storageNoServer => 'Data tidak dikirim ke server';

  @override
  String get specialFeatures => 'Fitur Khusus';

  @override
  String get featureSecureKeyboard => 'Keyboard Aman (tanpa logging)';

  @override
  String get featureDecoyVault => 'Vault Palsu (vault tiruan)';

  @override
  String get featureObfuscation => 'Obfuskasi Kode';

  @override
  String get privacyTitle => 'Privasi';

  @override
  String get privacyInfo1 => 'Semua file dienkripsi dengan AES-256-GCM';

  @override
  String get privacyInfo2 => 'Password diproses dengan PBKDF2 100.000 putaran';

  @override
  String get privacyInfo3 => 'Semua data disimpan di perangkat Anda saja';

  @override
  String get privacyInfo4 => 'Tidak ada data yang dikirim ke server';

  @override
  String get privacyInfo5 => 'Tidak ada pelacakan atau analisis perilaku';

  @override
  String get privacyInfo6 => 'Tanpa iklan';

  @override
  String get privacyWarning =>
      'Jika lupa password, data tidak dapat dipulihkan';

  @override
  String get understood => 'Mengerti';

  @override
  String get securityWarning => 'Peringatan Keamanan';

  @override
  String get unsafeEnvironment =>
      'Lingkungan yang mungkin tidak aman terdeteksi:';

  @override
  String get appStillUsable =>
      'Aplikasi masih dapat digunakan, tetapi data mungkin berisiko.\nDisarankan menggunakan di perangkat yang tidak di-root/jailbreak';

  @override
  String get exitApp => 'Keluar Aplikasi';

  @override
  String get continueAnyway => 'Lanjutkan';

  @override
  String seconds(int count) {
    return '$count detik';
  }

  @override
  String minutes(int count) {
    return '$count menit';
  }

  @override
  String hours(int count) {
    return '$count jam';
  }

  @override
  String get close => 'Tutup';

  @override
  String get cancel => 'Batal';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get share => 'Bagikan';

  @override
  String get restore => 'Pulihkan';

  @override
  String get pinLock => 'Kunci PIN';

  @override
  String get enterPinToUnlock => 'Masukkan PIN untuk membuka kunci';

  @override
  String get enterCurrentPin => 'Masukkan PIN saat ini';

  @override
  String get enterNewPin => 'Masukkan PIN baru';

  @override
  String get confirmNewPin => 'Konfirmasi PIN baru';

  @override
  String get createPin => 'Buat PIN';

  @override
  String get changePin => 'Ubah PIN';

  @override
  String get wrongPin => 'PIN salah';

  @override
  String get pinMismatch => 'PIN tidak cocok';

  @override
  String get pinChanged => 'PIN berhasil diubah';

  @override
  String get pinCreated => 'PIN berhasil dibuat';

  @override
  String get forgotPin => 'Lupa PIN?';

  @override
  String useBiometric(String type) {
    return 'Gunakan $type';
  }

  @override
  String attemptsRemaining(int count) {
    return 'Sisa $count percobaan';
  }

  @override
  String get tooManyAttempts => 'Terlalu banyak percobaan gagal';

  @override
  String tryAgainIn(int seconds) {
    return 'Coba lagi dalam $seconds detik';
  }

  @override
  String get enableAppLock => 'Aktifkan Kunci Aplikasi';

  @override
  String get enableAppLockSubtitle => 'Memerlukan PIN saat membuka aplikasi';

  @override
  String get biometricForAppLock => 'Biometrik untuk Kunci Aplikasi';

  @override
  String biometricForAppLockSubtitle(String type) {
    return 'Gunakan $type sebagai pengganti PIN';
  }

  @override
  String get autoLockTimeout => 'Waktu Kunci Otomatis';

  @override
  String lockAfterBackground(String time) {
    return 'Kunci setelah $time di background';
  }

  @override
  String get immediately => 'Segera';

  @override
  String get setupPin => 'Atur PIN';

  @override
  String get resetPin => 'Reset PIN';

  @override
  String get setPinFirst => 'Silakan atur PIN terlebih dahulu';

  @override
  String get backupTitle => 'Backup Data';

  @override
  String get backupInfo => 'Tentang Backup';

  @override
  String get backupInfo1 => 'File backup mencakup semua Vault, Folder dan file';

  @override
  String get backupInfo2 =>
      'File tetap terenkripsi, aman untuk dibagikan ke Cloud';

  @override
  String get backupInfo3 => 'Dapat mengatur password tambahan untuk keamanan';

  @override
  String get backupInfo4 => 'Disarankan untuk backup secara teratur';

  @override
  String get createBackup => 'Buat Backup';

  @override
  String get setBackupPassword => 'Atur Password Backup';

  @override
  String get setBackupPasswordSubtitle =>
      'Enkripsi file backup dengan password tambahan';

  @override
  String get password => 'Password';

  @override
  String get enterBackupPassword => 'Masukkan password untuk backup';

  @override
  String get creating => 'Membuat...';

  @override
  String get restoreFromBackup => 'Pulihkan dari Backup';

  @override
  String get selectBackupFile => 'Pilih file .svbackup untuk dipulihkan';

  @override
  String get duplicateVaultWarning =>
      'Jika Vault yang dipulihkan memiliki nama yang sama dengan yang ada, akan dilewati';

  @override
  String get selectBackupFileButton => 'Pilih File Backup';

  @override
  String get restoring => 'Memulihkan...';

  @override
  String get backupCreatedSuccess => 'Backup Berhasil Dibuat!';

  @override
  String get vaults => 'Vault';

  @override
  String get files => 'File';

  @override
  String get folders => 'Folder';

  @override
  String get fileSize => 'Ukuran File';

  @override
  String get selectSaveMethod => 'Pilih cara menyimpan file backup:';

  @override
  String get restoreSuccess => 'Pemulihan Berhasil!';

  @override
  String get vaultsRestored => 'Vault dipulihkan';

  @override
  String get filesRestored => 'File dipulihkan';

  @override
  String get foldersRestored => 'Folder dipulihkan';

  @override
  String get enterBackupPasswordPrompt => 'Masukkan Password Backup';

  @override
  String get backupInfoTitle => 'Info Backup';

  @override
  String get createdAt => 'Dibuat pada';

  @override
  String get device => 'Perangkat';

  @override
  String get vaultCount => 'Jumlah Vault';

  @override
  String get fileCount => 'Jumlah File';

  @override
  String get folderCount => 'Jumlah Folder';

  @override
  String get passwordProtected => 'Password';

  @override
  String get yes => 'Ada';

  @override
  String get no => 'Tidak ada';

  @override
  String get duplicateSkipped => 'Vault dengan nama sama akan dilewati';

  @override
  String get noVaultsToBackup => 'Tidak ada Vault untuk dibackup';

  @override
  String get backupFailed => 'Pembuatan backup gagal';

  @override
  String get fileNotFound => 'File backup tidak ditemukan';

  @override
  String get wrongPasswordOrCorrupt => 'Password salah atau file rusak';

  @override
  String get backupCorruptOrNeedsPassword =>
      'File backup rusak atau memerlukan password';

  @override
  String get invalidBackupNoMetadata =>
      'File backup tidak valid (tidak ada metadata)';

  @override
  String get invalidBackupNoVaults =>
      'File backup tidak valid (tidak ada data vault)';

  @override
  String get invalidBackupNoFiles =>
      'File backup tidak valid (tidak ada data file)';

  @override
  String get backupNeedsPassword => 'Backup ini memerlukan password';

  @override
  String get restoreFailed => 'Pemulihan gagal';

  @override
  String vaultReplaced(String name) {
    return 'Vault \"$name\" diganti';
  }

  @override
  String vaultSkipped(String name) {
    return 'Melewati Vault \"$name\" karena sudah ada';
  }

  @override
  String get folderSkippedNoVault =>
      'Melewati folder karena vault tidak ditemukan';

  @override
  String get fileSkippedNoVault => 'Melewati file karena vault tidak ditemukan';

  @override
  String encryptedFileNotFound(int id) {
    return 'File terenkripsi untuk ID $id tidak ditemukan';
  }

  @override
  String get passwordMinLength => 'Password minimal 4 karakter';

  @override
  String get pleaseEnterPassword => 'Silakan masukkan password';

  @override
  String get fileSaved => 'File berhasil disimpan';

  @override
  String get preparing => 'Menyiapkan data...';

  @override
  String get creatingBackupFile => 'Membuat file backup...';

  @override
  String get backingUpVaults => 'Membackup vault...';

  @override
  String get backingUpFileData => 'Membackup data file...';

  @override
  String get backingUpEncryptedFiles => 'Membackup file terenkripsi...';

  @override
  String backingUpFile(int current, int total) {
    return 'Membackup file ($current/$total)...';
  }

  @override
  String get compressing => 'Mengompresi data...';

  @override
  String get encrypting => 'Mengenkripsi backup...';

  @override
  String get done => 'Selesai!';

  @override
  String get readingBackup => 'Membaca file backup...';

  @override
  String get decrypting => 'Mendekripsi backup...';

  @override
  String get extracting => 'Mengekstrak file...';

  @override
  String get restoringVaults => 'Memulihkan vault...';

  @override
  String get restoringFolders => 'Memulihkan folder...';

  @override
  String get restoringFiles => 'Memulihkan file...';

  @override
  String restoringFile(int current, int total) {
    return 'Memulihkan file ($current/$total)...';
  }

  @override
  String get vaultList => 'Vault Saya';

  @override
  String get createVault => 'Buat Vault';

  @override
  String get openVault => 'Buka Vault';

  @override
  String get deleteVault => 'Hapus Vault';

  @override
  String get vaultName => 'Nama Vault';

  @override
  String get vaultPassword => 'Password Vault';

  @override
  String get confirmPassword => 'Konfirmasi Password';

  @override
  String get enterVaultName => 'Masukkan nama vault';

  @override
  String get enterVaultPassword => 'Masukkan password vault';

  @override
  String get passwordMismatch => 'Password tidak cocok';

  @override
  String get vaultCreated => 'Vault berhasil dibuat';

  @override
  String get vaultDeleted => 'Vault berhasil dihapus';

  @override
  String get enterPasswordToOpen => 'Masukkan password untuk membuka vault';

  @override
  String get wrongPassword => 'Password salah';

  @override
  String get noVaults => 'Belum ada vault';

  @override
  String get createFirstVault => 'Buat vault pertama Anda untuk memulai';

  @override
  String get pleaseEnterVaultName => 'Please enter vault name';

  @override
  String get vaultNameMinLength => 'Vault name must be at least 2 characters';

  @override
  String get vaultNameMaxLength => 'Vault name must not exceed 50 characters';

  @override
  String get passwordMinLengthHint => 'At least 8 characters';

  @override
  String get passwordMinLength8 => 'Password must be at least 8 characters';

  @override
  String get passwordMaxLength => 'Password must not exceed 128 characters';

  @override
  String get pleaseConfirmPassword => 'Please confirm password';

  @override
  String get vaultPasswordWarning =>
      'Important: Remember your password well. If you forget it, files cannot be recovered.';

  @override
  String get vaultCreationTimeout =>
      'Vault creation took too long. Please try again.';

  @override
  String get vaultCreationError => 'Error creating vault';

  @override
  String get directoryCreationError =>
      'Cannot create folder. Please check access permissions.';

  @override
  String get databaseError => 'Database error. Please try again.';

  @override
  String get networkError =>
      'Cannot connect to server. Please check your internet connection.';

  @override
  String get fileManager => 'Manajer File';

  @override
  String get addFiles => 'Tambah File';

  @override
  String get addImages => 'Tambah Gambar';

  @override
  String get takePhoto => 'Ambil Foto';

  @override
  String get createFolder => 'Buat Folder';

  @override
  String get folderName => 'Nama Folder';

  @override
  String get enterFolderName => 'Masukkan nama folder';

  @override
  String get folderCreated => 'Folder berhasil dibuat';

  @override
  String get deleteFolder => 'Hapus Folder';

  @override
  String get folderDeleted => 'Folder berhasil dihapus';

  @override
  String get moveToFolder => 'Pindahkan ke Folder';

  @override
  String get root => 'Root';

  @override
  String get moveTo => 'Pindahkan ke';

  @override
  String get movedToFolder => 'Berhasil dipindahkan ke folder';

  @override
  String get search => 'Cari';

  @override
  String get searchFiles => 'Cari file...';

  @override
  String get noFilesFound => 'File tidak ditemukan';

  @override
  String get noFoldersFound => 'Folder tidak ditemukan';

  @override
  String get sortBy => 'Urutkan';

  @override
  String get sortNewest => 'Terbaru';

  @override
  String get sortOldest => 'Terlama';

  @override
  String get sortNameAZ => 'Nama A-Z';

  @override
  String get sortNameZA => 'Nama Z-A';

  @override
  String get sortSizeSmall => 'Ukuran: Terkecil';

  @override
  String get sortSizeLarge => 'Ukuran: Terbesar';

  @override
  String get filterBy => 'Filter';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterImages => 'Gambar';

  @override
  String get filterDocuments => 'Dokumen';

  @override
  String get filterVideos => 'Video';

  @override
  String get filterAudio => 'Audio';

  @override
  String get selectAll => 'Pilih Semua';

  @override
  String get deselectAll => 'Batalkan Pilihan';

  @override
  String selectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String get deleteSelected => 'Hapus Terpilih';

  @override
  String get moveSelected => 'Pindahkan Terpilih';

  @override
  String get downloadSelected => 'Unduh Terpilih';

  @override
  String get fileDeleted => 'File dihapus';

  @override
  String get fileRestored => 'File dipulihkan';

  @override
  String get movedToTrash => 'Dipindahkan ke sampah';

  @override
  String get permanentDelete => 'Hapus Permanen';

  @override
  String get permanentDeleteWarning =>
      'Tindakan ini tidak dapat dibatalkan. File akan dihapus secara permanen.';

  @override
  String daysRemaining(int count) {
    return 'Tersisa $count hari';
  }

  @override
  String get emptyTrash => 'Kosongkan Sampah';

  @override
  String get emptyTrashWarning =>
      'Ini akan menghapus semua file di sampah secara permanen. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get trashEmpty => 'Sampah kosong';

  @override
  String get restoreAll => 'Pulihkan Semua';

  @override
  String get allRestored => 'Semua file dipulihkan';

  @override
  String get trashEmptied => 'Sampah dikosongkan';

  @override
  String get fileDetails => 'Detail File';

  @override
  String get fileName => 'Nama File';

  @override
  String get fileType => 'Tipe File';

  @override
  String get created => 'Dibuat';

  @override
  String get modified => 'Diubah';

  @override
  String get size => 'Ukuran';

  @override
  String get download => 'Unduh';

  @override
  String get downloadComplete => 'Unduhan selesai';

  @override
  String get decoyVault => 'Vault Palsu';

  @override
  String get decoyVaultSubtitle => 'Buat vault palsu dengan password berbeda';

  @override
  String get decoyVaultEnabled => 'Vault Palsu aktif';

  @override
  String get decoyVaultPassword => 'Password Palsu';

  @override
  String get decoyVaultInfo =>
      'Masukkan password palsu untuk membuka vault palsu';

  @override
  String get decoyVaultWhatIs => 'What is Decoy Vault?';

  @override
  String get decoyVaultDescription =>
      'Decoy Vault is a security feature that helps protect your data in case you are forced to open your Vault.\n\n- Set a fake password (Decoy Password)\n- When entering the fake password, it shows a fake Vault with unimportant data\n- Your real password still opens the real Vault normally';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get decoyVaultActive => 'Decoy Vault is active';

  @override
  String get decoyVaultNotSet => 'Decoy Vault not set up';

  @override
  String get setupDecoyPassword => 'Setup Decoy Password';

  @override
  String get decoyPasswordHint => 'This password will open the fake Vault';

  @override
  String get enterDecoyPassword => 'Enter decoy password';

  @override
  String get confirmDecoyPassword => 'Confirm Decoy Password';

  @override
  String get enterDecoyPasswordAgain => 'Enter decoy password again';

  @override
  String get setupDecoyVault => 'Setup Decoy Vault';

  @override
  String get decoyPasswordWarning =>
      'Do not use the same password as your real Vault!';

  @override
  String get enableDecoyVault => 'Enable Decoy Vault';

  @override
  String get decoyPasswordWillWork => 'Decoy password will work';

  @override
  String get decoyPasswordWillNotWork => 'Decoy password will not work';

  @override
  String get changeDecoyPassword => 'Change Decoy Password';

  @override
  String get setNewDecoyPassword => 'Set new decoy password';

  @override
  String get deleteDecoyVault => 'Delete Decoy Vault';

  @override
  String get deleteDecoyVaultSubtitle => 'Delete decoy password and fake vault';

  @override
  String get howToUse => 'How to Use';

  @override
  String get decoyStep1 =>
      'When opening Vault, enter decoy password instead of real password';

  @override
  String get decoyStep2 => 'System will open Decoy Vault with fake data';

  @override
  String get decoyStep3 => 'Use real password to open real Vault';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteDecoyVaultConfirm =>
      'Do you want to delete Decoy Vault?\n\nAll data in Decoy Vault will be deleted.';

  @override
  String get decoyVaultSetupSuccess => 'Decoy Vault setup successful';

  @override
  String get decoyVaultDeleteSuccess => 'Decoy Vault deleted successfully';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get newPassword => 'New Password';

  @override
  String get language => 'Bahasa';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get languageChanged => 'Bahasa diubah';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'Terjadi kesalahan';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get success => 'Berhasil';

  @override
  String get biometricFingerprint => 'Sidik Jari';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricIris => 'Iris';

  @override
  String get biometricGeneric => 'Biometrik';

  @override
  String get unlock => 'Buka Kunci';

  @override
  String get setupPinTitle => 'Atur PIN';

  @override
  String get confirmPinTitle => 'Konfirmasi PIN';

  @override
  String get confirmNewPinTitle => 'Konfirmasi PIN Baru';

  @override
  String get enterCurrentPinTitle => 'Masukkan PIN Saat Ini';

  @override
  String get verifyIdentity => 'Verifikasi Identitas';

  @override
  String get enter6DigitPinToUnlock =>
      'Masukkan PIN 6 digit untuk membuka aplikasi';

  @override
  String get enter6DigitPinToSetup => 'Buat PIN 6 digit untuk keamanan';

  @override
  String get enterPinAgainToConfirm => 'Masukkan PIN lagi untuk konfirmasi';

  @override
  String get enterNewPinAgain => 'Masukkan PIN baru lagi';

  @override
  String get enterYourCurrentPin => 'Masukkan PIN Anda saat ini';

  @override
  String get enterPinToContinue => 'Masukkan PIN untuk melanjutkan';

  @override
  String get pinSetupSuccess => 'PIN berhasil diatur';

  @override
  String get pinSetupFailed => 'Tidak dapat mengatur PIN';

  @override
  String get pinUsedToUnlock => 'PIN akan digunakan untuk membuka aplikasi';

  @override
  String waitMinutes(int minutes) {
    return 'Tunggu $minutes menit lalu coba lagi';
  }

  @override
  String get authenticationSection => 'Authentication';

  @override
  String get appProtected => 'App is protected';

  @override
  String get appNotLocked => 'App is not locked';

  @override
  String get yourDataIsSafe => 'Your data is safe';

  @override
  String get setupPinForSecurity => 'Setup PIN for security';

  @override
  String get create6DigitPin => 'Create 6-digit PIN to lock app';

  @override
  String get pinIsSet => 'PIN is set';

  @override
  String get appWillBeLocked => 'App will be locked on every open';

  @override
  String get enabled => 'Enabled';

  @override
  String get disableAppLock => 'Disable App Lock';

  @override
  String get disableAppLockConfirm => 'Disable App Lock?';

  @override
  String get disableAppLockWarning =>
      'Disabling app lock will allow anyone to access your data. Are you sure?';

  @override
  String get disableLock => 'Disable Lock';

  @override
  String get appLockDisabled => 'App lock disabled';

  @override
  String get enterPinToConfirm => 'Enter PIN to confirm';

  @override
  String get verifyCurrentPin => 'Verify Current PIN';

  @override
  String get enterCurrentPinToChange => 'Enter current PIN to change';

  @override
  String get setNewPin => 'Set New PIN';

  @override
  String get createNew6DigitPin => 'Create a new 6-digit PIN';

  @override
  String get verifyPinTitle => 'Verify PIN';

  @override
  String get enterPinToDisableLock => 'Enter PIN to disable app lock';

  @override
  String unlockAppWith(Object type) {
    return 'Unlock app with $type';
  }

  @override
  String enableBiometricToUnlock(Object type) {
    return 'Enable $type to unlock app';
  }

  @override
  String biometricEnabled(Object type) {
    return '$type enabled';
  }

  @override
  String lockAfterInactivity(Object time) {
    return 'Lock app after $time of inactivity';
  }

  @override
  String get selectLockAfter => 'Lock after';

  @override
  String get securityTips => 'Security Tips';

  @override
  String get securityTip1 => 'Use a unique PIN not used in other apps';

  @override
  String get securityTip2 => 'Avoid easy PINs like 123456';

  @override
  String get securityTip3 => 'Enable Biometric for convenience';

  @override
  String get securityTip4 => 'Set auto lock for better security';

  @override
  String authenticateToEnable(Object type) {
    return 'Authenticate to enable $type';
  }

  @override
  String get biometricAuthFailed => 'Authentication failed';

  @override
  String get biometricSettings => 'Biometric Settings';

  @override
  String biometricEnabledForVault(String type) {
    return '$type is enabled';
  }

  @override
  String get forThisVault => 'For this vault';

  @override
  String get disableBiometric => 'Disable Biometric';

  @override
  String get requirePasswordEveryTime => 'Require password every time';

  @override
  String get biometricDisabled => 'Biometric disabled';

  @override
  String get enableBiometricQuestion => 'Enable Biometric?';

  @override
  String enableBiometricDescription(String type) {
    return 'Do you want to use $type to unlock this vault next time?\n\nYou can still use password as usual.';
  }

  @override
  String get doNotUse => 'Don\'t use';

  @override
  String get enable => 'Enable';

  @override
  String biometricAvailableHint(String type) {
    return '$type is available';
  }

  @override
  String get biometricFirstTimeHint =>
      'Open vault with password first, then you will be asked to enable it';

  @override
  String get orDivider => 'or';

  @override
  String get upgradeSecurityTitle => 'Security Upgrade';

  @override
  String get upgradeSecurityDescription =>
      'This vault uses PBKDF2 which is an older standard.\n\nRecommend upgrading to Argon2id which:';

  @override
  String get gpuAttackResistant => 'Resistant to GPU attacks';

  @override
  String get asicAttackResistant => 'Resistant to ASIC attacks';

  @override
  String get latestSecurityStandard => 'Latest security standard';

  @override
  String get passwordRemainsNote => 'Note: Password will remain the same';

  @override
  String get upgradeLater => 'Later';

  @override
  String get upgradeNow => 'Upgrade';

  @override
  String get upgradingProgress => 'Upgrading...';

  @override
  String get upgradeToArgon2idSuccess => 'Upgraded to Argon2id successfully';

  @override
  String get upgradeToArgon2idFailed => 'Upgrade failed';

  @override
  String get openVaultButton => 'Open Vault';

  @override
  String get onboardingWelcome => 'Welcome to';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingFeature1Title => 'Military-Grade Encryption';

  @override
  String get onboardingFeature1Desc =>
      'All files are encrypted with AES-256.\nEven we cannot access your data.';

  @override
  String get onboardingFeature2Title => 'Stored Locally Only';

  @override
  String get onboardingFeature2Desc =>
      'No data is sent to any server.\nYour data stays only on your device.';

  @override
  String get onboardingFeature3Title => 'Multi-Layer Protection';

  @override
  String get onboardingFeature3Desc =>
      'PIN, Biometric, and\nScreenshot prevention.';

  @override
  String get onboardingFeature4Title => 'Easy Management';

  @override
  String get onboardingFeature4Desc =>
      'Create multiple vaults,\neach with its own password.';

  @override
  String get onboardingSecurityWarningTitle => 'Please Read Carefully';

  @override
  String get onboardingNoRecovery => 'No Password Recovery';

  @override
  String get onboardingNoRecoveryDesc =>
      'If you forget your PIN or Vault password, your data cannot be recovered.';

  @override
  String get onboardingRecommendations => 'Recommendations:';

  @override
  String get onboardingRecommend1 =>
      'Write down your passwords and keep them safe';

  @override
  String get onboardingRecommend2 => 'Use passwords you can remember';

  @override
  String get onboardingRecommend3 => 'Backup your data regularly';

  @override
  String get onboardingUnderstandRisk => 'I understand and accept this risk';

  @override
  String get onboardingTermsTitle => 'Terms of Service';

  @override
  String get onboardingTerms1 =>
      'All data is encrypted and stored locally only';

  @override
  String get onboardingTerms2 => 'We do not store your passwords';

  @override
  String get onboardingTerms3 =>
      'If you forget your password, we cannot help recover your data';

  @override
  String get onboardingTerms4 =>
      'You are responsible for remembering your passwords';

  @override
  String get onboardingTerms5 => 'Regular backups are recommended';

  @override
  String get onboardingAcceptTerms => 'Accept Terms';

  @override
  String get onboardingAcceptPrivacy => 'Accept Privacy Policy';

  @override
  String get onboardingAcceptAndContinue => 'Accept and Continue';

  @override
  String get onboardingSetupPinTitle => 'Setup PIN';

  @override
  String get onboardingSetupPinDesc =>
      'This PIN will be used to open the app every time.';

  @override
  String get onboardingEnter6DigitPin => 'Enter 6-digit PIN';

  @override
  String get onboardingConfirmPinDesc => 'Enter PIN again to confirm';

  @override
  String onboardingBiometricTitle(String type) {
    return 'Enable $type?';
  }

  @override
  String onboardingBiometricDesc(String type) {
    return 'Use $type instead of PIN for convenience.\n\n(You still need to remember your PIN for emergencies)';
  }

  @override
  String onboardingEnableBiometric(String type) {
    return 'Enable $type';
  }

  @override
  String get onboardingSkipForNow => 'Skip for now';

  @override
  String get onboardingCompleteTitle => 'All Set!';

  @override
  String get onboardingCompleteTip1 =>
      'Create your first Vault to start storing files';

  @override
  String get onboardingCompleteTip2 =>
      'Each Vault has its own separate password';

  @override
  String get onboardingCompleteTip3 => 'You can backup your data in Settings';

  @override
  String get onboardingStartUsing => 'Start Using';

  @override
  String get onboardingTips => 'Tips:';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get largeFileWarning => 'Large File Warning';

  @override
  String largeFileWarningMessage(int count, String size) {
    return 'You selected $count file(s) larger than $size. Large files require significant RAM and may cause the app to crash.';
  }

  @override
  String get largeFilesList => 'Large files:';

  @override
  String estimatedRamUsage(String size) {
    return 'Estimated RAM usage: $size';
  }

  @override
  String get proceedAnyway => 'Proceed Anyway';

  @override
  String get removeAndContinue => 'Remove Large Files';

  @override
  String get skipLargeFiles =>
      'Skip large files and continue with smaller ones';

  @override
  String get deleteOriginalTitle => 'Delete Original Files?';

  @override
  String deleteOriginalMessage(int count) {
    return 'Successfully uploaded $count file(s). Would you like to delete the original files from your device to save storage space?';
  }

  @override
  String get deleteOriginalWarning =>
      'This will permanently delete the original files from your gallery/folder.';

  @override
  String get keepOriginals => 'Keep Originals';

  @override
  String get deleteOriginals => 'Delete Originals';

  @override
  String originalsDeleted(int count) {
    return '$count original file(s) deleted';
  }

  @override
  String get originalsDeleteFailed => 'Could not delete some original files';

  @override
  String get takeVideo => 'Take Video';

  @override
  String get recentFiles => 'Recent Files';

  @override
  String get fileOpened => 'File opened';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get themeChanged => 'Theme changed';

  @override
  String get storageStats => 'Storage Stats';

  @override
  String get byCategory => 'By Category';

  @override
  String get images => 'Images';

  @override
  String get videos => 'Videos';

  @override
  String get documents => 'Documents';

  @override
  String get audio => 'Audio';

  @override
  String get other => 'Other';

  @override
  String get totalFiles => 'Total Files';

  @override
  String get totalSize => 'Total Size';

  @override
  String get tags => 'Tags';

  @override
  String get manageTags => 'Manage Tags';

  @override
  String get createTag => 'Create Tag';

  @override
  String get tagName => 'Tag Name';

  @override
  String get selectColor => 'Select Color';

  @override
  String get tagCreated => 'Tag created';

  @override
  String get tagDeleted => 'Tag deleted';

  @override
  String get noTags => 'No tags yet';

  @override
  String get filterByTag => 'Filter by Tag';
}
