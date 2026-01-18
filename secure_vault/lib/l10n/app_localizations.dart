import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_th.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('th'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Secure Vault'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Keep your files safe'**
  String get appTagline;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @securityCheck.
  ///
  /// In en, this message translates to:
  /// **'Checking security...'**
  String get securityCheck;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter PIN'**
  String get enterPin;

  /// No description provided for @enteringApp.
  ///
  /// In en, this message translates to:
  /// **'Entering app...'**
  String get enteringApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock with {type}'**
  String biometricUnlock(String type);

  /// No description provided for @biometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID to open Vault'**
  String get biometricSubtitle;

  /// No description provided for @autoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto Lock'**
  String get autoLock;

  /// No description provided for @autoLockEnabled.
  ///
  /// In en, this message translates to:
  /// **'Lock Vault after {time} of inactivity'**
  String autoLockEnabled(String time);

  /// No description provided for @autoLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get autoLockDisabled;

  /// No description provided for @lockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Lock Timeout'**
  String get lockTimeout;

  /// No description provided for @selectAutoLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Select auto lock timeout'**
  String get selectAutoLockTimeout;

  /// No description provided for @lockOnBackground.
  ///
  /// In en, this message translates to:
  /// **'Lock when leaving app'**
  String get lockOnBackground;

  /// No description provided for @lockOnBackgroundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lock Vault immediately when switching to another app'**
  String get lockOnBackgroundSubtitle;

  /// No description provided for @screenshotPrevention.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Prevention'**
  String get screenshotPrevention;

  /// No description provided for @screenshotPreventionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent screen capture in the app'**
  String get screenshotPreventionSubtitle;

  /// No description provided for @restartRequired.
  ///
  /// In en, this message translates to:
  /// **'Changes will take effect after restart'**
  String get restartRequired;

  /// No description provided for @clipboardAutoClear.
  ///
  /// In en, this message translates to:
  /// **'Auto Clear Clipboard'**
  String get clipboardAutoClear;

  /// No description provided for @clipboardAutoClearEnabled.
  ///
  /// In en, this message translates to:
  /// **'Clear clipboard after {seconds} seconds'**
  String clipboardAutoClearEnabled(int seconds);

  /// No description provided for @clipboardTimeout.
  ///
  /// In en, this message translates to:
  /// **'Clipboard Clear Timeout'**
  String get clipboardTimeout;

  /// No description provided for @selectClipboardTimeout.
  ///
  /// In en, this message translates to:
  /// **'Select clipboard clear timeout'**
  String get selectClipboardTimeout;

  /// No description provided for @securityStatus.
  ///
  /// In en, this message translates to:
  /// **'Security Status'**
  String get securityStatus;

  /// No description provided for @deviceStatus.
  ///
  /// In en, this message translates to:
  /// **'Device Status'**
  String get deviceStatus;

  /// No description provided for @deviceSecure.
  ///
  /// In en, this message translates to:
  /// **'Device is secure'**
  String get deviceSecure;

  /// No description provided for @deviceRooted.
  ///
  /// In en, this message translates to:
  /// **'Device is Rooted/Jailbroken'**
  String get deviceRooted;

  /// No description provided for @developerModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Developer Mode is enabled'**
  String get developerModeEnabled;

  /// No description provided for @securityDetails.
  ///
  /// In en, this message translates to:
  /// **'Security Details'**
  String get securityDetails;

  /// No description provided for @appIntegrity.
  ///
  /// In en, this message translates to:
  /// **'App Integrity'**
  String get appIntegrity;

  /// No description provided for @appIntegritySafe.
  ///
  /// In en, this message translates to:
  /// **'App is running in a safe environment'**
  String get appIntegritySafe;

  /// No description provided for @appIntegrityWarnings.
  ///
  /// In en, this message translates to:
  /// **'{count} warnings found'**
  String appIntegrityWarnings(int count);

  /// No description provided for @rootJailbreak.
  ///
  /// In en, this message translates to:
  /// **'Root/Jailbreak'**
  String get rootJailbreak;

  /// No description provided for @developerMode.
  ///
  /// In en, this message translates to:
  /// **'Developer Mode'**
  String get developerMode;

  /// No description provided for @emulator.
  ///
  /// In en, this message translates to:
  /// **'Emulator'**
  String get emulator;

  /// No description provided for @externalStorage.
  ///
  /// In en, this message translates to:
  /// **'App installed on External Storage'**
  String get externalStorage;

  /// No description provided for @debugMode.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode'**
  String get debugMode;

  /// No description provided for @detected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get detected;

  /// No description provided for @notDetected.
  ///
  /// In en, this message translates to:
  /// **'Not Detected'**
  String get notDetected;

  /// No description provided for @warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warnings;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @trashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and restore deleted files'**
  String get trashSubtitle;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export/Import all data'**
  String get backupSubtitle;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionInfo;

  /// No description provided for @securityFeatures.
  ///
  /// In en, this message translates to:
  /// **'Security Features'**
  String get securityFeatures;

  /// No description provided for @securityFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AES-256-GCM + Argon2id (or PBKDF2)'**
  String get securityFeaturesSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Data is encrypted and stored locally only'**
  String get privacyPolicySubtitle;

  /// No description provided for @appLockSettings.
  ///
  /// In en, this message translates to:
  /// **'App Lock Settings'**
  String get appLockSettings;

  /// No description provided for @pinEnabled.
  ///
  /// In en, this message translates to:
  /// **'PIN enabled'**
  String get pinEnabled;

  /// No description provided for @pinNotSet.
  ///
  /// In en, this message translates to:
  /// **'PIN not set'**
  String get pinNotSet;

  /// No description provided for @lockAppNow.
  ///
  /// In en, this message translates to:
  /// **'Lock App Now'**
  String get lockAppNow;

  /// No description provided for @lockAppNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lock app and show PIN screen'**
  String get lockAppNowSubtitle;

  /// No description provided for @encryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get encryption;

  /// No description provided for @encryptionAES.
  ///
  /// In en, this message translates to:
  /// **'AES-256-GCM (Military grade)'**
  String get encryptionAES;

  /// No description provided for @encryptionArgon2.
  ///
  /// In en, this message translates to:
  /// **'Argon2id Key Derivation (GPU attack resistant)'**
  String get encryptionArgon2;

  /// No description provided for @encryptionPBKDF2.
  ///
  /// In en, this message translates to:
  /// **'PBKDF2 100,000 iterations (for legacy vaults)'**
  String get encryptionPBKDF2;

  /// No description provided for @protection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get protection;

  /// No description provided for @protectionRoot.
  ///
  /// In en, this message translates to:
  /// **'Root/Jailbreak detection'**
  String get protectionRoot;

  /// No description provided for @protectionEmulator.
  ///
  /// In en, this message translates to:
  /// **'Emulator and Debug mode detection'**
  String get protectionEmulator;

  /// No description provided for @protectionScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Screenshot prevention'**
  String get protectionScreenshot;

  /// No description provided for @protectionClipboard.
  ///
  /// In en, this message translates to:
  /// **'Auto clipboard clear'**
  String get protectionClipboard;

  /// No description provided for @protectionBackground.
  ///
  /// In en, this message translates to:
  /// **'Lock on background'**
  String get protectionBackground;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storageKeystore.
  ///
  /// In en, this message translates to:
  /// **'Hardware Keystore (Android/iOS)'**
  String get storageKeystore;

  /// No description provided for @storageEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Shared Preferences'**
  String get storageEncrypted;

  /// No description provided for @storageNoServer.
  ///
  /// In en, this message translates to:
  /// **'No data sent to server'**
  String get storageNoServer;

  /// No description provided for @specialFeatures.
  ///
  /// In en, this message translates to:
  /// **'Special Features'**
  String get specialFeatures;

  /// No description provided for @featureSecureKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Secure Keyboard (no logging)'**
  String get featureSecureKeyboard;

  /// No description provided for @featureDecoyVault.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault (fake vault)'**
  String get featureDecoyVault;

  /// No description provided for @featureObfuscation.
  ///
  /// In en, this message translates to:
  /// **'Code Obfuscation'**
  String get featureObfuscation;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyInfo1.
  ///
  /// In en, this message translates to:
  /// **'All files are encrypted with AES-256-GCM'**
  String get privacyInfo1;

  /// No description provided for @privacyInfo2.
  ///
  /// In en, this message translates to:
  /// **'Passwords processed with PBKDF2 100,000 rounds'**
  String get privacyInfo2;

  /// No description provided for @privacyInfo3.
  ///
  /// In en, this message translates to:
  /// **'All data stored locally on your device only'**
  String get privacyInfo3;

  /// No description provided for @privacyInfo4.
  ///
  /// In en, this message translates to:
  /// **'No data sent to server'**
  String get privacyInfo4;

  /// No description provided for @privacyInfo5.
  ///
  /// In en, this message translates to:
  /// **'No tracking or behavior analysis'**
  String get privacyInfo5;

  /// No description provided for @privacyInfo6.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get privacyInfo6;

  /// No description provided for @privacyWarning.
  ///
  /// In en, this message translates to:
  /// **'If you forget your password, data cannot be recovered'**
  String get privacyWarning;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @securityWarning.
  ///
  /// In en, this message translates to:
  /// **'Security Warning'**
  String get securityWarning;

  /// No description provided for @unsafeEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Potentially unsafe environment detected:'**
  String get unsafeEnvironment;

  /// No description provided for @appStillUsable.
  ///
  /// In en, this message translates to:
  /// **'App can still be used, but data may be at risk.\nRecommended to use on non-rooted/jailbroken device'**
  String get appStillUsable;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAnyway;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String seconds(int count);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutes(int count);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hours(int count);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @pinLock.
  ///
  /// In en, this message translates to:
  /// **'PIN Lock'**
  String get pinLock;

  /// No description provided for @enterPinToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to unlock'**
  String get enterPinToUnlock;

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPin;

  /// No description provided for @enterNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get enterNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get confirmNewPin;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPin;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinMismatch;

  /// No description provided for @pinChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully'**
  String get pinChanged;

  /// No description provided for @pinCreated.
  ///
  /// In en, this message translates to:
  /// **'PIN created successfully'**
  String get pinCreated;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use {type}'**
  String useBiometric(String type);

  /// No description provided for @attemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} attempts remaining'**
  String attemptsRemaining(int count);

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts'**
  String get tooManyAttempts;

  /// No description provided for @tryAgainIn.
  ///
  /// In en, this message translates to:
  /// **'Try again in {seconds} seconds'**
  String tryAgainIn(int seconds);

  /// No description provided for @enableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Enable App Lock'**
  String get enableAppLock;

  /// No description provided for @enableAppLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require PIN when opening app'**
  String get enableAppLockSubtitle;

  /// No description provided for @biometricForAppLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric for App Lock'**
  String get biometricForAppLock;

  /// No description provided for @biometricForAppLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use {type} instead of PIN'**
  String biometricForAppLockSubtitle(String type);

  /// No description provided for @autoLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auto Lock Timeout'**
  String get autoLockTimeout;

  /// No description provided for @lockAfterBackground.
  ///
  /// In en, this message translates to:
  /// **'Lock after {time} in background'**
  String lockAfterBackground(String time);

  /// No description provided for @immediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// No description provided for @setupPin.
  ///
  /// In en, this message translates to:
  /// **'Setup PIN'**
  String get setupPin;

  /// No description provided for @resetPin.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPin;

  /// No description provided for @setPinFirst.
  ///
  /// In en, this message translates to:
  /// **'Please set PIN first'**
  String get setPinFirst;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupTitle;

  /// No description provided for @backupInfo.
  ///
  /// In en, this message translates to:
  /// **'About Backup'**
  String get backupInfo;

  /// No description provided for @backupInfo1.
  ///
  /// In en, this message translates to:
  /// **'Backup file includes all Vaults, Folders and files'**
  String get backupInfo1;

  /// No description provided for @backupInfo2.
  ///
  /// In en, this message translates to:
  /// **'Files remain encrypted, safe to share to Cloud'**
  String get backupInfo2;

  /// No description provided for @backupInfo3.
  ///
  /// In en, this message translates to:
  /// **'Can set additional password for security'**
  String get backupInfo3;

  /// No description provided for @backupInfo4.
  ///
  /// In en, this message translates to:
  /// **'Recommended to backup regularly'**
  String get backupInfo4;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @setBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Backup Password'**
  String get setBackupPassword;

  /// No description provided for @setBackupPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypt backup file with additional password'**
  String get setBackupPasswordSubtitle;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password for backup'**
  String get enterBackupPassword;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromBackup;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select .svbackup file to restore'**
  String get selectBackupFile;

  /// No description provided for @duplicateVaultWarning.
  ///
  /// In en, this message translates to:
  /// **'If restored Vault has same name as existing, it will be skipped'**
  String get duplicateVaultWarning;

  /// No description provided for @selectBackupFileButton.
  ///
  /// In en, this message translates to:
  /// **'Select Backup File'**
  String get selectBackupFileButton;

  /// No description provided for @restoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get restoring;

  /// No description provided for @backupCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup Created Successfully!'**
  String get backupCreatedSuccess;

  /// No description provided for @vaults.
  ///
  /// In en, this message translates to:
  /// **'Vaults'**
  String get vaults;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @selectSaveMethod.
  ///
  /// In en, this message translates to:
  /// **'Select how to save backup file:'**
  String get selectSaveMethod;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restore Successful!'**
  String get restoreSuccess;

  /// No description provided for @vaultsRestored.
  ///
  /// In en, this message translates to:
  /// **'Vaults restored'**
  String get vaultsRestored;

  /// No description provided for @filesRestored.
  ///
  /// In en, this message translates to:
  /// **'Files restored'**
  String get filesRestored;

  /// No description provided for @foldersRestored.
  ///
  /// In en, this message translates to:
  /// **'Folders restored'**
  String get foldersRestored;

  /// No description provided for @enterBackupPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter Backup Password'**
  String get enterBackupPasswordPrompt;

  /// No description provided for @backupInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Info'**
  String get backupInfoTitle;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @vaultCount.
  ///
  /// In en, this message translates to:
  /// **'Vault count'**
  String get vaultCount;

  /// No description provided for @fileCount.
  ///
  /// In en, this message translates to:
  /// **'File count'**
  String get fileCount;

  /// No description provided for @folderCount.
  ///
  /// In en, this message translates to:
  /// **'Folder count'**
  String get folderCount;

  /// No description provided for @passwordProtected.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordProtected;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @duplicateSkipped.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Vault will be skipped'**
  String get duplicateSkipped;

  /// No description provided for @noVaultsToBackup.
  ///
  /// In en, this message translates to:
  /// **'No Vaults to backup'**
  String get noVaultsToBackup;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup creation failed'**
  String get backupFailed;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Backup file not found'**
  String get fileNotFound;

  /// No description provided for @wrongPasswordOrCorrupt.
  ///
  /// In en, this message translates to:
  /// **'Wrong password or file is corrupted'**
  String get wrongPasswordOrCorrupt;

  /// No description provided for @backupCorruptOrNeedsPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup file corrupted or needs password'**
  String get backupCorruptOrNeedsPassword;

  /// No description provided for @invalidBackupNoMetadata.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file (no metadata)'**
  String get invalidBackupNoMetadata;

  /// No description provided for @invalidBackupNoVaults.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file (no vaults data)'**
  String get invalidBackupNoVaults;

  /// No description provided for @invalidBackupNoFiles.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file (no files data)'**
  String get invalidBackupNoFiles;

  /// No description provided for @backupNeedsPassword.
  ///
  /// In en, this message translates to:
  /// **'This backup requires password'**
  String get backupNeedsPassword;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// No description provided for @vaultReplaced.
  ///
  /// In en, this message translates to:
  /// **'Vault \"{name}\" was replaced'**
  String vaultReplaced(String name);

  /// No description provided for @vaultSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped Vault \"{name}\" as it already exists'**
  String vaultSkipped(String name);

  /// No description provided for @folderSkippedNoVault.
  ///
  /// In en, this message translates to:
  /// **'Skipped folder as vault not found'**
  String get folderSkippedNoVault;

  /// No description provided for @fileSkippedNoVault.
  ///
  /// In en, this message translates to:
  /// **'Skipped file as vault not found'**
  String get fileSkippedNoVault;

  /// No description provided for @encryptedFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Encrypted file not found for file ID {id}'**
  String encryptedFileNotFound(int id);

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get passwordMinLength;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @fileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved successfully'**
  String get fileSaved;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing data...'**
  String get preparing;

  /// No description provided for @creatingBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Creating backup file...'**
  String get creatingBackupFile;

  /// No description provided for @backingUpVaults.
  ///
  /// In en, this message translates to:
  /// **'Backing up vaults...'**
  String get backingUpVaults;

  /// No description provided for @backingUpFileData.
  ///
  /// In en, this message translates to:
  /// **'Backing up file data...'**
  String get backingUpFileData;

  /// No description provided for @backingUpEncryptedFiles.
  ///
  /// In en, this message translates to:
  /// **'Backing up encrypted files...'**
  String get backingUpEncryptedFiles;

  /// No description provided for @backingUpFile.
  ///
  /// In en, this message translates to:
  /// **'Backing up file ({current}/{total})...'**
  String backingUpFile(int current, int total);

  /// No description provided for @compressing.
  ///
  /// In en, this message translates to:
  /// **'Compressing data...'**
  String get compressing;

  /// No description provided for @encrypting.
  ///
  /// In en, this message translates to:
  /// **'Encrypting backup...'**
  String get encrypting;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get done;

  /// No description provided for @readingBackup.
  ///
  /// In en, this message translates to:
  /// **'Reading backup file...'**
  String get readingBackup;

  /// No description provided for @decrypting.
  ///
  /// In en, this message translates to:
  /// **'Decrypting backup...'**
  String get decrypting;

  /// No description provided for @extracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting files...'**
  String get extracting;

  /// No description provided for @restoringVaults.
  ///
  /// In en, this message translates to:
  /// **'Restoring vaults...'**
  String get restoringVaults;

  /// No description provided for @restoringFolders.
  ///
  /// In en, this message translates to:
  /// **'Restoring folders...'**
  String get restoringFolders;

  /// No description provided for @restoringFiles.
  ///
  /// In en, this message translates to:
  /// **'Restoring files...'**
  String get restoringFiles;

  /// No description provided for @restoringFile.
  ///
  /// In en, this message translates to:
  /// **'Restoring file ({current}/{total})...'**
  String restoringFile(int current, int total);

  /// No description provided for @vaultList.
  ///
  /// In en, this message translates to:
  /// **'My Vaults'**
  String get vaultList;

  /// No description provided for @createVault.
  ///
  /// In en, this message translates to:
  /// **'Create Vault'**
  String get createVault;

  /// No description provided for @openVault.
  ///
  /// In en, this message translates to:
  /// **'Open Vault'**
  String get openVault;

  /// No description provided for @deleteVault.
  ///
  /// In en, this message translates to:
  /// **'Delete Vault'**
  String get deleteVault;

  /// No description provided for @vaultName.
  ///
  /// In en, this message translates to:
  /// **'Vault Name'**
  String get vaultName;

  /// No description provided for @vaultPassword.
  ///
  /// In en, this message translates to:
  /// **'Vault Password'**
  String get vaultPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterVaultName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Personal Files, Photos'**
  String get enterVaultName;

  /// No description provided for @enterVaultPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter vault password'**
  String get enterVaultPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @vaultCreated.
  ///
  /// In en, this message translates to:
  /// **'Vault created successfully'**
  String get vaultCreated;

  /// No description provided for @vaultDeleted.
  ///
  /// In en, this message translates to:
  /// **'Vault deleted successfully'**
  String get vaultDeleted;

  /// No description provided for @enterPasswordToOpen.
  ///
  /// In en, this message translates to:
  /// **'Enter password to open vault'**
  String get enterPasswordToOpen;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @noVaults.
  ///
  /// In en, this message translates to:
  /// **'No vaults yet'**
  String get noVaults;

  /// No description provided for @createFirstVault.
  ///
  /// In en, this message translates to:
  /// **'Create your first vault to get started'**
  String get createFirstVault;

  /// No description provided for @pleaseEnterVaultName.
  ///
  /// In en, this message translates to:
  /// **'Please enter vault name'**
  String get pleaseEnterVaultName;

  /// No description provided for @vaultNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Vault name must be at least 2 characters'**
  String get vaultNameMinLength;

  /// No description provided for @vaultNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Vault name must not exceed 50 characters'**
  String get vaultNameMaxLength;

  /// No description provided for @passwordMinLengthHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordMinLengthHint;

  /// No description provided for @passwordMinLength8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength8;

  /// No description provided for @passwordMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Password must not exceed 128 characters'**
  String get passwordMaxLength;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get pleaseConfirmPassword;

  /// No description provided for @vaultPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'Important: Remember your password well. If you forget it, files cannot be recovered.'**
  String get vaultPasswordWarning;

  /// No description provided for @vaultCreationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Vault creation took too long. Please try again.'**
  String get vaultCreationTimeout;

  /// No description provided for @vaultCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating vault'**
  String get vaultCreationError;

  /// No description provided for @directoryCreationError.
  ///
  /// In en, this message translates to:
  /// **'Cannot create folder. Please check access permissions.'**
  String get directoryCreationError;

  /// No description provided for @databaseError.
  ///
  /// In en, this message translates to:
  /// **'Database error. Please try again.'**
  String get databaseError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Please check your internet connection.'**
  String get networkError;

  /// No description provided for @fileManager.
  ///
  /// In en, this message translates to:
  /// **'File Manager'**
  String get fileManager;

  /// No description provided for @addFiles.
  ///
  /// In en, this message translates to:
  /// **'Add Files'**
  String get addFiles;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get createFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder Name'**
  String get folderName;

  /// No description provided for @enterFolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter folder name'**
  String get enterFolderName;

  /// No description provided for @folderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created successfully'**
  String get folderCreated;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete Folder'**
  String get deleteFolder;

  /// No description provided for @folderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted successfully'**
  String get folderDeleted;

  /// No description provided for @moveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to Folder'**
  String get moveToFolder;

  /// No description provided for @root.
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get root;

  /// No description provided for @moveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get moveTo;

  /// No description provided for @movedToFolder.
  ///
  /// In en, this message translates to:
  /// **'Moved to folder successfully'**
  String get movedToFolder;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchFiles.
  ///
  /// In en, this message translates to:
  /// **'Search files...'**
  String get searchFiles;

  /// No description provided for @noFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No files found'**
  String get noFilesFound;

  /// No description provided for @noFoldersFound.
  ///
  /// In en, this message translates to:
  /// **'No folders found'**
  String get noFoldersFound;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// No description provided for @sortNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get sortNameAZ;

  /// No description provided for @sortNameZA.
  ///
  /// In en, this message translates to:
  /// **'Name Z-A'**
  String get sortNameZA;

  /// No description provided for @sortSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Size: Smallest'**
  String get sortSizeSmall;

  /// No description provided for @sortSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Size: Largest'**
  String get sortSizeLarge;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get filterImages;

  /// No description provided for @filterDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get filterDocuments;

  /// No description provided for @filterVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get filterVideos;

  /// No description provided for @filterAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get filterAudio;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @moveSelected.
  ///
  /// In en, this message translates to:
  /// **'Move Selected'**
  String get moveSelected;

  /// No description provided for @downloadSelected.
  ///
  /// In en, this message translates to:
  /// **'Download Selected'**
  String get downloadSelected;

  /// No description provided for @fileDeleted.
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get fileDeleted;

  /// No description provided for @fileRestored.
  ///
  /// In en, this message translates to:
  /// **'File restored'**
  String get fileRestored;

  /// No description provided for @movedToTrash.
  ///
  /// In en, this message translates to:
  /// **'Moved to trash'**
  String get movedToTrash;

  /// No description provided for @permanentDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete'**
  String get permanentDelete;

  /// No description provided for @permanentDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. The file will be permanently deleted.'**
  String get permanentDeleteWarning;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} days remaining'**
  String daysRemaining(int count);

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get emptyTrash;

  /// No description provided for @emptyTrashWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all files in trash. This action cannot be undone.'**
  String get emptyTrashWarning;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmpty;

  /// No description provided for @restoreAll.
  ///
  /// In en, this message translates to:
  /// **'Restore All'**
  String get restoreAll;

  /// No description provided for @allRestored.
  ///
  /// In en, this message translates to:
  /// **'All files restored'**
  String get allRestored;

  /// No description provided for @trashEmptied.
  ///
  /// In en, this message translates to:
  /// **'Trash emptied'**
  String get trashEmptied;

  /// No description provided for @fileDetails.
  ///
  /// In en, this message translates to:
  /// **'File Details'**
  String get fileDetails;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @fileType.
  ///
  /// In en, this message translates to:
  /// **'File Type'**
  String get fileType;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete'**
  String get downloadComplete;

  /// No description provided for @decoyVault.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault'**
  String get decoyVault;

  /// No description provided for @decoyVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a fake vault with different password'**
  String get decoyVaultSubtitle;

  /// No description provided for @decoyVaultEnabled.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault enabled'**
  String get decoyVaultEnabled;

  /// No description provided for @decoyVaultPassword.
  ///
  /// In en, this message translates to:
  /// **'Decoy Password'**
  String get decoyVaultPassword;

  /// No description provided for @decoyVaultInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter decoy password to open fake vault'**
  String get decoyVaultInfo;

  /// No description provided for @decoyVaultWhatIs.
  ///
  /// In en, this message translates to:
  /// **'What is Decoy Vault?'**
  String get decoyVaultWhatIs;

  /// No description provided for @decoyVaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault is a security feature that helps protect your data in case you are forced to open your Vault.\n\n- Set a fake password (Decoy Password)\n- When entering the fake password, it shows a fake Vault with unimportant data\n- Your real password still opens the real Vault normally'**
  String get decoyVaultDescription;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// No description provided for @decoyVaultActive.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault is active'**
  String get decoyVaultActive;

  /// No description provided for @decoyVaultNotSet.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault not set up'**
  String get decoyVaultNotSet;

  /// No description provided for @setupDecoyPassword.
  ///
  /// In en, this message translates to:
  /// **'Setup Decoy Password'**
  String get setupDecoyPassword;

  /// No description provided for @decoyPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'This password will open the fake Vault'**
  String get decoyPasswordHint;

  /// No description provided for @enterDecoyPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter decoy password'**
  String get enterDecoyPassword;

  /// No description provided for @confirmDecoyPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Decoy Password'**
  String get confirmDecoyPassword;

  /// No description provided for @enterDecoyPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Enter decoy password again'**
  String get enterDecoyPasswordAgain;

  /// No description provided for @setupDecoyVault.
  ///
  /// In en, this message translates to:
  /// **'Setup Decoy Vault'**
  String get setupDecoyVault;

  /// No description provided for @decoyPasswordWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not use the same password as your real Vault!'**
  String get decoyPasswordWarning;

  /// No description provided for @enableDecoyVault.
  ///
  /// In en, this message translates to:
  /// **'Enable Decoy Vault'**
  String get enableDecoyVault;

  /// No description provided for @decoyPasswordWillWork.
  ///
  /// In en, this message translates to:
  /// **'Decoy password will work'**
  String get decoyPasswordWillWork;

  /// No description provided for @decoyPasswordWillNotWork.
  ///
  /// In en, this message translates to:
  /// **'Decoy password will not work'**
  String get decoyPasswordWillNotWork;

  /// No description provided for @changeDecoyPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Decoy Password'**
  String get changeDecoyPassword;

  /// No description provided for @setNewDecoyPassword.
  ///
  /// In en, this message translates to:
  /// **'Set new decoy password'**
  String get setNewDecoyPassword;

  /// No description provided for @deleteDecoyVault.
  ///
  /// In en, this message translates to:
  /// **'Delete Decoy Vault'**
  String get deleteDecoyVault;

  /// No description provided for @deleteDecoyVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete decoy password and fake vault'**
  String get deleteDecoyVaultSubtitle;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @decoyStep1.
  ///
  /// In en, this message translates to:
  /// **'When opening Vault, enter decoy password instead of real password'**
  String get decoyStep1;

  /// No description provided for @decoyStep2.
  ///
  /// In en, this message translates to:
  /// **'System will open Decoy Vault with fake data'**
  String get decoyStep2;

  /// No description provided for @decoyStep3.
  ///
  /// In en, this message translates to:
  /// **'Use real password to open real Vault'**
  String get decoyStep3;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteDecoyVaultConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete Decoy Vault?\n\nAll data in Decoy Vault will be deleted.'**
  String get deleteDecoyVaultConfirm;

  /// No description provided for @decoyVaultSetupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault setup successful'**
  String get decoyVaultSetupSuccess;

  /// No description provided for @decoyVaultDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Decoy Vault deleted successfully'**
  String get decoyVaultDeleteSuccess;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @biometricFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get biometricFingerprint;

  /// No description provided for @biometricFaceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get biometricFaceId;

  /// No description provided for @biometricIris.
  ///
  /// In en, this message translates to:
  /// **'Iris'**
  String get biometricIris;

  /// No description provided for @biometricGeneric.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get biometricGeneric;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @setupPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup PIN'**
  String get setupPinTitle;

  /// No description provided for @confirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPinTitle;

  /// No description provided for @confirmNewPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm New PIN'**
  String get confirmNewPinTitle;

  /// No description provided for @enterCurrentPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Current PIN'**
  String get enterCurrentPinTitle;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify Identity'**
  String get verifyIdentity;

  /// No description provided for @enter6DigitPinToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit PIN to open the app'**
  String get enter6DigitPinToUnlock;

  /// No description provided for @enter6DigitPinToSetup.
  ///
  /// In en, this message translates to:
  /// **'Create a 6-digit PIN for security'**
  String get enter6DigitPinToSetup;

  /// No description provided for @enterPinAgainToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN again to confirm'**
  String get enterPinAgainToConfirm;

  /// No description provided for @enterNewPinAgain.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN again'**
  String get enterNewPinAgain;

  /// No description provided for @enterYourCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get enterYourCurrentPin;

  /// No description provided for @enterPinToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to continue'**
  String get enterPinToContinue;

  /// No description provided for @pinSetupSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN setup successful'**
  String get pinSetupSuccess;

  /// No description provided for @pinSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to setup PIN'**
  String get pinSetupFailed;

  /// No description provided for @pinUsedToUnlock.
  ///
  /// In en, this message translates to:
  /// **'PIN will be used to unlock the app'**
  String get pinUsedToUnlock;

  /// No description provided for @waitMinutes.
  ///
  /// In en, this message translates to:
  /// **'Wait {minutes} minutes then try again'**
  String waitMinutes(int minutes);

  /// No description provided for @authenticationSection.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authenticationSection;

  /// No description provided for @appProtected.
  ///
  /// In en, this message translates to:
  /// **'App is protected'**
  String get appProtected;

  /// No description provided for @appNotLocked.
  ///
  /// In en, this message translates to:
  /// **'App is not locked'**
  String get appNotLocked;

  /// No description provided for @yourDataIsSafe.
  ///
  /// In en, this message translates to:
  /// **'Your data is safe'**
  String get yourDataIsSafe;

  /// No description provided for @setupPinForSecurity.
  ///
  /// In en, this message translates to:
  /// **'Setup PIN for security'**
  String get setupPinForSecurity;

  /// No description provided for @create6DigitPin.
  ///
  /// In en, this message translates to:
  /// **'Create 6-digit PIN to lock app'**
  String get create6DigitPin;

  /// No description provided for @pinIsSet.
  ///
  /// In en, this message translates to:
  /// **'PIN is set'**
  String get pinIsSet;

  /// No description provided for @appWillBeLocked.
  ///
  /// In en, this message translates to:
  /// **'App will be locked on every open'**
  String get appWillBeLocked;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Disable App Lock'**
  String get disableAppLock;

  /// No description provided for @disableAppLockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disable App Lock?'**
  String get disableAppLockConfirm;

  /// No description provided for @disableAppLockWarning.
  ///
  /// In en, this message translates to:
  /// **'Disabling app lock will allow anyone to access your data. Are you sure?'**
  String get disableAppLockWarning;

  /// No description provided for @disableLock.
  ///
  /// In en, this message translates to:
  /// **'Disable Lock'**
  String get disableLock;

  /// No description provided for @appLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'App lock disabled'**
  String get appLockDisabled;

  /// No description provided for @enterPinToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to confirm'**
  String get enterPinToConfirm;

  /// No description provided for @verifyCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Verify Current PIN'**
  String get verifyCurrentPin;

  /// No description provided for @enterCurrentPinToChange.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN to change'**
  String get enterCurrentPinToChange;

  /// No description provided for @setNewPin.
  ///
  /// In en, this message translates to:
  /// **'Set New PIN'**
  String get setNewPin;

  /// No description provided for @createNew6DigitPin.
  ///
  /// In en, this message translates to:
  /// **'Create a new 6-digit PIN'**
  String get createNew6DigitPin;

  /// No description provided for @verifyPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify PIN'**
  String get verifyPinTitle;

  /// No description provided for @enterPinToDisableLock.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to disable app lock'**
  String get enterPinToDisableLock;

  /// No description provided for @unlockAppWith.
  ///
  /// In en, this message translates to:
  /// **'Unlock app with {type}'**
  String unlockAppWith(Object type);

  /// No description provided for @enableBiometricToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Enable {type} to unlock app'**
  String enableBiometricToUnlock(Object type);

  /// No description provided for @biometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'{type} enabled'**
  String biometricEnabled(Object type);

  /// No description provided for @lockAfterInactivity.
  ///
  /// In en, this message translates to:
  /// **'Lock app after {time} of inactivity'**
  String lockAfterInactivity(Object time);

  /// No description provided for @selectLockAfter.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get selectLockAfter;

  /// No description provided for @securityTips.
  ///
  /// In en, this message translates to:
  /// **'Security Tips'**
  String get securityTips;

  /// No description provided for @securityTip1.
  ///
  /// In en, this message translates to:
  /// **'Use a unique PIN not used in other apps'**
  String get securityTip1;

  /// No description provided for @securityTip2.
  ///
  /// In en, this message translates to:
  /// **'Avoid easy PINs like 123456'**
  String get securityTip2;

  /// No description provided for @securityTip3.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric for convenience'**
  String get securityTip3;

  /// No description provided for @securityTip4.
  ///
  /// In en, this message translates to:
  /// **'Set auto lock for better security'**
  String get securityTip4;

  /// No description provided for @authenticateToEnable.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to enable {type}'**
  String authenticateToEnable(Object type);

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get biometricAuthFailed;

  /// No description provided for @biometricSettings.
  ///
  /// In en, this message translates to:
  /// **'Biometric Settings'**
  String get biometricSettings;

  /// No description provided for @biometricEnabledForVault.
  ///
  /// In en, this message translates to:
  /// **'{type} is enabled'**
  String biometricEnabledForVault(String type);

  /// No description provided for @forThisVault.
  ///
  /// In en, this message translates to:
  /// **'For this vault'**
  String get forThisVault;

  /// No description provided for @disableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Disable Biometric'**
  String get disableBiometric;

  /// No description provided for @requirePasswordEveryTime.
  ///
  /// In en, this message translates to:
  /// **'Require password every time'**
  String get requirePasswordEveryTime;

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric disabled'**
  String get biometricDisabled;

  /// No description provided for @enableBiometricQuestion.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric?'**
  String get enableBiometricQuestion;

  /// No description provided for @enableBiometricDescription.
  ///
  /// In en, this message translates to:
  /// **'Do you want to use {type} to unlock this vault next time?\n\nYou can still use password as usual.'**
  String enableBiometricDescription(String type);

  /// No description provided for @doNotUse.
  ///
  /// In en, this message translates to:
  /// **'Don\'t use'**
  String get doNotUse;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @biometricAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'{type} is available'**
  String biometricAvailableHint(String type);

  /// No description provided for @biometricFirstTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Open vault with password first, then you will be asked to enable it'**
  String get biometricFirstTimeHint;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @upgradeSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Upgrade'**
  String get upgradeSecurityTitle;

  /// No description provided for @upgradeSecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'This vault uses PBKDF2 which is an older standard.\n\nRecommend upgrading to Argon2id which:'**
  String get upgradeSecurityDescription;

  /// No description provided for @gpuAttackResistant.
  ///
  /// In en, this message translates to:
  /// **'Resistant to GPU attacks'**
  String get gpuAttackResistant;

  /// No description provided for @asicAttackResistant.
  ///
  /// In en, this message translates to:
  /// **'Resistant to ASIC attacks'**
  String get asicAttackResistant;

  /// No description provided for @latestSecurityStandard.
  ///
  /// In en, this message translates to:
  /// **'Latest security standard'**
  String get latestSecurityStandard;

  /// No description provided for @passwordRemainsNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Password will remain the same'**
  String get passwordRemainsNote;

  /// No description provided for @upgradeLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get upgradeLater;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeNow;

  /// No description provided for @upgradingProgress.
  ///
  /// In en, this message translates to:
  /// **'Upgrading...'**
  String get upgradingProgress;

  /// No description provided for @upgradeToArgon2idSuccess.
  ///
  /// In en, this message translates to:
  /// **'Upgraded to Argon2id successfully'**
  String get upgradeToArgon2idSuccess;

  /// No description provided for @upgradeToArgon2idFailed.
  ///
  /// In en, this message translates to:
  /// **'Upgrade failed'**
  String get upgradeToArgon2idFailed;

  /// No description provided for @openVaultButton.
  ///
  /// In en, this message translates to:
  /// **'Open Vault'**
  String get openVaultButton;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get onboardingWelcome;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingFeature1Title.
  ///
  /// In en, this message translates to:
  /// **'Military-Grade Encryption'**
  String get onboardingFeature1Title;

  /// No description provided for @onboardingFeature1Desc.
  ///
  /// In en, this message translates to:
  /// **'All files are encrypted with AES-256.\nEven we cannot access your data.'**
  String get onboardingFeature1Desc;

  /// No description provided for @onboardingFeature2Title.
  ///
  /// In en, this message translates to:
  /// **'Stored Locally Only'**
  String get onboardingFeature2Title;

  /// No description provided for @onboardingFeature2Desc.
  ///
  /// In en, this message translates to:
  /// **'No data is sent to any server.\nYour data stays only on your device.'**
  String get onboardingFeature2Desc;

  /// No description provided for @onboardingFeature3Title.
  ///
  /// In en, this message translates to:
  /// **'Multi-Layer Protection'**
  String get onboardingFeature3Title;

  /// No description provided for @onboardingFeature3Desc.
  ///
  /// In en, this message translates to:
  /// **'PIN, Biometric, and\nScreenshot prevention.'**
  String get onboardingFeature3Desc;

  /// No description provided for @onboardingFeature4Title.
  ///
  /// In en, this message translates to:
  /// **'Easy Management'**
  String get onboardingFeature4Title;

  /// No description provided for @onboardingFeature4Desc.
  ///
  /// In en, this message translates to:
  /// **'Create multiple vaults,\neach with its own password.'**
  String get onboardingFeature4Desc;

  /// No description provided for @onboardingSecurityWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Please Read Carefully'**
  String get onboardingSecurityWarningTitle;

  /// No description provided for @onboardingNoRecovery.
  ///
  /// In en, this message translates to:
  /// **'No Password Recovery'**
  String get onboardingNoRecovery;

  /// No description provided for @onboardingNoRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'If you forget your PIN or Vault password, your data cannot be recovered.'**
  String get onboardingNoRecoveryDesc;

  /// No description provided for @onboardingRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations:'**
  String get onboardingRecommendations;

  /// No description provided for @onboardingRecommend1.
  ///
  /// In en, this message translates to:
  /// **'Write down your passwords and keep them safe'**
  String get onboardingRecommend1;

  /// No description provided for @onboardingRecommend2.
  ///
  /// In en, this message translates to:
  /// **'Use passwords you can remember'**
  String get onboardingRecommend2;

  /// No description provided for @onboardingRecommend3.
  ///
  /// In en, this message translates to:
  /// **'Backup your data regularly'**
  String get onboardingRecommend3;

  /// No description provided for @onboardingUnderstandRisk.
  ///
  /// In en, this message translates to:
  /// **'I understand and accept this risk'**
  String get onboardingUnderstandRisk;

  /// No description provided for @onboardingTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get onboardingTermsTitle;

  /// No description provided for @onboardingTerms1.
  ///
  /// In en, this message translates to:
  /// **'All data is encrypted and stored locally only'**
  String get onboardingTerms1;

  /// No description provided for @onboardingTerms2.
  ///
  /// In en, this message translates to:
  /// **'We do not store your passwords'**
  String get onboardingTerms2;

  /// No description provided for @onboardingTerms3.
  ///
  /// In en, this message translates to:
  /// **'If you forget your password, we cannot help recover your data'**
  String get onboardingTerms3;

  /// No description provided for @onboardingTerms4.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for remembering your passwords'**
  String get onboardingTerms4;

  /// No description provided for @onboardingTerms5.
  ///
  /// In en, this message translates to:
  /// **'Regular backups are recommended'**
  String get onboardingTerms5;

  /// No description provided for @onboardingAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Accept Terms'**
  String get onboardingAcceptTerms;

  /// No description provided for @onboardingAcceptPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Accept Privacy Policy'**
  String get onboardingAcceptPrivacy;

  /// No description provided for @onboardingAcceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and Continue'**
  String get onboardingAcceptAndContinue;

  /// No description provided for @onboardingSetupPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup PIN'**
  String get onboardingSetupPinTitle;

  /// No description provided for @onboardingSetupPinDesc.
  ///
  /// In en, this message translates to:
  /// **'This PIN will be used to open the app every time.'**
  String get onboardingSetupPinDesc;

  /// No description provided for @onboardingEnter6DigitPin.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit PIN'**
  String get onboardingEnter6DigitPin;

  /// No description provided for @onboardingConfirmPinDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN again to confirm'**
  String get onboardingConfirmPinDesc;

  /// No description provided for @onboardingBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable {type}?'**
  String onboardingBiometricTitle(String type);

  /// No description provided for @onboardingBiometricDesc.
  ///
  /// In en, this message translates to:
  /// **'Use {type} instead of PIN for convenience.\n\n(You still need to remember your PIN for emergencies)'**
  String onboardingBiometricDesc(String type);

  /// No description provided for @onboardingEnableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Enable {type}'**
  String onboardingEnableBiometric(String type);

  /// No description provided for @onboardingSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkipForNow;

  /// No description provided for @onboardingCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'All Set!'**
  String get onboardingCompleteTitle;

  /// No description provided for @onboardingCompleteTip1.
  ///
  /// In en, this message translates to:
  /// **'Create your first Vault to start storing files'**
  String get onboardingCompleteTip1;

  /// No description provided for @onboardingCompleteTip2.
  ///
  /// In en, this message translates to:
  /// **'Each Vault has its own separate password'**
  String get onboardingCompleteTip2;

  /// No description provided for @onboardingCompleteTip3.
  ///
  /// In en, this message translates to:
  /// **'You can backup your data in Settings'**
  String get onboardingCompleteTip3;

  /// No description provided for @onboardingStartUsing.
  ///
  /// In en, this message translates to:
  /// **'Start Using'**
  String get onboardingStartUsing;

  /// No description provided for @onboardingTips.
  ///
  /// In en, this message translates to:
  /// **'Tips:'**
  String get onboardingTips;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @largeFileWarning.
  ///
  /// In en, this message translates to:
  /// **'Large File Warning'**
  String get largeFileWarning;

  /// No description provided for @largeFileWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'You selected {count} file(s) larger than {size}. Large files require significant RAM and may cause the app to crash.'**
  String largeFileWarningMessage(int count, String size);

  /// No description provided for @largeFilesList.
  ///
  /// In en, this message translates to:
  /// **'Large files:'**
  String get largeFilesList;

  /// No description provided for @estimatedRamUsage.
  ///
  /// In en, this message translates to:
  /// **'Estimated RAM usage: {size}'**
  String estimatedRamUsage(String size);

  /// No description provided for @proceedAnyway.
  ///
  /// In en, this message translates to:
  /// **'Proceed Anyway'**
  String get proceedAnyway;

  /// No description provided for @removeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Remove Large Files'**
  String get removeAndContinue;

  /// No description provided for @skipLargeFiles.
  ///
  /// In en, this message translates to:
  /// **'Skip large files and continue with smaller ones'**
  String get skipLargeFiles;

  /// No description provided for @deleteOriginalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Original Files?'**
  String get deleteOriginalTitle;

  /// No description provided for @deleteOriginalMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully uploaded {count} file(s). Would you like to delete the original files from your device to save storage space?'**
  String deleteOriginalMessage(int count);

  /// No description provided for @deleteOriginalWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the original files from your gallery/folder.'**
  String get deleteOriginalWarning;

  /// No description provided for @keepOriginals.
  ///
  /// In en, this message translates to:
  /// **'Keep Originals'**
  String get keepOriginals;

  /// No description provided for @deleteOriginals.
  ///
  /// In en, this message translates to:
  /// **'Delete Originals'**
  String get deleteOriginals;

  /// No description provided for @originalsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} original file(s) deleted'**
  String originalsDeleted(int count);

  /// No description provided for @originalsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete some original files'**
  String get originalsDeleteFailed;

  /// No description provided for @takeVideo.
  ///
  /// In en, this message translates to:
  /// **'Take Video'**
  String get takeVideo;

  /// No description provided for @recentFiles.
  ///
  /// In en, this message translates to:
  /// **'Recent Files'**
  String get recentFiles;

  /// No description provided for @fileOpened.
  ///
  /// In en, this message translates to:
  /// **'File opened'**
  String get fileOpened;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @themeChanged.
  ///
  /// In en, this message translates to:
  /// **'Theme changed'**
  String get themeChanged;

  /// No description provided for @storageStats.
  ///
  /// In en, this message translates to:
  /// **'Storage Stats'**
  String get storageStats;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @totalFiles.
  ///
  /// In en, this message translates to:
  /// **'Total Files'**
  String get totalFiles;

  /// No description provided for @totalSize.
  ///
  /// In en, this message translates to:
  /// **'Total Size'**
  String get totalSize;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @manageTags.
  ///
  /// In en, this message translates to:
  /// **'Manage Tags'**
  String get manageTags;

  /// No description provided for @createTag.
  ///
  /// In en, this message translates to:
  /// **'Create Tag'**
  String get createTag;

  /// No description provided for @tagName.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagName;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @tagCreated.
  ///
  /// In en, this message translates to:
  /// **'Tag created'**
  String get tagCreated;

  /// No description provided for @tagDeleted.
  ///
  /// In en, this message translates to:
  /// **'Tag deleted'**
  String get tagDeleted;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTags;

  /// No description provided for @filterByTag.
  ///
  /// In en, this message translates to:
  /// **'Filter by Tag'**
  String get filterByTag;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'id',
    'ja',
    'ko',
    'th',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'id':
      return SId();
    case 'ja':
      return SJa();
    case 'ko':
      return SKo();
    case 'th':
      return STh();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
