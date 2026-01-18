// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Secure Vault';

  @override
  String get appTagline => 'Keep your files safe';

  @override
  String get loading => 'Loading...';

  @override
  String get securityCheck => 'Checking security...';

  @override
  String get enterPin => 'Please enter PIN';

  @override
  String get enteringApp => 'Entering app...';

  @override
  String get version => 'Version';

  @override
  String get settings => 'Settings';

  @override
  String get security => 'Security';

  @override
  String get data => 'Data';

  @override
  String get about => 'About';

  @override
  String get account => 'Account';

  @override
  String biometricUnlock(String type) {
    return 'Unlock with $type';
  }

  @override
  String get biometricSubtitle => 'Use fingerprint or Face ID to open Vault';

  @override
  String get autoLock => 'Auto Lock';

  @override
  String autoLockEnabled(String time) {
    return 'Lock Vault after $time of inactivity';
  }

  @override
  String get autoLockDisabled => 'Disabled';

  @override
  String get lockTimeout => 'Lock Timeout';

  @override
  String get selectAutoLockTimeout => 'Select auto lock timeout';

  @override
  String get lockOnBackground => 'Lock when leaving app';

  @override
  String get lockOnBackgroundSubtitle =>
      'Lock Vault immediately when switching to another app';

  @override
  String get screenshotPrevention => 'Screenshot Prevention';

  @override
  String get screenshotPreventionSubtitle =>
      'Prevent screen capture in the app';

  @override
  String get restartRequired => 'Changes will take effect after restart';

  @override
  String get clipboardAutoClear => 'Auto Clear Clipboard';

  @override
  String clipboardAutoClearEnabled(int seconds) {
    return 'Clear clipboard after $seconds seconds';
  }

  @override
  String get clipboardTimeout => 'Clipboard Clear Timeout';

  @override
  String get selectClipboardTimeout => 'Select clipboard clear timeout';

  @override
  String get securityStatus => 'Security Status';

  @override
  String get deviceStatus => 'Device Status';

  @override
  String get deviceSecure => 'Device is secure';

  @override
  String get deviceRooted => 'Device is Rooted/Jailbroken';

  @override
  String get developerModeEnabled => 'Developer Mode is enabled';

  @override
  String get securityDetails => 'Security Details';

  @override
  String get appIntegrity => 'App Integrity';

  @override
  String get appIntegritySafe => 'App is running in a safe environment';

  @override
  String appIntegrityWarnings(int count) {
    return '$count warnings found';
  }

  @override
  String get rootJailbreak => 'Root/Jailbreak';

  @override
  String get developerMode => 'Developer Mode';

  @override
  String get emulator => 'Emulator';

  @override
  String get externalStorage => 'App installed on External Storage';

  @override
  String get debugMode => 'Debug Mode';

  @override
  String get detected => 'Detected';

  @override
  String get notDetected => 'Not Detected';

  @override
  String get warnings => 'Warnings';

  @override
  String get trash => 'Trash';

  @override
  String get trashSubtitle => 'View and restore deleted files';

  @override
  String get backup => 'Backup';

  @override
  String get backupSubtitle => 'Export/Import all data';

  @override
  String get versionInfo => 'Version';

  @override
  String get securityFeatures => 'Security Features';

  @override
  String get securityFeaturesSubtitle => 'AES-256-GCM + Argon2id (or PBKDF2)';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle =>
      'Data is encrypted and stored locally only';

  @override
  String get appLockSettings => 'App Lock Settings';

  @override
  String get pinEnabled => 'PIN enabled';

  @override
  String get pinNotSet => 'PIN not set';

  @override
  String get lockAppNow => 'Lock App Now';

  @override
  String get lockAppNowSubtitle => 'Lock app and show PIN screen';

  @override
  String get encryption => 'Encryption';

  @override
  String get encryptionAES => 'AES-256-GCM (Military grade)';

  @override
  String get encryptionArgon2 =>
      'Argon2id Key Derivation (GPU attack resistant)';

  @override
  String get encryptionPBKDF2 =>
      'PBKDF2 100,000 iterations (for legacy vaults)';

  @override
  String get protection => 'Protection';

  @override
  String get protectionRoot => 'Root/Jailbreak detection';

  @override
  String get protectionEmulator => 'Emulator and Debug mode detection';

  @override
  String get protectionScreenshot => 'Screenshot prevention';

  @override
  String get protectionClipboard => 'Auto clipboard clear';

  @override
  String get protectionBackground => 'Lock on background';

  @override
  String get storage => 'Storage';

  @override
  String get storageKeystore => 'Hardware Keystore (Android/iOS)';

  @override
  String get storageEncrypted => 'Encrypted Shared Preferences';

  @override
  String get storageNoServer => 'No data sent to server';

  @override
  String get specialFeatures => 'Special Features';

  @override
  String get featureSecureKeyboard => 'Secure Keyboard (no logging)';

  @override
  String get featureDecoyVault => 'Decoy Vault (fake vault)';

  @override
  String get featureObfuscation => 'Code Obfuscation';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyInfo1 => 'All files are encrypted with AES-256-GCM';

  @override
  String get privacyInfo2 => 'Passwords processed with PBKDF2 100,000 rounds';

  @override
  String get privacyInfo3 => 'All data stored locally on your device only';

  @override
  String get privacyInfo4 => 'No data sent to server';

  @override
  String get privacyInfo5 => 'No tracking or behavior analysis';

  @override
  String get privacyInfo6 => 'No ads';

  @override
  String get privacyWarning =>
      'If you forget your password, data cannot be recovered';

  @override
  String get understood => 'Understood';

  @override
  String get securityWarning => 'Security Warning';

  @override
  String get unsafeEnvironment => 'Potentially unsafe environment detected:';

  @override
  String get appStillUsable =>
      'App can still be used, but data may be at risk.\nRecommended to use on non-rooted/jailbroken device';

  @override
  String get exitApp => 'Exit App';

  @override
  String get continueAnyway => 'Continue';

  @override
  String seconds(int count) {
    return '$count seconds';
  }

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String hours(int count) {
    return '$count hours';
  }

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get share => 'Share';

  @override
  String get restore => 'Restore';

  @override
  String get pinLock => 'PIN Lock';

  @override
  String get enterPinToUnlock => 'Enter PIN to unlock';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get enterNewPin => 'Enter new PIN';

  @override
  String get confirmNewPin => 'Confirm new PIN';

  @override
  String get createPin => 'Create PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get pinMismatch => 'PINs do not match';

  @override
  String get pinChanged => 'PIN changed successfully';

  @override
  String get pinCreated => 'PIN created successfully';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String useBiometric(String type) {
    return 'Use $type';
  }

  @override
  String attemptsRemaining(int count) {
    return '$count attempts remaining';
  }

  @override
  String get tooManyAttempts => 'Too many failed attempts';

  @override
  String tryAgainIn(int seconds) {
    return 'Try again in $seconds seconds';
  }

  @override
  String get enableAppLock => 'Enable App Lock';

  @override
  String get enableAppLockSubtitle => 'Require PIN when opening app';

  @override
  String get biometricForAppLock => 'Biometric for App Lock';

  @override
  String biometricForAppLockSubtitle(String type) {
    return 'Use $type instead of PIN';
  }

  @override
  String get autoLockTimeout => 'Auto Lock Timeout';

  @override
  String lockAfterBackground(String time) {
    return 'Lock after $time in background';
  }

  @override
  String get immediately => 'Immediately';

  @override
  String get setupPin => 'Setup PIN';

  @override
  String get resetPin => 'Reset PIN';

  @override
  String get setPinFirst => 'Please set PIN first';

  @override
  String get backupTitle => 'Backup Data';

  @override
  String get backupInfo => 'About Backup';

  @override
  String get backupInfo1 =>
      'Backup file includes all Vaults, Folders and files';

  @override
  String get backupInfo2 => 'Files remain encrypted, safe to share to Cloud';

  @override
  String get backupInfo3 => 'Can set additional password for security';

  @override
  String get backupInfo4 => 'Recommended to backup regularly';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get setBackupPassword => 'Set Backup Password';

  @override
  String get setBackupPasswordSubtitle =>
      'Encrypt backup file with additional password';

  @override
  String get password => 'Password';

  @override
  String get enterBackupPassword => 'Enter password for backup';

  @override
  String get creating => 'Creating...';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get selectBackupFile => 'Select .svbackup file to restore';

  @override
  String get duplicateVaultWarning =>
      'If restored Vault has same name as existing, it will be skipped';

  @override
  String get selectBackupFileButton => 'Select Backup File';

  @override
  String get restoring => 'Restoring...';

  @override
  String get backupCreatedSuccess => 'Backup Created Successfully!';

  @override
  String get vaults => 'Vaults';

  @override
  String get files => 'Files';

  @override
  String get folders => 'Folders';

  @override
  String get fileSize => 'File Size';

  @override
  String get selectSaveMethod => 'Select how to save backup file:';

  @override
  String get restoreSuccess => 'Restore Successful!';

  @override
  String get vaultsRestored => 'Vaults restored';

  @override
  String get filesRestored => 'Files restored';

  @override
  String get foldersRestored => 'Folders restored';

  @override
  String get enterBackupPasswordPrompt => 'Enter Backup Password';

  @override
  String get backupInfoTitle => 'Backup Info';

  @override
  String get createdAt => 'Created at';

  @override
  String get device => 'Device';

  @override
  String get vaultCount => 'Vault count';

  @override
  String get fileCount => 'File count';

  @override
  String get folderCount => 'Folder count';

  @override
  String get passwordProtected => 'Password';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get duplicateSkipped => 'Duplicate Vault will be skipped';

  @override
  String get noVaultsToBackup => 'No Vaults to backup';

  @override
  String get backupFailed => 'Backup creation failed';

  @override
  String get fileNotFound => 'Backup file not found';

  @override
  String get wrongPasswordOrCorrupt => 'Wrong password or file is corrupted';

  @override
  String get backupCorruptOrNeedsPassword =>
      'Backup file corrupted or needs password';

  @override
  String get invalidBackupNoMetadata => 'Invalid backup file (no metadata)';

  @override
  String get invalidBackupNoVaults => 'Invalid backup file (no vaults data)';

  @override
  String get invalidBackupNoFiles => 'Invalid backup file (no files data)';

  @override
  String get backupNeedsPassword => 'This backup requires password';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String vaultReplaced(String name) {
    return 'Vault \"$name\" was replaced';
  }

  @override
  String vaultSkipped(String name) {
    return 'Skipped Vault \"$name\" as it already exists';
  }

  @override
  String get folderSkippedNoVault => 'Skipped folder as vault not found';

  @override
  String get fileSkippedNoVault => 'Skipped file as vault not found';

  @override
  String encryptedFileNotFound(int id) {
    return 'Encrypted file not found for file ID $id';
  }

  @override
  String get passwordMinLength => 'Password must be at least 4 characters';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get fileSaved => 'File saved successfully';

  @override
  String get preparing => 'Preparing data...';

  @override
  String get creatingBackupFile => 'Creating backup file...';

  @override
  String get backingUpVaults => 'Backing up vaults...';

  @override
  String get backingUpFileData => 'Backing up file data...';

  @override
  String get backingUpEncryptedFiles => 'Backing up encrypted files...';

  @override
  String backingUpFile(int current, int total) {
    return 'Backing up file ($current/$total)...';
  }

  @override
  String get compressing => 'Compressing data...';

  @override
  String get encrypting => 'Encrypting backup...';

  @override
  String get done => 'Done!';

  @override
  String get readingBackup => 'Reading backup file...';

  @override
  String get decrypting => 'Decrypting backup...';

  @override
  String get extracting => 'Extracting files...';

  @override
  String get restoringVaults => 'Restoring vaults...';

  @override
  String get restoringFolders => 'Restoring folders...';

  @override
  String get restoringFiles => 'Restoring files...';

  @override
  String restoringFile(int current, int total) {
    return 'Restoring file ($current/$total)...';
  }

  @override
  String get vaultList => 'My Vaults';

  @override
  String get createVault => 'Create Vault';

  @override
  String get openVault => 'Open Vault';

  @override
  String get deleteVault => 'Delete Vault';

  @override
  String get vaultName => 'Vault Name';

  @override
  String get vaultPassword => 'Vault Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterVaultName => 'e.g. Personal Files, Photos';

  @override
  String get enterVaultPassword => 'Enter vault password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get vaultCreated => 'Vault created successfully';

  @override
  String get vaultDeleted => 'Vault deleted successfully';

  @override
  String get enterPasswordToOpen => 'Enter password to open vault';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get noVaults => 'No vaults yet';

  @override
  String get createFirstVault => 'Create your first vault to get started';

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
  String get fileManager => 'File Manager';

  @override
  String get addFiles => 'Add Files';

  @override
  String get addImages => 'Add Images';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get createFolder => 'Create Folder';

  @override
  String get folderName => 'Folder Name';

  @override
  String get enterFolderName => 'Enter folder name';

  @override
  String get folderCreated => 'Folder created successfully';

  @override
  String get deleteFolder => 'Delete Folder';

  @override
  String get folderDeleted => 'Folder deleted successfully';

  @override
  String get moveToFolder => 'Move to Folder';

  @override
  String get root => 'Root';

  @override
  String get moveTo => 'Move to';

  @override
  String get movedToFolder => 'Moved to folder successfully';

  @override
  String get search => 'Search';

  @override
  String get searchFiles => 'Search files...';

  @override
  String get noFilesFound => 'No files found';

  @override
  String get noFoldersFound => 'No folders found';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortNameAZ => 'Name A-Z';

  @override
  String get sortNameZA => 'Name Z-A';

  @override
  String get sortSizeSmall => 'Size: Smallest';

  @override
  String get sortSizeLarge => 'Size: Largest';

  @override
  String get filterBy => 'Filter by';

  @override
  String get filterAll => 'All';

  @override
  String get filterImages => 'Images';

  @override
  String get filterDocuments => 'Documents';

  @override
  String get filterVideos => 'Videos';

  @override
  String get filterAudio => 'Audio';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get moveSelected => 'Move Selected';

  @override
  String get downloadSelected => 'Download Selected';

  @override
  String get fileDeleted => 'File deleted';

  @override
  String get fileRestored => 'File restored';

  @override
  String get movedToTrash => 'Moved to trash';

  @override
  String get permanentDelete => 'Permanently Delete';

  @override
  String get permanentDeleteWarning =>
      'This action cannot be undone. The file will be permanently deleted.';

  @override
  String daysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String get emptyTrash => 'Empty Trash';

  @override
  String get emptyTrashWarning =>
      'This will permanently delete all files in trash. This action cannot be undone.';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get restoreAll => 'Restore All';

  @override
  String get allRestored => 'All files restored';

  @override
  String get trashEmptied => 'Trash emptied';

  @override
  String get fileDetails => 'File Details';

  @override
  String get fileName => 'File Name';

  @override
  String get fileType => 'File Type';

  @override
  String get created => 'Created';

  @override
  String get modified => 'Modified';

  @override
  String get size => 'Size';

  @override
  String get download => 'Download';

  @override
  String get downloadComplete => 'Download complete';

  @override
  String get decoyVault => 'Decoy Vault';

  @override
  String get decoyVaultSubtitle =>
      'Create a fake vault with different password';

  @override
  String get decoyVaultEnabled => 'Decoy Vault enabled';

  @override
  String get decoyVaultPassword => 'Decoy Password';

  @override
  String get decoyVaultInfo => 'Enter decoy password to open fake vault';

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
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get success => 'Success';

  @override
  String get biometricFingerprint => 'Fingerprint';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricIris => 'Iris';

  @override
  String get biometricGeneric => 'Biometric';

  @override
  String get unlock => 'Unlock';

  @override
  String get setupPinTitle => 'Setup PIN';

  @override
  String get confirmPinTitle => 'Confirm PIN';

  @override
  String get confirmNewPinTitle => 'Confirm New PIN';

  @override
  String get enterCurrentPinTitle => 'Enter Current PIN';

  @override
  String get verifyIdentity => 'Verify Identity';

  @override
  String get enter6DigitPinToUnlock => 'Enter 6-digit PIN to open the app';

  @override
  String get enter6DigitPinToSetup => 'Create a 6-digit PIN for security';

  @override
  String get enterPinAgainToConfirm => 'Enter PIN again to confirm';

  @override
  String get enterNewPinAgain => 'Enter new PIN again';

  @override
  String get enterYourCurrentPin => 'Enter your current PIN';

  @override
  String get enterPinToContinue => 'Enter PIN to continue';

  @override
  String get pinSetupSuccess => 'PIN setup successful';

  @override
  String get pinSetupFailed => 'Unable to setup PIN';

  @override
  String get pinUsedToUnlock => 'PIN will be used to unlock the app';

  @override
  String waitMinutes(int minutes) {
    return 'Wait $minutes minutes then try again';
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
