// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '安全保险库';

  @override
  String get appTagline => '安全保护您的文件';

  @override
  String get loading => '加载中...';

  @override
  String get securityCheck => '安全检查中...';

  @override
  String get enterPin => '请输入PIN码';

  @override
  String get enteringApp => '正在进入应用...';

  @override
  String get version => '版本';

  @override
  String get settings => '设置';

  @override
  String get security => '安全';

  @override
  String get data => '数据';

  @override
  String get about => '关于';

  @override
  String get account => '账户';

  @override
  String biometricUnlock(String type) {
    return '使用$type解锁';
  }

  @override
  String get biometricSubtitle => '使用指纹或Face ID打开保险库';

  @override
  String get autoLock => '自动锁定';

  @override
  String autoLockEnabled(String time) {
    return '$time无操作后锁定保险库';
  }

  @override
  String get autoLockDisabled => '已禁用';

  @override
  String get lockTimeout => '锁定超时';

  @override
  String get selectAutoLockTimeout => '选择自动锁定超时时间';

  @override
  String get lockOnBackground => '后台锁定';

  @override
  String get lockOnBackgroundSubtitle => '切换到其他应用时立即锁定保险库';

  @override
  String get screenshotPrevention => '防截屏';

  @override
  String get screenshotPreventionSubtitle => '防止在应用内截屏';

  @override
  String get restartRequired => '更改将在重启后生效';

  @override
  String get clipboardAutoClear => '自动清除剪贴板';

  @override
  String clipboardAutoClearEnabled(int seconds) {
    return '复制后$seconds秒清除剪贴板';
  }

  @override
  String get clipboardTimeout => '剪贴板清除超时';

  @override
  String get selectClipboardTimeout => '选择剪贴板清除超时时间';

  @override
  String get securityStatus => '安全状态';

  @override
  String get deviceStatus => '设备状态';

  @override
  String get deviceSecure => '设备安全';

  @override
  String get deviceRooted => '设备已Root/越狱';

  @override
  String get developerModeEnabled => '开发者模式已启用';

  @override
  String get securityDetails => '安全详情';

  @override
  String get appIntegrity => '应用完整性';

  @override
  String get appIntegritySafe => '应用运行在安全环境中';

  @override
  String appIntegrityWarnings(int count) {
    return '发现$count个警告';
  }

  @override
  String get rootJailbreak => 'Root/越狱';

  @override
  String get developerMode => '开发者模式';

  @override
  String get emulator => '模拟器';

  @override
  String get externalStorage => '应用安装在外部存储';

  @override
  String get debugMode => '调试模式';

  @override
  String get detected => '已检测到';

  @override
  String get notDetected => '未检测到';

  @override
  String get warnings => '警告';

  @override
  String get trash => '回收站';

  @override
  String get trashSubtitle => '查看和恢复已删除的文件';

  @override
  String get backup => '备份';

  @override
  String get backupSubtitle => '导出/导入所有数据';

  @override
  String get versionInfo => '版本';

  @override
  String get securityFeatures => '安全功能';

  @override
  String get securityFeaturesSubtitle => 'AES-256-GCM + Argon2id（或PBKDF2）';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicySubtitle => '数据已加密并仅存储在本地';

  @override
  String get appLockSettings => '应用锁设置';

  @override
  String get pinEnabled => 'PIN已启用';

  @override
  String get pinNotSet => 'PIN未设置';

  @override
  String get lockAppNow => '立即锁定应用';

  @override
  String get lockAppNowSubtitle => '锁定应用并显示PIN屏幕';

  @override
  String get encryption => '加密';

  @override
  String get encryptionAES => 'AES-256-GCM（军事级别）';

  @override
  String get encryptionArgon2 => 'Argon2id密钥派生（抵抗GPU攻击）';

  @override
  String get encryptionPBKDF2 => 'PBKDF2 100,000次迭代（用于旧保险库）';

  @override
  String get protection => '保护';

  @override
  String get protectionRoot => 'Root/越狱检测';

  @override
  String get protectionEmulator => '模拟器和调试模式检测';

  @override
  String get protectionScreenshot => '防截屏';

  @override
  String get protectionClipboard => '自动清除剪贴板';

  @override
  String get protectionBackground => '后台锁定';

  @override
  String get storage => '存储';

  @override
  String get storageKeystore => '硬件密钥库（Android/iOS）';

  @override
  String get storageEncrypted => '加密共享首选项';

  @override
  String get storageNoServer => '数据不发送到服务器';

  @override
  String get specialFeatures => '特殊功能';

  @override
  String get featureSecureKeyboard => '安全键盘（无日志记录）';

  @override
  String get featureDecoyVault => '伪装保险库（假保险库）';

  @override
  String get featureObfuscation => '代码混淆';

  @override
  String get privacyTitle => '隐私';

  @override
  String get privacyInfo1 => '所有文件使用AES-256-GCM加密';

  @override
  String get privacyInfo2 => '密码使用PBKDF2进行100,000轮处理';

  @override
  String get privacyInfo3 => '所有数据仅存储在您的设备上';

  @override
  String get privacyInfo4 => '数据不发送到服务器';

  @override
  String get privacyInfo5 => '无跟踪或行为分析';

  @override
  String get privacyInfo6 => '无广告';

  @override
  String get privacyWarning => '如果忘记密码，数据将无法恢复';

  @override
  String get understood => '我明白了';

  @override
  String get securityWarning => '安全警告';

  @override
  String get unsafeEnvironment => '检测到可能不安全的环境：';

  @override
  String get appStillUsable => '应用仍可使用，但数据可能存在风险。\n建议在未Root/越狱的设备上使用';

  @override
  String get exitApp => '退出应用';

  @override
  String get continueAnyway => '继续';

  @override
  String seconds(int count) {
    return '$count秒';
  }

  @override
  String minutes(int count) {
    return '$count分钟';
  }

  @override
  String hours(int count) {
    return '$count小时';
  }

  @override
  String get close => '关闭';

  @override
  String get cancel => '取消';

  @override
  String get ok => '确定';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get share => '分享';

  @override
  String get restore => '恢复';

  @override
  String get pinLock => 'PIN锁';

  @override
  String get enterPinToUnlock => '输入PIN解锁';

  @override
  String get enterCurrentPin => '输入当前PIN';

  @override
  String get enterNewPin => '输入新PIN';

  @override
  String get confirmNewPin => '确认新PIN';

  @override
  String get createPin => '创建PIN';

  @override
  String get changePin => '更改PIN';

  @override
  String get wrongPin => 'PIN错误';

  @override
  String get pinMismatch => 'PIN不匹配';

  @override
  String get pinChanged => 'PIN更改成功';

  @override
  String get pinCreated => 'PIN创建成功';

  @override
  String get forgotPin => '忘记PIN？';

  @override
  String useBiometric(String type) {
    return '使用$type';
  }

  @override
  String attemptsRemaining(int count) {
    return '剩余$count次尝试';
  }

  @override
  String get tooManyAttempts => '尝试次数过多';

  @override
  String tryAgainIn(int seconds) {
    return '$seconds秒后重试';
  }

  @override
  String get enableAppLock => '启用应用锁';

  @override
  String get enableAppLockSubtitle => '打开应用时需要PIN';

  @override
  String get biometricForAppLock => '生物识别应用锁';

  @override
  String biometricForAppLockSubtitle(String type) {
    return '使用$type代替PIN';
  }

  @override
  String get autoLockTimeout => '自动锁定超时';

  @override
  String lockAfterBackground(String time) {
    return '后台$time后锁定';
  }

  @override
  String get immediately => '立即';

  @override
  String get setupPin => '设置PIN';

  @override
  String get resetPin => '重置PIN';

  @override
  String get setPinFirst => '请先设置PIN';

  @override
  String get backupTitle => '备份数据';

  @override
  String get backupInfo => '关于备份';

  @override
  String get backupInfo1 => '备份文件包含所有保险库、文件夹和文件';

  @override
  String get backupInfo2 => '文件保持加密状态，分享到云端也很安全';

  @override
  String get backupInfo3 => '可以设置额外密码增加安全性';

  @override
  String get backupInfo4 => '建议定期备份';

  @override
  String get createBackup => '创建备份';

  @override
  String get setBackupPassword => '设置备份密码';

  @override
  String get setBackupPasswordSubtitle => '使用额外密码加密备份文件';

  @override
  String get password => '密码';

  @override
  String get enterBackupPassword => '输入备份密码';

  @override
  String get creating => '创建中...';

  @override
  String get restoreFromBackup => '从备份恢复';

  @override
  String get selectBackupFile => '选择.svbackup文件进行恢复';

  @override
  String get duplicateVaultWarning => '如果恢复的保险库与现有保险库同名，将跳过该保险库';

  @override
  String get selectBackupFileButton => '选择备份文件';

  @override
  String get restoring => '恢复中...';

  @override
  String get backupCreatedSuccess => '备份创建成功！';

  @override
  String get vaults => '保险库';

  @override
  String get files => '文件';

  @override
  String get folders => '文件夹';

  @override
  String get fileSize => '文件大小';

  @override
  String get selectSaveMethod => '选择保存备份文件的方式：';

  @override
  String get restoreSuccess => '恢复成功！';

  @override
  String get vaultsRestored => '已恢复的保险库';

  @override
  String get filesRestored => '已恢复的文件';

  @override
  String get foldersRestored => '已恢复的文件夹';

  @override
  String get enterBackupPasswordPrompt => '输入备份密码';

  @override
  String get backupInfoTitle => '备份信息';

  @override
  String get createdAt => '创建时间';

  @override
  String get device => '设备';

  @override
  String get vaultCount => '保险库数量';

  @override
  String get fileCount => '文件数量';

  @override
  String get folderCount => '文件夹数量';

  @override
  String get passwordProtected => '密码';

  @override
  String get yes => '有';

  @override
  String get no => '无';

  @override
  String get duplicateSkipped => '同名保险库将被跳过';

  @override
  String get noVaultsToBackup => '没有可备份的保险库';

  @override
  String get backupFailed => '备份创建失败';

  @override
  String get fileNotFound => '找不到备份文件';

  @override
  String get wrongPasswordOrCorrupt => '密码错误或文件已损坏';

  @override
  String get backupCorruptOrNeedsPassword => '备份文件已损坏或需要密码';

  @override
  String get invalidBackupNoMetadata => '无效的备份文件（无元数据）';

  @override
  String get invalidBackupNoVaults => '无效的备份文件（无保险库数据）';

  @override
  String get invalidBackupNoFiles => '无效的备份文件（无文件数据）';

  @override
  String get backupNeedsPassword => '此备份需要密码';

  @override
  String get restoreFailed => '恢复失败';

  @override
  String vaultReplaced(String name) {
    return '保险库\"$name\"已被替换';
  }

  @override
  String vaultSkipped(String name) {
    return '跳过保险库\"$name\"，因为它已存在';
  }

  @override
  String get folderSkippedNoVault => '跳过文件夹，因为找不到保险库';

  @override
  String get fileSkippedNoVault => '跳过文件，因为找不到保险库';

  @override
  String encryptedFileNotFound(int id) {
    return '找不到文件ID $id的加密文件';
  }

  @override
  String get passwordMinLength => '密码至少需要4个字符';

  @override
  String get pleaseEnterPassword => '请输入密码';

  @override
  String get fileSaved => '文件保存成功';

  @override
  String get preparing => '准备数据中...';

  @override
  String get creatingBackupFile => '创建备份文件中...';

  @override
  String get backingUpVaults => '备份保险库中...';

  @override
  String get backingUpFileData => '备份文件数据中...';

  @override
  String get backingUpEncryptedFiles => '备份加密文件中...';

  @override
  String backingUpFile(int current, int total) {
    return '备份文件中（$current/$total）...';
  }

  @override
  String get compressing => '压缩数据中...';

  @override
  String get encrypting => '加密备份中...';

  @override
  String get done => '完成！';

  @override
  String get readingBackup => '读取备份文件中...';

  @override
  String get decrypting => '解密备份中...';

  @override
  String get extracting => '解压文件中...';

  @override
  String get restoringVaults => '恢复保险库中...';

  @override
  String get restoringFolders => '恢复文件夹中...';

  @override
  String get restoringFiles => '恢复文件中...';

  @override
  String restoringFile(int current, int total) {
    return '恢复文件中（$current/$total）...';
  }

  @override
  String get vaultList => '我的保险库';

  @override
  String get createVault => '创建保险库';

  @override
  String get openVault => '打开保险库';

  @override
  String get deleteVault => '删除保险库';

  @override
  String get vaultName => '保险库名称';

  @override
  String get vaultPassword => '保险库密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get enterVaultName => '输入保险库名称';

  @override
  String get enterVaultPassword => '输入保险库密码';

  @override
  String get passwordMismatch => '密码不匹配';

  @override
  String get vaultCreated => '保险库创建成功';

  @override
  String get vaultDeleted => '保险库删除成功';

  @override
  String get enterPasswordToOpen => '输入密码打开保险库';

  @override
  String get wrongPassword => '密码错误';

  @override
  String get noVaults => '还没有保险库';

  @override
  String get createFirstVault => '创建您的第一个保险库开始使用';

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
  String get fileManager => '文件管理器';

  @override
  String get addFiles => '添加文件';

  @override
  String get addImages => '添加图片';

  @override
  String get takePhoto => '拍照';

  @override
  String get createFolder => '创建文件夹';

  @override
  String get folderName => '文件夹名称';

  @override
  String get enterFolderName => '输入文件夹名称';

  @override
  String get folderCreated => '文件夹创建成功';

  @override
  String get deleteFolder => '删除文件夹';

  @override
  String get folderDeleted => '文件夹删除成功';

  @override
  String get moveToFolder => '移动到文件夹';

  @override
  String get root => '根目录';

  @override
  String get moveTo => '移动到';

  @override
  String get movedToFolder => '移动到文件夹成功';

  @override
  String get search => '搜索';

  @override
  String get searchFiles => '搜索文件...';

  @override
  String get noFilesFound => '未找到文件';

  @override
  String get noFoldersFound => '未找到文件夹';

  @override
  String get sortBy => '排序方式';

  @override
  String get sortNewest => '最新';

  @override
  String get sortOldest => '最旧';

  @override
  String get sortNameAZ => '名称 A-Z';

  @override
  String get sortNameZA => '名称 Z-A';

  @override
  String get sortSizeSmall => '大小：最小';

  @override
  String get sortSizeLarge => '大小：最大';

  @override
  String get filterBy => '筛选';

  @override
  String get filterAll => '全部';

  @override
  String get filterImages => '图片';

  @override
  String get filterDocuments => '文档';

  @override
  String get filterVideos => '视频';

  @override
  String get filterAudio => '音频';

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String selectedCount(int count) {
    return '已选$count项';
  }

  @override
  String get deleteSelected => '删除选中项';

  @override
  String get moveSelected => '移动选中项';

  @override
  String get downloadSelected => '下载选中项';

  @override
  String get fileDeleted => '文件已删除';

  @override
  String get fileRestored => '文件已恢复';

  @override
  String get movedToTrash => '已移至回收站';

  @override
  String get permanentDelete => '永久删除';

  @override
  String get permanentDeleteWarning => '此操作无法撤销。文件将被永久删除。';

  @override
  String daysRemaining(int count) {
    return '剩余$count天';
  }

  @override
  String get emptyTrash => '清空回收站';

  @override
  String get emptyTrashWarning => '这将永久删除回收站中的所有文件。此操作无法撤销。';

  @override
  String get trashEmpty => '回收站为空';

  @override
  String get restoreAll => '全部恢复';

  @override
  String get allRestored => '所有文件已恢复';

  @override
  String get trashEmptied => '回收站已清空';

  @override
  String get fileDetails => '文件详情';

  @override
  String get fileName => '文件名';

  @override
  String get fileType => '文件类型';

  @override
  String get created => '创建时间';

  @override
  String get modified => '修改时间';

  @override
  String get size => '大小';

  @override
  String get download => '下载';

  @override
  String get downloadComplete => '下载完成';

  @override
  String get decoyVault => '伪装保险库';

  @override
  String get decoyVaultSubtitle => '使用不同密码创建假保险库';

  @override
  String get decoyVaultEnabled => '伪装保险库已启用';

  @override
  String get decoyVaultPassword => '伪装密码';

  @override
  String get decoyVaultInfo => '输入伪装密码打开假保险库';

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
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageChanged => '语言已更改';

  @override
  String get error => '错误';

  @override
  String get errorOccurred => '发生错误';

  @override
  String get tryAgain => '重试';

  @override
  String get success => '成功';

  @override
  String get biometricFingerprint => '指纹';

  @override
  String get biometricFaceId => '面容ID';

  @override
  String get biometricIris => '虹膜';

  @override
  String get biometricGeneric => '生物识别';

  @override
  String get unlock => '解锁';

  @override
  String get setupPinTitle => '设置PIN';

  @override
  String get confirmPinTitle => '确认PIN';

  @override
  String get confirmNewPinTitle => '确认新PIN';

  @override
  String get enterCurrentPinTitle => '输入当前PIN';

  @override
  String get verifyIdentity => '验证身份';

  @override
  String get enter6DigitPinToUnlock => '输入6位PIN码打开应用';

  @override
  String get enter6DigitPinToSetup => '创建6位PIN码以确保安全';

  @override
  String get enterPinAgainToConfirm => '再次输入PIN码以确认';

  @override
  String get enterNewPinAgain => '再次输入新PIN码';

  @override
  String get enterYourCurrentPin => '输入您当前的PIN码';

  @override
  String get enterPinToContinue => '输入PIN码以继续';

  @override
  String get pinSetupSuccess => 'PIN设置成功';

  @override
  String get pinSetupFailed => '无法设置PIN';

  @override
  String get pinUsedToUnlock => 'PIN将用于解锁应用';

  @override
  String waitMinutes(int minutes) {
    return '等待$minutes分钟后重试';
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
