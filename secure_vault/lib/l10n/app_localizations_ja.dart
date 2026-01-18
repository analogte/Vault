// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class SJa extends S {
  SJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'セキュアボルト';

  @override
  String get appTagline => 'ファイルを安全に保護';

  @override
  String get loading => '読み込み中...';

  @override
  String get securityCheck => 'セキュリティチェック中...';

  @override
  String get enterPin => 'PINを入力してください';

  @override
  String get enteringApp => 'アプリに入っています...';

  @override
  String get version => 'バージョン';

  @override
  String get settings => '設定';

  @override
  String get security => 'セキュリティ';

  @override
  String get data => 'データ';

  @override
  String get about => 'アプリについて';

  @override
  String get account => 'アカウント';

  @override
  String biometricUnlock(String type) {
    return '$typeでロック解除';
  }

  @override
  String get biometricSubtitle => '指紋またはFace IDでボルトを開く';

  @override
  String get autoLock => '自動ロック';

  @override
  String autoLockEnabled(String time) {
    return '$time無操作後にボルトをロック';
  }

  @override
  String get autoLockDisabled => '無効';

  @override
  String get lockTimeout => 'ロックタイムアウト';

  @override
  String get selectAutoLockTimeout => '自動ロックタイムアウトを選択';

  @override
  String get lockOnBackground => 'バックグラウンドでロック';

  @override
  String get lockOnBackgroundSubtitle => '他のアプリに切り替えるとすぐにボルトをロック';

  @override
  String get screenshotPrevention => 'スクリーンショット防止';

  @override
  String get screenshotPreventionSubtitle => 'アプリ内でのスクリーンショットを防止';

  @override
  String get restartRequired => '変更は再起動後に有効になります';

  @override
  String get clipboardAutoClear => 'クリップボード自動クリア';

  @override
  String clipboardAutoClearEnabled(int seconds) {
    return 'コピー後$seconds秒でクリップボードをクリア';
  }

  @override
  String get clipboardTimeout => 'クリップボードクリアタイムアウト';

  @override
  String get selectClipboardTimeout => 'クリップボードクリアタイムアウトを選択';

  @override
  String get securityStatus => 'セキュリティ状態';

  @override
  String get deviceStatus => 'デバイス状態';

  @override
  String get deviceSecure => 'デバイスは安全です';

  @override
  String get deviceRooted => 'デバイスはRoot/脱獄されています';

  @override
  String get developerModeEnabled => '開発者モードが有効です';

  @override
  String get securityDetails => 'セキュリティ詳細';

  @override
  String get appIntegrity => 'アプリの整合性';

  @override
  String get appIntegritySafe => 'アプリは安全な環境で実行されています';

  @override
  String appIntegrityWarnings(int count) {
    return '$count件の警告が見つかりました';
  }

  @override
  String get rootJailbreak => 'Root/脱獄';

  @override
  String get developerMode => '開発者モード';

  @override
  String get emulator => 'エミュレータ';

  @override
  String get externalStorage => 'アプリが外部ストレージにインストールされています';

  @override
  String get debugMode => 'デバッグモード';

  @override
  String get detected => '検出';

  @override
  String get notDetected => '未検出';

  @override
  String get warnings => '警告';

  @override
  String get trash => 'ゴミ箱';

  @override
  String get trashSubtitle => '削除したファイルを表示・復元';

  @override
  String get backup => 'バックアップ';

  @override
  String get backupSubtitle => 'すべてのデータをエクスポート/インポート';

  @override
  String get versionInfo => 'バージョン';

  @override
  String get securityFeatures => 'セキュリティ機能';

  @override
  String get securityFeaturesSubtitle => 'AES-256-GCM + Argon2id（またはPBKDF2）';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get privacyPolicySubtitle => 'データは暗号化されローカルにのみ保存されます';

  @override
  String get appLockSettings => 'アプリロック設定';

  @override
  String get pinEnabled => 'PIN有効';

  @override
  String get pinNotSet => 'PIN未設定';

  @override
  String get lockAppNow => '今すぐアプリをロック';

  @override
  String get lockAppNowSubtitle => 'アプリをロックしてPIN画面を表示';

  @override
  String get encryption => '暗号化';

  @override
  String get encryptionAES => 'AES-256-GCM（軍事レベル）';

  @override
  String get encryptionArgon2 => 'Argon2idキー派生（GPU攻撃耐性）';

  @override
  String get encryptionPBKDF2 => 'PBKDF2 100,000回反復（レガシーボルト用）';

  @override
  String get protection => '保護';

  @override
  String get protectionRoot => 'Root/脱獄検出';

  @override
  String get protectionEmulator => 'エミュレータとデバッグモード検出';

  @override
  String get protectionScreenshot => 'スクリーンショット防止';

  @override
  String get protectionClipboard => 'クリップボード自動クリア';

  @override
  String get protectionBackground => 'バックグラウンドでロック';

  @override
  String get storage => 'ストレージ';

  @override
  String get storageKeystore => 'ハードウェアキーストア（Android/iOS）';

  @override
  String get storageEncrypted => '暗号化された共有設定';

  @override
  String get storageNoServer => 'サーバーにデータを送信しません';

  @override
  String get specialFeatures => '特殊機能';

  @override
  String get featureSecureKeyboard => 'セキュアキーボード（ログなし）';

  @override
  String get featureDecoyVault => 'おとりボルト（偽のボルト）';

  @override
  String get featureObfuscation => 'コード難読化';

  @override
  String get privacyTitle => 'プライバシー';

  @override
  String get privacyInfo1 => 'すべてのファイルはAES-256-GCMで暗号化されています';

  @override
  String get privacyInfo2 => 'パスワードはPBKDF2で100,000回処理されます';

  @override
  String get privacyInfo3 => 'すべてのデータはお使いのデバイスにのみ保存されます';

  @override
  String get privacyInfo4 => 'サーバーにデータを送信しません';

  @override
  String get privacyInfo5 => 'トラッキングや行動分析はありません';

  @override
  String get privacyInfo6 => '広告なし';

  @override
  String get privacyWarning => 'パスワードを忘れると、データを復元できません';

  @override
  String get understood => '理解しました';

  @override
  String get securityWarning => 'セキュリティ警告';

  @override
  String get unsafeEnvironment => '安全でない可能性のある環境が検出されました：';

  @override
  String get appStillUsable =>
      'アプリは引き続き使用できますが、データにリスクがある可能性があります。\nRoot/脱獄されていないデバイスでの使用をお勧めします';

  @override
  String get exitApp => 'アプリを終了';

  @override
  String get continueAnyway => '続行';

  @override
  String seconds(int count) {
    return '$count秒';
  }

  @override
  String minutes(int count) {
    return '$count分';
  }

  @override
  String hours(int count) {
    return '$count時間';
  }

  @override
  String get close => '閉じる';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'OK';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get confirm => '確認';

  @override
  String get share => '共有';

  @override
  String get restore => '復元';

  @override
  String get pinLock => 'PINロック';

  @override
  String get enterPinToUnlock => 'PINを入力してロック解除';

  @override
  String get enterCurrentPin => '現在のPINを入力';

  @override
  String get enterNewPin => '新しいPINを入力';

  @override
  String get confirmNewPin => '新しいPINを確認';

  @override
  String get createPin => 'PINを作成';

  @override
  String get changePin => 'PINを変更';

  @override
  String get wrongPin => 'PINが間違っています';

  @override
  String get pinMismatch => 'PINが一致しません';

  @override
  String get pinChanged => 'PINが変更されました';

  @override
  String get pinCreated => 'PINが作成されました';

  @override
  String get forgotPin => 'PINを忘れた？';

  @override
  String useBiometric(String type) {
    return '$typeを使用';
  }

  @override
  String attemptsRemaining(int count) {
    return '残り$count回';
  }

  @override
  String get tooManyAttempts => '試行回数が多すぎます';

  @override
  String tryAgainIn(int seconds) {
    return '$seconds秒後に再試行してください';
  }

  @override
  String get enableAppLock => 'アプリロックを有効にする';

  @override
  String get enableAppLockSubtitle => 'アプリを開くときにPINが必要';

  @override
  String get biometricForAppLock => 'アプリロック用生体認証';

  @override
  String biometricForAppLockSubtitle(String type) {
    return 'PINの代わりに$typeを使用';
  }

  @override
  String get autoLockTimeout => '自動ロックタイムアウト';

  @override
  String lockAfterBackground(String time) {
    return 'バックグラウンドで$time後にロック';
  }

  @override
  String get immediately => 'すぐに';

  @override
  String get setupPin => 'PINを設定';

  @override
  String get resetPin => 'PINをリセット';

  @override
  String get setPinFirst => '先にPINを設定してください';

  @override
  String get backupTitle => 'データバックアップ';

  @override
  String get backupInfo => 'バックアップについて';

  @override
  String get backupInfo1 => 'バックアップファイルにはすべてのボルト、フォルダ、ファイルが含まれます';

  @override
  String get backupInfo2 => 'ファイルは暗号化されたままなので、クラウドに共有しても安全です';

  @override
  String get backupInfo3 => 'セキュリティのために追加のパスワードを設定できます';

  @override
  String get backupInfo4 => '定期的なバックアップをお勧めします';

  @override
  String get createBackup => 'バックアップを作成';

  @override
  String get setBackupPassword => 'バックアップパスワードを設定';

  @override
  String get setBackupPasswordSubtitle => '追加のパスワードでバックアップファイルを暗号化';

  @override
  String get password => 'パスワード';

  @override
  String get enterBackupPassword => 'バックアップ用パスワードを入力';

  @override
  String get creating => '作成中...';

  @override
  String get restoreFromBackup => 'バックアップから復元';

  @override
  String get selectBackupFile => '.svbackupファイルを選択して復元';

  @override
  String get duplicateVaultWarning => '復元するボルトが既存のものと同名の場合、そのボルトはスキップされます';

  @override
  String get selectBackupFileButton => 'バックアップファイルを選択';

  @override
  String get restoring => '復元中...';

  @override
  String get backupCreatedSuccess => 'バックアップ作成成功！';

  @override
  String get vaults => 'ボルト';

  @override
  String get files => 'ファイル';

  @override
  String get folders => 'フォルダ';

  @override
  String get fileSize => 'ファイルサイズ';

  @override
  String get selectSaveMethod => 'バックアップファイルの保存方法を選択：';

  @override
  String get restoreSuccess => '復元成功！';

  @override
  String get vaultsRestored => '復元されたボルト';

  @override
  String get filesRestored => '復元されたファイル';

  @override
  String get foldersRestored => '復元されたフォルダ';

  @override
  String get enterBackupPasswordPrompt => 'バックアップパスワードを入力';

  @override
  String get backupInfoTitle => 'バックアップ情報';

  @override
  String get createdAt => '作成日時';

  @override
  String get device => 'デバイス';

  @override
  String get vaultCount => 'ボルト数';

  @override
  String get fileCount => 'ファイル数';

  @override
  String get folderCount => 'フォルダ数';

  @override
  String get passwordProtected => 'パスワード';

  @override
  String get yes => 'あり';

  @override
  String get no => 'なし';

  @override
  String get duplicateSkipped => '同名のボルトはスキップされます';

  @override
  String get noVaultsToBackup => 'バックアップするボルトがありません';

  @override
  String get backupFailed => 'バックアップ作成失敗';

  @override
  String get fileNotFound => 'バックアップファイルが見つかりません';

  @override
  String get wrongPasswordOrCorrupt => 'パスワードが間違っているかファイルが破損しています';

  @override
  String get backupCorruptOrNeedsPassword => 'バックアップファイルが破損しているかパスワードが必要です';

  @override
  String get invalidBackupNoMetadata => '無効なバックアップファイル（メタデータなし）';

  @override
  String get invalidBackupNoVaults => '無効なバックアップファイル（ボルトデータなし）';

  @override
  String get invalidBackupNoFiles => '無効なバックアップファイル（ファイルデータなし）';

  @override
  String get backupNeedsPassword => 'このバックアップにはパスワードが必要です';

  @override
  String get restoreFailed => '復元失敗';

  @override
  String vaultReplaced(String name) {
    return 'ボルト「$name」が置き換えられました';
  }

  @override
  String vaultSkipped(String name) {
    return 'ボルト「$name」は既に存在するためスキップされました';
  }

  @override
  String get folderSkippedNoVault => 'ボルトが見つからないためフォルダがスキップされました';

  @override
  String get fileSkippedNoVault => 'ボルトが見つからないためファイルがスキップされました';

  @override
  String encryptedFileNotFound(int id) {
    return 'ファイルID $idの暗号化ファイルが見つかりません';
  }

  @override
  String get passwordMinLength => 'パスワードは4文字以上必要です';

  @override
  String get pleaseEnterPassword => 'パスワードを入力してください';

  @override
  String get fileSaved => 'ファイルが保存されました';

  @override
  String get preparing => 'データを準備中...';

  @override
  String get creatingBackupFile => 'バックアップファイルを作成中...';

  @override
  String get backingUpVaults => 'ボルトをバックアップ中...';

  @override
  String get backingUpFileData => 'ファイルデータをバックアップ中...';

  @override
  String get backingUpEncryptedFiles => '暗号化ファイルをバックアップ中...';

  @override
  String backingUpFile(int current, int total) {
    return 'ファイルをバックアップ中（$current/$total）...';
  }

  @override
  String get compressing => 'データを圧縮中...';

  @override
  String get encrypting => 'バックアップを暗号化中...';

  @override
  String get done => '完了！';

  @override
  String get readingBackup => 'バックアップファイルを読み込み中...';

  @override
  String get decrypting => 'バックアップを復号化中...';

  @override
  String get extracting => 'ファイルを展開中...';

  @override
  String get restoringVaults => 'ボルトを復元中...';

  @override
  String get restoringFolders => 'フォルダを復元中...';

  @override
  String get restoringFiles => 'ファイルを復元中...';

  @override
  String restoringFile(int current, int total) {
    return 'ファイルを復元中（$current/$total）...';
  }

  @override
  String get vaultList => 'マイボルト';

  @override
  String get createVault => 'ボルトを作成';

  @override
  String get openVault => 'ボルトを開く';

  @override
  String get deleteVault => 'ボルトを削除';

  @override
  String get vaultName => 'ボルト名';

  @override
  String get vaultPassword => 'ボルトパスワード';

  @override
  String get confirmPassword => 'パスワードを確認';

  @override
  String get enterVaultName => 'ボルト名を入力';

  @override
  String get enterVaultPassword => 'ボルトパスワードを入力';

  @override
  String get passwordMismatch => 'パスワードが一致しません';

  @override
  String get vaultCreated => 'ボルトが作成されました';

  @override
  String get vaultDeleted => 'ボルトが削除されました';

  @override
  String get enterPasswordToOpen => 'パスワードを入力してボルトを開く';

  @override
  String get wrongPassword => 'パスワードが間違っています';

  @override
  String get noVaults => 'ボルトがまだありません';

  @override
  String get createFirstVault => '最初のボルトを作成して始めましょう';

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
  String get fileManager => 'ファイルマネージャー';

  @override
  String get addFiles => 'ファイルを追加';

  @override
  String get addImages => '画像を追加';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get createFolder => 'フォルダを作成';

  @override
  String get folderName => 'フォルダ名';

  @override
  String get enterFolderName => 'フォルダ名を入力';

  @override
  String get folderCreated => 'フォルダが作成されました';

  @override
  String get deleteFolder => 'フォルダを削除';

  @override
  String get folderDeleted => 'フォルダが削除されました';

  @override
  String get moveToFolder => 'フォルダに移動';

  @override
  String get root => 'ルート';

  @override
  String get moveTo => '移動先';

  @override
  String get movedToFolder => 'フォルダに移動しました';

  @override
  String get search => '検索';

  @override
  String get searchFiles => 'ファイルを検索...';

  @override
  String get noFilesFound => 'ファイルが見つかりません';

  @override
  String get noFoldersFound => 'フォルダが見つかりません';

  @override
  String get sortBy => '並び替え';

  @override
  String get sortNewest => '新しい順';

  @override
  String get sortOldest => '古い順';

  @override
  String get sortNameAZ => '名前 A-Z';

  @override
  String get sortNameZA => '名前 Z-A';

  @override
  String get sortSizeSmall => 'サイズ：小さい順';

  @override
  String get sortSizeLarge => 'サイズ：大きい順';

  @override
  String get filterBy => 'フィルター';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterImages => '画像';

  @override
  String get filterDocuments => 'ドキュメント';

  @override
  String get filterVideos => '動画';

  @override
  String get filterAudio => '音声';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get deselectAll => '選択解除';

  @override
  String selectedCount(int count) {
    return '$count件選択';
  }

  @override
  String get deleteSelected => '選択を削除';

  @override
  String get moveSelected => '選択を移動';

  @override
  String get downloadSelected => '選択をダウンロード';

  @override
  String get fileDeleted => 'ファイルが削除されました';

  @override
  String get fileRestored => 'ファイルが復元されました';

  @override
  String get movedToTrash => 'ゴミ箱に移動しました';

  @override
  String get permanentDelete => '完全に削除';

  @override
  String get permanentDeleteWarning => 'この操作は元に戻せません。ファイルは完全に削除されます。';

  @override
  String daysRemaining(int count) {
    return '残り$count日';
  }

  @override
  String get emptyTrash => 'ゴミ箱を空にする';

  @override
  String get emptyTrashWarning => 'これによりゴミ箱内のすべてのファイルが完全に削除されます。この操作は元に戻せません。';

  @override
  String get trashEmpty => 'ゴミ箱は空です';

  @override
  String get restoreAll => 'すべて復元';

  @override
  String get allRestored => 'すべてのファイルが復元されました';

  @override
  String get trashEmptied => 'ゴミ箱が空になりました';

  @override
  String get fileDetails => 'ファイル詳細';

  @override
  String get fileName => 'ファイル名';

  @override
  String get fileType => 'ファイルタイプ';

  @override
  String get created => '作成日';

  @override
  String get modified => '更新日';

  @override
  String get size => 'サイズ';

  @override
  String get download => 'ダウンロード';

  @override
  String get downloadComplete => 'ダウンロード完了';

  @override
  String get decoyVault => 'おとりボルト';

  @override
  String get decoyVaultSubtitle => '別のパスワードで偽のボルトを作成';

  @override
  String get decoyVaultEnabled => 'おとりボルト有効';

  @override
  String get decoyVaultPassword => 'おとりパスワード';

  @override
  String get decoyVaultInfo => 'おとりパスワードを入力して偽のボルトを開く';

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
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get languageChanged => '言語が変更されました';

  @override
  String get error => 'エラー';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get tryAgain => '再試行';

  @override
  String get success => '成功';

  @override
  String get biometricFingerprint => '指紋';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricIris => '虹彩';

  @override
  String get biometricGeneric => '生体認証';

  @override
  String get unlock => 'ロック解除';

  @override
  String get setupPinTitle => 'PINを設定';

  @override
  String get confirmPinTitle => 'PINを確認';

  @override
  String get confirmNewPinTitle => '新しいPINを確認';

  @override
  String get enterCurrentPinTitle => '現在のPINを入力';

  @override
  String get verifyIdentity => '本人確認';

  @override
  String get enter6DigitPinToUnlock => '6桁のPINを入力してアプリを開く';

  @override
  String get enter6DigitPinToSetup => 'セキュリティのために6桁のPINを作成';

  @override
  String get enterPinAgainToConfirm => '確認のためPINを再入力';

  @override
  String get enterNewPinAgain => '新しいPINを再入力';

  @override
  String get enterYourCurrentPin => '現在のPINを入力してください';

  @override
  String get enterPinToContinue => '続行するにはPINを入力';

  @override
  String get pinSetupSuccess => 'PIN設定完了';

  @override
  String get pinSetupFailed => 'PINを設定できませんでした';

  @override
  String get pinUsedToUnlock => 'PINはアプリのロック解除に使用されます';

  @override
  String waitMinutes(int minutes) {
    return '$minutes分待ってから再試行してください';
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
