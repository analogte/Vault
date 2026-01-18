import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/biometric_service.dart';
import '../../../services/security_service.dart';
import '../../../services/clipboard_service.dart';
import '../../../services/root_detection_service.dart';
import '../../../services/app_integrity_service.dart';
import '../../../services/app_lock_service.dart';
import '../../../services/locale_service.dart';
import '../../../services/theme_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/screens/security_settings_screen.dart';
import '../../auth/screens/splash_screen.dart';
import 'trash_screen.dart';
import 'backup_screen.dart';
import '../widgets/storage_stats_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _biometricService = BiometricService();
  final _securityService = SecurityService();
  final _clipboardService = ClipboardService();
  final _rootDetectionService = RootDetectionService();
  final _appIntegrityService = AppIntegrityService();
  final _appLockService = AppLockService();

  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  bool _autoLockEnabled = true;
  int _autoLockTimeout = 60;
  bool _lockOnBackground = true;
  bool _screenshotPrevention = true;
  String _biometricTypeName = 'Biometric';

  // New security settings
  bool _clipboardAutoClear = true;
  int _clipboardTimeout = 30;
  SecurityStatus? _securityStatus;
  IntegrityResult? _integrityResult;

  // App lock settings
  bool _isPinSet = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final biometricAvailable = await _biometricService.isBiometricAvailable();
    final biometricEnabled = await _biometricService.isBiometricEnabled();
    final types = await _biometricService.getAvailableBiometrics();
    final autoLockEnabled = await _securityService.isAutoLockEnabled();
    final autoLockTimeout = await _securityService.getAutoLockTimeout();
    final lockOnBackground = await _securityService.isLockOnBackgroundEnabled();
    final screenshotPrevention =
        await _securityService.isScreenshotPreventionEnabled();

    // Load new security settings
    final clipboardAutoClear = await _clipboardService.isAutoClearEnabled();
    final clipboardTimeout = await _clipboardService.getTimeout();
    final securityStatus = await _rootDetectionService.getSecurityStatus();
    final integrityResult = await _appIntegrityService.checkIntegrity();

    // Load app lock settings
    final isPinSet = await _appLockService.isPinSet();

    setState(() {
      _biometricAvailable = biometricAvailable;
      _biometricEnabled = biometricEnabled;
      _biometricTypeName = _biometricService.getBiometricTypeName(types);
      _autoLockEnabled = autoLockEnabled;
      _autoLockTimeout = autoLockTimeout;
      _lockOnBackground = lockOnBackground;
      _screenshotPrevention = screenshotPrevention;
      _clipboardAutoClear = clipboardAutoClear;
      _clipboardTimeout = clipboardTimeout;
      _securityStatus = securityStatus;
      _integrityResult = integrityResult;
      _isPinSet = isPinSet;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'ตั้งค่า'),
      ),
      body: ListView(
        children: [
          // Security Section
          _buildSectionHeader(l10n?.security ?? 'ความปลอดภัย'),

          // Biometric
          if (_biometricAvailable)
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: l10n?.biometricUnlock(_biometricTypeName) ?? 'ปลดล็อคด้วย $_biometricTypeName',
              subtitle: l10n?.biometricSubtitle ?? 'ใช้ลายนิ้วมือหรือ Face ID เพื่อเปิด Vault',
              value: _biometricEnabled,
              onChanged: (value) async {
                await _biometricService.setBiometricEnabled(value);
                setState(() => _biometricEnabled = value);
              },
            ),

          // Auto-lock
          _buildSwitchTile(
            icon: Icons.timer,
            title: l10n?.autoLock ?? 'ล็อคอัตโนมัติ',
            subtitle: _autoLockEnabled
                ? l10n?.autoLockEnabled(_getTimeoutLabel(_autoLockTimeout, l10n)) ?? 'ล็อค Vault หลังจากไม่ใช้งาน ${_getTimeoutLabel(_autoLockTimeout, l10n)}'
                : l10n?.autoLockDisabled ?? 'ปิดใช้งาน',
            value: _autoLockEnabled,
            onChanged: (value) async {
              await _securityService.setAutoLockEnabled(value);
              setState(() => _autoLockEnabled = value);
            },
          ),

          // Auto-lock timeout
          if (_autoLockEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: Text(l10n?.lockTimeout ?? 'ระยะเวลาล็อค'),
              subtitle: Text(_getTimeoutLabel(_autoLockTimeout, l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showTimeoutPicker,
            ),

          // Lock on background
          _buildSwitchTile(
            icon: Icons.phonelink_lock,
            title: l10n?.lockOnBackground ?? 'ล็อคเมื่อออกจากแอป',
            subtitle: l10n?.lockOnBackgroundSubtitle ?? 'ล็อค Vault ทันทีเมื่อสลับไปใช้แอปอื่น',
            value: _lockOnBackground,
            onChanged: (value) async {
              await _securityService.setLockOnBackgroundEnabled(value);
              setState(() => _lockOnBackground = value);
            },
          ),

          // Screenshot prevention
          _buildSwitchTile(
            icon: Icons.no_photography,
            title: l10n?.screenshotPrevention ?? 'ป้องกันการ Screenshot',
            subtitle: l10n?.screenshotPreventionSubtitle ?? 'ป้องกันการจับภาพหน้าจอในแอป',
            value: _screenshotPrevention,
            onChanged: (value) async {
              await _securityService.setScreenshotPreventionEnabled(value);
              setState(() => _screenshotPrevention = value);
              _showRestartHint(l10n);
            },
          ),

          // Clipboard auto-clear
          _buildSwitchTile(
            icon: Icons.content_paste_off,
            title: l10n?.clipboardAutoClear ?? 'ล้าง Clipboard อัตโนมัติ',
            subtitle: _clipboardAutoClear
                ? l10n?.clipboardAutoClearEnabled(_clipboardTimeout) ?? 'ล้าง Clipboard หลังคัดลอก $_clipboardTimeout วินาที'
                : l10n?.autoLockDisabled ?? 'ปิดใช้งาน',
            value: _clipboardAutoClear,
            onChanged: (value) async {
              await _clipboardService.setAutoClearEnabled(value);
              setState(() => _clipboardAutoClear = value);
            },
          ),

          // Clipboard timeout
          if (_clipboardAutoClear)
            ListTile(
              leading: const SizedBox(width: 24),
              title: Text(l10n?.clipboardTimeout ?? 'ระยะเวลาล้าง Clipboard'),
              subtitle: Text(l10n?.seconds(_clipboardTimeout) ?? '$_clipboardTimeout วินาที'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showClipboardTimeoutPicker,
            ),

          const Divider(),

          // Security Status Section
          _buildSectionHeader(l10n?.securityStatus ?? 'สถานะความปลอดภัย'),

          // Device security status
          if (_securityStatus != null)
            _buildSecurityStatusTile(l10n),

          // Integrity check result
          if (_integrityResult != null)
            _buildIntegrityStatusTile(l10n),

          const Divider(),

          // Storage Stats Section
          _buildSectionHeader(l10n?.storageStats ?? 'สถิติการใช้งาน'),
          const StorageStatsWidget(),

          const Divider(),

          // Data Section
          _buildSectionHeader(l10n?.data ?? 'ข้อมูล'),

          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: Text(l10n?.trash ?? 'ถังขยะ'),
            subtitle: Text(l10n?.trashSubtitle ?? 'ดูและกู้คืนไฟล์ที่ลบ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to trash screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrashScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(l10n?.backup ?? 'สำรองข้อมูล'),
            subtitle: Text(l10n?.backupSubtitle ?? 'Export/Import ข้อมูลทั้งหมด'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackupScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(S.of(context)?.about ?? 'เกี่ยวกับ'),

          // Theme Selector
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return ListTile(
                leading: Icon(themeService.getThemeModeIcon(themeService.themeMode)),
                title: Text(l10n?.theme ?? 'ธีม'),
                subtitle: Text(themeService.getThemeModeName(themeService.themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemePicker(context, themeService),
              );
            },
          ),

          // Language Selector
          Consumer<LocaleService>(
            builder: (context, localeService, child) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(S.of(context)?.language ?? 'ภาษา'),
                subtitle: Text(
                  '${localeService.currentLanguageFlag} ${localeService.currentLanguageName}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguagePicker(context, localeService),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(S.of(context)?.versionInfo ?? 'เวอร์ชัน'),
            subtitle: const Text('1.0.0'),
          ),

          ListTile(
            leading: const Icon(Icons.shield),
            title: Text(S.of(context)?.securityFeatures ?? 'ความปลอดภัย'),
            subtitle: Text(S.of(context)?.securityFeaturesSubtitle ?? 'AES-256-GCM + Argon2id (หรือ PBKDF2)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSecurityFeatures(),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n?.privacyPolicy ?? 'นโยบายความเป็นส่วนตัว'),
            subtitle: Text(l10n?.privacyPolicySubtitle ?? 'ข้อมูลถูกเข้ารหัสและเก็บในเครื่องของคุณเท่านั้น'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyInfo(l10n),
          ),

          const Divider(),

          // Account Section
          _buildSectionHeader(l10n?.account ?? 'บัญชี'),

          // Security settings (PIN, Biometric for app lock)
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n?.appLockSettings ?? 'ตั้งค่าการล็อคแอป'),
            subtitle: Text(_isPinSet ? (l10n?.pinEnabled ?? 'เปิดใช้งาน PIN แล้ว') : (l10n?.pinNotSet ?? 'ยังไม่ได้ตั้งค่า PIN')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SecuritySettingsScreen(),
                ),
              );
              _loadSettings(); // Reload settings after returning
            },
          ),

          // Lock App button
          if (_isPinSet)
            ListTile(
              leading: Icon(
                Icons.lock,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                l10n?.lockAppNow ?? 'ล็อคแอปตอนนี้',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(l10n?.lockAppNowSubtitle ?? 'ล็อคแอปและแสดงหน้า PIN'),
              onTap: _lockApp,
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }

  String _getTimeoutLabel(int seconds, S? l10n) {
    if (seconds < 60) {
      return l10n?.seconds(seconds) ?? '$seconds วินาที';
    } else if (seconds < 3600) {
      return l10n?.minutes(seconds ~/ 60) ?? '${seconds ~/ 60} นาที';
    } else {
      return l10n?.hours(seconds ~/ 3600) ?? '${seconds ~/ 3600} ชั่วโมง';
    }
  }

  void _showTimeoutPicker() {
    final options = _securityService.getTimeoutOptions();

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'เลือกระยะเวลาล็อคอัตโนมัติ',
                style: Theme.of(bottomSheetContext).textTheme.titleLarge,
              ),
            ),
            ...options.map((option) => ListTile(
                  leading: Radio<int>(
                    value: option.seconds,
                    groupValue: _autoLockTimeout,
                    onChanged: (value) => _selectTimeout(value, bottomSheetContext),
                  ),
                  title: Text(option.label),
                  onTap: () => _selectTimeout(option.seconds, bottomSheetContext),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTimeout(int? value, BuildContext bottomSheetContext) async {
    if (value != null) {
      await _securityService.setAutoLockTimeout(value);
      if (mounted) {
        setState(() => _autoLockTimeout = value);
      }
    }
    if (bottomSheetContext.mounted) {
      Navigator.pop(bottomSheetContext);
    }
  }

  void _showRestartHint(S? l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.restartRequired ?? 'การเปลี่ยนแปลงจะมีผลหลังจากรีสตาร์ทแอป'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showClipboardTimeoutPicker() {
    final options = _clipboardService.getTimeoutOptions();

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'เลือกระยะเวลาล้าง Clipboard',
                style: Theme.of(bottomSheetContext).textTheme.titleLarge,
              ),
            ),
            ...options.map((option) => ListTile(
                  leading: Radio<int>(
                    value: option.seconds,
                    groupValue: _clipboardTimeout,
                    onChanged: (value) => _selectClipboardTimeout(value, bottomSheetContext),
                  ),
                  title: Text(option.label),
                  onTap: () => _selectClipboardTimeout(option.seconds, bottomSheetContext),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectClipboardTimeout(int? value, BuildContext bottomSheetContext) async {
    if (value != null) {
      await _clipboardService.setTimeout(value);
      if (mounted) {
        setState(() => _clipboardTimeout = value);
      }
    }
    if (bottomSheetContext.mounted) {
      Navigator.pop(bottomSheetContext);
    }
  }

  Widget _buildSecurityStatusTile(S? l10n) {
    final status = _securityStatus!;
    final isSecure = status.isSecure;

    return ListTile(
      leading: Icon(
        isSecure ? Icons.shield : Icons.warning_amber,
        color: isSecure ? Colors.green : Colors.orange,
      ),
      title: Text(l10n?.deviceStatus ?? 'สถานะอุปกรณ์'),
      subtitle: Text(
        isSecure
            ? l10n?.deviceSecure ?? 'อุปกรณ์ปลอดภัย'
            : status.isRooted
                ? l10n?.deviceRooted ?? 'อุปกรณ์ถูก Root/Jailbreak'
                : l10n?.developerModeEnabled ?? 'Developer Mode เปิดอยู่',
        style: TextStyle(
          color: isSecure ? Colors.green : Colors.orange,
        ),
      ),
      trailing: TextButton(
        onPressed: () => _showSecurityDetails(l10n),
        child: Text(l10n?.securityDetails ?? 'รายละเอียด'),
      ),
    );
  }

  Widget _buildIntegrityStatusTile(S? l10n) {
    final result = _integrityResult!;
    final isSafe = result.isSafe;

    return ListTile(
      leading: Icon(
        isSafe ? Icons.verified_user : Icons.gpp_maybe,
        color: isSafe ? Colors.green : Colors.amber,
      ),
      title: Text(l10n?.appIntegrity ?? 'ความสมบูรณ์ของแอป'),
      subtitle: Text(
        isSafe
            ? l10n?.appIntegritySafe ?? 'แอปทำงานในสภาพแวดล้อมปลอดภัย'
            : l10n?.appIntegrityWarnings(result.warnings.length) ?? 'พบ ${result.warnings.length} คำเตือน',
        style: TextStyle(
          color: isSafe ? Colors.green : Colors.amber,
        ),
      ),
    );
  }

  void _showSecurityDetails(S? l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n?.securityDetails ?? 'รายละเอียดความปลอดภัย')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusRow(l10n?.rootJailbreak ?? 'Root/Jailbreak', _securityStatus?.isRooted ?? false, l10n),
              _buildStatusRow(l10n?.developerMode ?? 'Developer Mode', _securityStatus?.isDeveloperModeEnabled ?? false, l10n),
              _buildStatusRow(l10n?.emulator ?? 'Emulator', _integrityResult?.isEmulator ?? false, l10n),
              _buildStatusRow(l10n?.debugMode ?? 'Debug Mode', _integrityResult?.isDebugMode ?? false, l10n),
              if (_integrityResult?.warnings.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                Text(
                  '${l10n?.warnings ?? 'คำเตือน'}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...(_integrityResult!.warnings.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(child: Text(w, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                    ))),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.close ?? 'ปิด'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool hasIssue, S? l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasIssue ? Icons.cancel : Icons.check_circle,
            size: 20,
            color: hasIssue ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            hasIssue ? (l10n?.detected ?? 'พบ') : (l10n?.notDetected ?? 'ไม่พบ'),
            style: TextStyle(
              color: hasIssue ? Colors.red : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSecurityFeatures() {
    final l10n = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n?.securityFeatures ?? 'ฟีเจอร์ความปลอดภัย')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l10n?.encryption ?? 'การเข้ารหัส'}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${l10n?.encryptionAES ?? 'AES-256-GCM (มาตรฐานทหาร)'}'),
              Text('• ${l10n?.encryptionArgon2 ?? 'Argon2id Key Derivation (ทนทานต่อ GPU attack)'}'),
              Text('• ${l10n?.encryptionPBKDF2 ?? 'PBKDF2 100,000 iterations (สำหรับ vault เก่า)'}'),
              const SizedBox(height: 16),
              Text(
                '${l10n?.protection ?? 'การป้องกัน'}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${l10n?.protectionRoot ?? 'ตรวจจับ Root/Jailbreak'}'),
              Text('• ${l10n?.protectionEmulator ?? 'ตรวจจับ Emulator และ Debug mode'}'),
              Text('• ${l10n?.protectionScreenshot ?? 'ป้องกันการ Screenshot'}'),
              Text('• ${l10n?.protectionClipboard ?? 'ล้าง Clipboard อัตโนมัติ'}'),
              Text('• ${l10n?.protectionBackground ?? 'ล็อคเมื่อออกจากแอป'}'),
              const SizedBox(height: 16),
              Text(
                '${l10n?.storage ?? 'การจัดเก็บ'}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${l10n?.storageKeystore ?? 'Hardware Keystore (Android/iOS)'}'),
              Text('• ${l10n?.storageEncrypted ?? 'Encrypted Shared Preferences'}'),
              Text('• ${l10n?.storageNoServer ?? 'ไม่ส่งข้อมูลไปยัง server'}'),
              const SizedBox(height: 16),
              Text(
                '${l10n?.specialFeatures ?? 'ฟีเจอร์พิเศษ'}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${l10n?.featureSecureKeyboard ?? 'Secure Keyboard (ไม่บันทึกการพิมพ์)'}'),
              Text('• ${l10n?.featureDecoyVault ?? 'Decoy Vault (vault ปลอม)'}'),
              Text('• ${l10n?.featureObfuscation ?? 'Code Obfuscation'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.close ?? 'ปิด'),
          ),
        ],
      ),
    );
  }

  void _lockApp() {
    // Lock the app
    _appLockService.lockApp();

    // Navigate to splash screen which will check PIN
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      ),
      (route) => false, // Remove all routes
    );
  }

  void _showThemePicker(BuildContext context, ThemeService themeService) {
    final l10n = S.of(context);
    final themes = [
      (ThemeMode.system, l10n?.themeSystem ?? 'ตามระบบ', Icons.brightness_auto),
      (ThemeMode.light, l10n?.themeLight ?? 'สว่าง', Icons.light_mode),
      (ThemeMode.dark, l10n?.themeDark ?? 'มืด', Icons.dark_mode),
    ];

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n?.selectTheme ?? 'เลือกธีม',
                style: Theme.of(bottomSheetContext).textTheme.titleLarge,
              ),
            ),
            ...themes.map((theme) {
              final (mode, name, icon) = theme;
              final isSelected = themeService.themeMode == mode;

              return ListTile(
                leading: Icon(icon),
                title: Text(name),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () async {
                  await themeService.setThemeMode(mode);
                  if (bottomSheetContext.mounted) {
                    Navigator.pop(bottomSheetContext);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.themeChanged ?? 'เปลี่ยนธีมแล้ว',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LocaleService localeService) {
    final l10n = S.of(context);

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n?.selectLanguage ?? 'เลือกภาษา',
                style: Theme.of(bottomSheetContext).textTheme.titleLarge,
              ),
            ),
            ...LocaleService.supportedLocales.map((locale) {
              final code = locale.languageCode;
              final flag = localeService.getLanguageFlag(code);
              final name = localeService.getLanguageName(code);
              final isSelected = localeService.currentLocale.languageCode == code;

              return ListTile(
                leading: Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(name),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () async {
                  await localeService.setLocale(locale);
                  if (bottomSheetContext.mounted) {
                    Navigator.pop(bottomSheetContext);
                  }
                  // Show confirmation
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          S.of(context)?.languageChanged ?? 'เปลี่ยนภาษาแล้ว',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPrivacyInfo(S? l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.privacy_tip),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n?.privacyTitle ?? 'ความเป็นส่วนตัว')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Secure Vault:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('• ${l10n?.privacyInfo1 ?? 'ไฟล์ทั้งหมดถูกเข้ารหัสด้วย AES-256-GCM'}'),
              const SizedBox(height: 8),
              Text('• ${l10n?.privacyInfo2 ?? 'รหัสผ่านถูกประมวลผลด้วย PBKDF2 100,000 รอบ'}'),
              const SizedBox(height: 8),
              Text('• ${l10n?.privacyInfo3 ?? 'ข้อมูลทั้งหมดเก็บในเครื่องของคุณเท่านั้น'}'),
              const SizedBox(height: 8),
              Text('• ${l10n?.privacyInfo4 ?? 'ไม่มีการส่งข้อมูลไปยัง server'}'),
              const SizedBox(height: 8),
              Text('• ${l10n?.privacyInfo5 ?? 'ไม่มีการติดตามหรือวิเคราะห์พฤติกรรม'}'),
              const SizedBox(height: 8),
              Text('• ${l10n?.privacyInfo6 ?? 'ไม่มีโฆษณา'}'),
              const SizedBox(height: 16),
              Text(
                l10n?.privacyWarning ?? 'หากลืมรหัสผ่าน จะไม่สามารถกู้คืนข้อมูลได้',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.understood ?? 'เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }
}

