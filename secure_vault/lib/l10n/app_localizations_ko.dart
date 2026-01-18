// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class SKo extends S {
  SKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '시큐어 볼트';

  @override
  String get appTagline => '파일을 안전하게 보호하세요';

  @override
  String get loading => '로딩 중...';

  @override
  String get securityCheck => '보안 확인 중...';

  @override
  String get enterPin => 'PIN을 입력하세요';

  @override
  String get enteringApp => '앱 진입 중...';

  @override
  String get version => '버전';

  @override
  String get settings => '설정';

  @override
  String get security => '보안';

  @override
  String get data => '데이터';

  @override
  String get about => '정보';

  @override
  String get account => '계정';

  @override
  String biometricUnlock(String type) {
    return '$type으로 잠금 해제';
  }

  @override
  String get biometricSubtitle => '지문 또는 Face ID로 볼트 열기';

  @override
  String get autoLock => '자동 잠금';

  @override
  String autoLockEnabled(String time) {
    return '$time 후 볼트 잠금';
  }

  @override
  String get autoLockDisabled => '비활성화됨';

  @override
  String get lockTimeout => '잠금 시간';

  @override
  String get selectAutoLockTimeout => '자동 잠금 시간 선택';

  @override
  String get lockOnBackground => '백그라운드에서 잠금';

  @override
  String get lockOnBackgroundSubtitle => '다른 앱으로 전환 시 즉시 볼트 잠금';

  @override
  String get screenshotPrevention => '스크린샷 방지';

  @override
  String get screenshotPreventionSubtitle => '앱 내 스크린샷 방지';

  @override
  String get restartRequired => '변경사항은 재시작 후 적용됩니다';

  @override
  String get clipboardAutoClear => '클립보드 자동 삭제';

  @override
  String clipboardAutoClearEnabled(int seconds) {
    return '복사 후 $seconds초 후 클립보드 삭제';
  }

  @override
  String get clipboardTimeout => '클립보드 삭제 시간';

  @override
  String get selectClipboardTimeout => '클립보드 삭제 시간 선택';

  @override
  String get securityStatus => '보안 상태';

  @override
  String get deviceStatus => '기기 상태';

  @override
  String get deviceSecure => '기기가 안전합니다';

  @override
  String get deviceRooted => '기기가 루팅/탈옥되었습니다';

  @override
  String get developerModeEnabled => '개발자 모드가 활성화되어 있습니다';

  @override
  String get securityDetails => '보안 세부정보';

  @override
  String get appIntegrity => '앱 무결성';

  @override
  String get appIntegritySafe => '앱이 안전한 환경에서 실행 중입니다';

  @override
  String appIntegrityWarnings(int count) {
    return '$count개의 경고가 발견되었습니다';
  }

  @override
  String get rootJailbreak => '루팅/탈옥';

  @override
  String get developerMode => '개발자 모드';

  @override
  String get emulator => '에뮬레이터';

  @override
  String get externalStorage => '앱이 외부 저장소에 설치됨';

  @override
  String get debugMode => '디버그 모드';

  @override
  String get detected => '감지됨';

  @override
  String get notDetected => '감지되지 않음';

  @override
  String get warnings => '경고';

  @override
  String get trash => '휴지통';

  @override
  String get trashSubtitle => '삭제된 파일 보기 및 복원';

  @override
  String get backup => '백업';

  @override
  String get backupSubtitle => '모든 데이터 내보내기/가져오기';

  @override
  String get versionInfo => '버전';

  @override
  String get securityFeatures => '보안 기능';

  @override
  String get securityFeaturesSubtitle => 'AES-256-GCM + Argon2id (또는 PBKDF2)';

  @override
  String get privacyPolicy => '개인정보 보호정책';

  @override
  String get privacyPolicySubtitle => '데이터는 암호화되어 로컬에만 저장됩니다';

  @override
  String get appLockSettings => '앱 잠금 설정';

  @override
  String get pinEnabled => 'PIN 활성화됨';

  @override
  String get pinNotSet => 'PIN 설정되지 않음';

  @override
  String get lockAppNow => '지금 앱 잠금';

  @override
  String get lockAppNowSubtitle => '앱을 잠그고 PIN 화면 표시';

  @override
  String get encryption => '암호화';

  @override
  String get encryptionAES => 'AES-256-GCM (군사 등급)';

  @override
  String get encryptionArgon2 => 'Argon2id 키 파생 (GPU 공격 저항)';

  @override
  String get encryptionPBKDF2 => 'PBKDF2 100,000회 반복 (레거시 볼트용)';

  @override
  String get protection => '보호';

  @override
  String get protectionRoot => '루팅/탈옥 감지';

  @override
  String get protectionEmulator => '에뮬레이터 및 디버그 모드 감지';

  @override
  String get protectionScreenshot => '스크린샷 방지';

  @override
  String get protectionClipboard => '클립보드 자동 삭제';

  @override
  String get protectionBackground => '백그라운드에서 잠금';

  @override
  String get storage => '저장소';

  @override
  String get storageKeystore => '하드웨어 키스토어 (Android/iOS)';

  @override
  String get storageEncrypted => '암호화된 공유 환경설정';

  @override
  String get storageNoServer => '서버로 데이터를 전송하지 않음';

  @override
  String get specialFeatures => '특수 기능';

  @override
  String get featureSecureKeyboard => '보안 키보드 (로깅 없음)';

  @override
  String get featureDecoyVault => '가짜 볼트 (미끼 볼트)';

  @override
  String get featureObfuscation => '코드 난독화';

  @override
  String get privacyTitle => '개인정보';

  @override
  String get privacyInfo1 => '모든 파일은 AES-256-GCM으로 암호화됩니다';

  @override
  String get privacyInfo2 => '비밀번호는 PBKDF2로 100,000회 처리됩니다';

  @override
  String get privacyInfo3 => '모든 데이터는 기기에만 저장됩니다';

  @override
  String get privacyInfo4 => '서버로 데이터를 전송하지 않습니다';

  @override
  String get privacyInfo5 => '추적이나 행동 분석이 없습니다';

  @override
  String get privacyInfo6 => '광고 없음';

  @override
  String get privacyWarning => '비밀번호를 잊으면 데이터를 복구할 수 없습니다';

  @override
  String get understood => '이해했습니다';

  @override
  String get securityWarning => '보안 경고';

  @override
  String get unsafeEnvironment => '안전하지 않을 수 있는 환경이 감지되었습니다:';

  @override
  String get appStillUsable =>
      '앱은 계속 사용할 수 있지만 데이터가 위험에 처할 수 있습니다.\n루팅/탈옥되지 않은 기기에서 사용하는 것이 좋습니다';

  @override
  String get exitApp => '앱 종료';

  @override
  String get continueAnyway => '계속';

  @override
  String seconds(int count) {
    return '$count초';
  }

  @override
  String minutes(int count) {
    return '$count분';
  }

  @override
  String hours(int count) {
    return '$count시간';
  }

  @override
  String get close => '닫기';

  @override
  String get cancel => '취소';

  @override
  String get ok => '확인';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get confirm => '확인';

  @override
  String get share => '공유';

  @override
  String get restore => '복원';

  @override
  String get pinLock => 'PIN 잠금';

  @override
  String get enterPinToUnlock => 'PIN을 입력하여 잠금 해제';

  @override
  String get enterCurrentPin => '현재 PIN 입력';

  @override
  String get enterNewPin => '새 PIN 입력';

  @override
  String get confirmNewPin => '새 PIN 확인';

  @override
  String get createPin => 'PIN 만들기';

  @override
  String get changePin => 'PIN 변경';

  @override
  String get wrongPin => 'PIN이 틀렸습니다';

  @override
  String get pinMismatch => 'PIN이 일치하지 않습니다';

  @override
  String get pinChanged => 'PIN이 변경되었습니다';

  @override
  String get pinCreated => 'PIN이 생성되었습니다';

  @override
  String get forgotPin => 'PIN을 잊으셨나요?';

  @override
  String useBiometric(String type) {
    return '$type 사용';
  }

  @override
  String attemptsRemaining(int count) {
    return '$count회 남음';
  }

  @override
  String get tooManyAttempts => '시도 횟수가 너무 많습니다';

  @override
  String tryAgainIn(int seconds) {
    return '$seconds초 후 다시 시도하세요';
  }

  @override
  String get enableAppLock => '앱 잠금 활성화';

  @override
  String get enableAppLockSubtitle => '앱을 열 때 PIN 필요';

  @override
  String get biometricForAppLock => '앱 잠금용 생체 인식';

  @override
  String biometricForAppLockSubtitle(String type) {
    return 'PIN 대신 $type 사용';
  }

  @override
  String get autoLockTimeout => '자동 잠금 시간';

  @override
  String lockAfterBackground(String time) {
    return '백그라운드 $time 후 잠금';
  }

  @override
  String get immediately => '즉시';

  @override
  String get setupPin => 'PIN 설정';

  @override
  String get resetPin => 'PIN 재설정';

  @override
  String get setPinFirst => '먼저 PIN을 설정하세요';

  @override
  String get backupTitle => '데이터 백업';

  @override
  String get backupInfo => '백업 정보';

  @override
  String get backupInfo1 => '백업 파일에는 모든 볼트, 폴더 및 파일이 포함됩니다';

  @override
  String get backupInfo2 => '파일은 암호화된 상태로 유지되어 클라우드에 공유해도 안전합니다';

  @override
  String get backupInfo3 => '보안을 위해 추가 비밀번호를 설정할 수 있습니다';

  @override
  String get backupInfo4 => '정기적으로 백업하는 것이 좋습니다';

  @override
  String get createBackup => '백업 만들기';

  @override
  String get setBackupPassword => '백업 비밀번호 설정';

  @override
  String get setBackupPasswordSubtitle => '추가 비밀번호로 백업 파일 암호화';

  @override
  String get password => '비밀번호';

  @override
  String get enterBackupPassword => '백업 비밀번호 입력';

  @override
  String get creating => '생성 중...';

  @override
  String get restoreFromBackup => '백업에서 복원';

  @override
  String get selectBackupFile => '.svbackup 파일을 선택하여 복원';

  @override
  String get duplicateVaultWarning => '복원하는 볼트가 기존 볼트와 이름이 같으면 건너뜁니다';

  @override
  String get selectBackupFileButton => '백업 파일 선택';

  @override
  String get restoring => '복원 중...';

  @override
  String get backupCreatedSuccess => '백업 생성 완료!';

  @override
  String get vaults => '볼트';

  @override
  String get files => '파일';

  @override
  String get folders => '폴더';

  @override
  String get fileSize => '파일 크기';

  @override
  String get selectSaveMethod => '백업 파일 저장 방법 선택:';

  @override
  String get restoreSuccess => '복원 완료!';

  @override
  String get vaultsRestored => '복원된 볼트';

  @override
  String get filesRestored => '복원된 파일';

  @override
  String get foldersRestored => '복원된 폴더';

  @override
  String get enterBackupPasswordPrompt => '백업 비밀번호 입력';

  @override
  String get backupInfoTitle => '백업 정보';

  @override
  String get createdAt => '생성 시간';

  @override
  String get device => '기기';

  @override
  String get vaultCount => '볼트 수';

  @override
  String get fileCount => '파일 수';

  @override
  String get folderCount => '폴더 수';

  @override
  String get passwordProtected => '비밀번호';

  @override
  String get yes => '있음';

  @override
  String get no => '없음';

  @override
  String get duplicateSkipped => '이름이 같은 볼트는 건너뜁니다';

  @override
  String get noVaultsToBackup => '백업할 볼트가 없습니다';

  @override
  String get backupFailed => '백업 생성 실패';

  @override
  String get fileNotFound => '백업 파일을 찾을 수 없습니다';

  @override
  String get wrongPasswordOrCorrupt => '비밀번호가 틀리거나 파일이 손상되었습니다';

  @override
  String get backupCorruptOrNeedsPassword => '백업 파일이 손상되었거나 비밀번호가 필요합니다';

  @override
  String get invalidBackupNoMetadata => '유효하지 않은 백업 파일 (메타데이터 없음)';

  @override
  String get invalidBackupNoVaults => '유효하지 않은 백업 파일 (볼트 데이터 없음)';

  @override
  String get invalidBackupNoFiles => '유효하지 않은 백업 파일 (파일 데이터 없음)';

  @override
  String get backupNeedsPassword => '이 백업에는 비밀번호가 필요합니다';

  @override
  String get restoreFailed => '복원 실패';

  @override
  String vaultReplaced(String name) {
    return '볼트 \"$name\"이(가) 대체되었습니다';
  }

  @override
  String vaultSkipped(String name) {
    return '볼트 \"$name\"이(가) 이미 존재하여 건너뛰었습니다';
  }

  @override
  String get folderSkippedNoVault => '볼트를 찾을 수 없어 폴더를 건너뛰었습니다';

  @override
  String get fileSkippedNoVault => '볼트를 찾을 수 없어 파일을 건너뛰었습니다';

  @override
  String encryptedFileNotFound(int id) {
    return '파일 ID $id의 암호화된 파일을 찾을 수 없습니다';
  }

  @override
  String get passwordMinLength => '비밀번호는 최소 4자 이상이어야 합니다';

  @override
  String get pleaseEnterPassword => '비밀번호를 입력하세요';

  @override
  String get fileSaved => '파일이 저장되었습니다';

  @override
  String get preparing => '데이터 준비 중...';

  @override
  String get creatingBackupFile => '백업 파일 생성 중...';

  @override
  String get backingUpVaults => '볼트 백업 중...';

  @override
  String get backingUpFileData => '파일 데이터 백업 중...';

  @override
  String get backingUpEncryptedFiles => '암호화된 파일 백업 중...';

  @override
  String backingUpFile(int current, int total) {
    return '파일 백업 중 ($current/$total)...';
  }

  @override
  String get compressing => '데이터 압축 중...';

  @override
  String get encrypting => '백업 암호화 중...';

  @override
  String get done => '완료!';

  @override
  String get readingBackup => '백업 파일 읽는 중...';

  @override
  String get decrypting => '백업 복호화 중...';

  @override
  String get extracting => '파일 추출 중...';

  @override
  String get restoringVaults => '볼트 복원 중...';

  @override
  String get restoringFolders => '폴더 복원 중...';

  @override
  String get restoringFiles => '파일 복원 중...';

  @override
  String restoringFile(int current, int total) {
    return '파일 복원 중 ($current/$total)...';
  }

  @override
  String get vaultList => '내 볼트';

  @override
  String get createVault => '볼트 만들기';

  @override
  String get openVault => '볼트 열기';

  @override
  String get deleteVault => '볼트 삭제';

  @override
  String get vaultName => '볼트 이름';

  @override
  String get vaultPassword => '볼트 비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get enterVaultName => '볼트 이름 입력';

  @override
  String get enterVaultPassword => '볼트 비밀번호 입력';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get vaultCreated => '볼트가 생성되었습니다';

  @override
  String get vaultDeleted => '볼트가 삭제되었습니다';

  @override
  String get enterPasswordToOpen => '비밀번호를 입력하여 볼트 열기';

  @override
  String get wrongPassword => '비밀번호가 틀렸습니다';

  @override
  String get noVaults => '볼트가 없습니다';

  @override
  String get createFirstVault => '첫 번째 볼트를 만들어 시작하세요';

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
  String get fileManager => '파일 관리자';

  @override
  String get addFiles => '파일 추가';

  @override
  String get addImages => '이미지 추가';

  @override
  String get takePhoto => '사진 찍기';

  @override
  String get createFolder => '폴더 만들기';

  @override
  String get folderName => '폴더 이름';

  @override
  String get enterFolderName => '폴더 이름 입력';

  @override
  String get folderCreated => '폴더가 생성되었습니다';

  @override
  String get deleteFolder => '폴더 삭제';

  @override
  String get folderDeleted => '폴더가 삭제되었습니다';

  @override
  String get moveToFolder => '폴더로 이동';

  @override
  String get root => '루트';

  @override
  String get moveTo => '이동';

  @override
  String get movedToFolder => '폴더로 이동했습니다';

  @override
  String get search => '검색';

  @override
  String get searchFiles => '파일 검색...';

  @override
  String get noFilesFound => '파일을 찾을 수 없습니다';

  @override
  String get noFoldersFound => '폴더를 찾을 수 없습니다';

  @override
  String get sortBy => '정렬';

  @override
  String get sortNewest => '최신순';

  @override
  String get sortOldest => '오래된 순';

  @override
  String get sortNameAZ => '이름 A-Z';

  @override
  String get sortNameZA => '이름 Z-A';

  @override
  String get sortSizeSmall => '크기: 작은 순';

  @override
  String get sortSizeLarge => '크기: 큰 순';

  @override
  String get filterBy => '필터';

  @override
  String get filterAll => '전체';

  @override
  String get filterImages => '이미지';

  @override
  String get filterDocuments => '문서';

  @override
  String get filterVideos => '동영상';

  @override
  String get filterAudio => '오디오';

  @override
  String get selectAll => '전체 선택';

  @override
  String get deselectAll => '선택 해제';

  @override
  String selectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String get deleteSelected => '선택 삭제';

  @override
  String get moveSelected => '선택 이동';

  @override
  String get downloadSelected => '선택 다운로드';

  @override
  String get fileDeleted => '파일이 삭제되었습니다';

  @override
  String get fileRestored => '파일이 복원되었습니다';

  @override
  String get movedToTrash => '휴지통으로 이동했습니다';

  @override
  String get permanentDelete => '영구 삭제';

  @override
  String get permanentDeleteWarning => '이 작업은 취소할 수 없습니다. 파일이 영구적으로 삭제됩니다.';

  @override
  String daysRemaining(int count) {
    return '$count일 남음';
  }

  @override
  String get emptyTrash => '휴지통 비우기';

  @override
  String get emptyTrashWarning => '휴지통의 모든 파일이 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다.';

  @override
  String get trashEmpty => '휴지통이 비어 있습니다';

  @override
  String get restoreAll => '전체 복원';

  @override
  String get allRestored => '모든 파일이 복원되었습니다';

  @override
  String get trashEmptied => '휴지통이 비워졌습니다';

  @override
  String get fileDetails => '파일 세부정보';

  @override
  String get fileName => '파일 이름';

  @override
  String get fileType => '파일 유형';

  @override
  String get created => '생성일';

  @override
  String get modified => '수정일';

  @override
  String get size => '크기';

  @override
  String get download => '다운로드';

  @override
  String get downloadComplete => '다운로드 완료';

  @override
  String get decoyVault => '가짜 볼트';

  @override
  String get decoyVaultSubtitle => '다른 비밀번호로 가짜 볼트 만들기';

  @override
  String get decoyVaultEnabled => '가짜 볼트 활성화됨';

  @override
  String get decoyVaultPassword => '가짜 비밀번호';

  @override
  String get decoyVaultInfo => '가짜 비밀번호를 입력하여 가짜 볼트 열기';

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
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get languageChanged => '언어가 변경되었습니다';

  @override
  String get error => '오류';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get success => '성공';

  @override
  String get biometricFingerprint => '지문';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricIris => '홍채';

  @override
  String get biometricGeneric => '생체 인식';

  @override
  String get unlock => '잠금 해제';

  @override
  String get setupPinTitle => 'PIN 설정';

  @override
  String get confirmPinTitle => 'PIN 확인';

  @override
  String get confirmNewPinTitle => '새 PIN 확인';

  @override
  String get enterCurrentPinTitle => '현재 PIN 입력';

  @override
  String get verifyIdentity => '본인 확인';

  @override
  String get enter6DigitPinToUnlock => '앱을 열려면 6자리 PIN을 입력하세요';

  @override
  String get enter6DigitPinToSetup => '보안을 위해 6자리 PIN을 만드세요';

  @override
  String get enterPinAgainToConfirm => '확인을 위해 PIN을 다시 입력하세요';

  @override
  String get enterNewPinAgain => '새 PIN을 다시 입력하세요';

  @override
  String get enterYourCurrentPin => '현재 PIN을 입력하세요';

  @override
  String get enterPinToContinue => '계속하려면 PIN을 입력하세요';

  @override
  String get pinSetupSuccess => 'PIN 설정 완료';

  @override
  String get pinSetupFailed => 'PIN을 설정할 수 없습니다';

  @override
  String get pinUsedToUnlock => 'PIN은 앱 잠금 해제에 사용됩니다';

  @override
  String waitMinutes(int minutes) {
    return '$minutes분 후에 다시 시도하세요';
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
