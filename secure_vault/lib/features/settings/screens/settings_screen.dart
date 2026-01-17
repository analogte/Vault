import 'package:flutter/material.dart';
import '../../../services/biometric_service.dart';
import '../../../services/security_service.dart';
import '../../../services/clipboard_service.dart';
import '../../../services/root_detection_service.dart';
import '../../../services/app_integrity_service.dart';
import 'trash_screen.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
      ),
      body: ListView(
        children: [
          // Security Section
          _buildSectionHeader('ความปลอดภัย'),

          // Biometric
          if (_biometricAvailable)
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: 'ปลดล็อคด้วย $_biometricTypeName',
              subtitle: 'ใช้ลายนิ้วมือหรือ Face ID เพื่อเปิด Vault',
              value: _biometricEnabled,
              onChanged: (value) async {
                await _biometricService.setBiometricEnabled(value);
                setState(() => _biometricEnabled = value);
              },
            ),

          // Auto-lock
          _buildSwitchTile(
            icon: Icons.timer,
            title: 'ล็อคอัตโนมัติ',
            subtitle: _autoLockEnabled
                ? 'ล็อค Vault หลังจากไม่ใช้งาน ${_getTimeoutLabel(_autoLockTimeout)}'
                : 'ปิดใช้งาน',
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
              title: const Text('ระยะเวลาล็อค'),
              subtitle: Text(_getTimeoutLabel(_autoLockTimeout)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showTimeoutPicker,
            ),

          // Lock on background
          _buildSwitchTile(
            icon: Icons.phonelink_lock,
            title: 'ล็อคเมื่อออกจากแอป',
            subtitle: 'ล็อค Vault ทันทีเมื่อสลับไปใช้แอปอื่น',
            value: _lockOnBackground,
            onChanged: (value) async {
              await _securityService.setLockOnBackgroundEnabled(value);
              setState(() => _lockOnBackground = value);
            },
          ),

          // Screenshot prevention
          _buildSwitchTile(
            icon: Icons.no_photography,
            title: 'ป้องกันการ Screenshot',
            subtitle: 'ป้องกันการจับภาพหน้าจอในแอป',
            value: _screenshotPrevention,
            onChanged: (value) async {
              await _securityService.setScreenshotPreventionEnabled(value);
              setState(() => _screenshotPrevention = value);
              _showRestartHint();
            },
          ),

          // Clipboard auto-clear
          _buildSwitchTile(
            icon: Icons.content_paste_off,
            title: 'ล้าง Clipboard อัตโนมัติ',
            subtitle: _clipboardAutoClear
                ? 'ล้าง Clipboard หลังคัดลอก $_clipboardTimeout วินาที'
                : 'ปิดใช้งาน',
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
              title: const Text('ระยะเวลาล้าง Clipboard'),
              subtitle: Text('$_clipboardTimeout วินาที'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showClipboardTimeoutPicker,
            ),

          const Divider(),

          // Security Status Section
          _buildSectionHeader('สถานะความปลอดภัย'),

          // Device security status
          if (_securityStatus != null)
            _buildSecurityStatusTile(),

          // Integrity check result
          if (_integrityResult != null)
            _buildIntegrityStatusTile(),

          const Divider(),

          // Data Section
          _buildSectionHeader('ข้อมูล'),

          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('ถังขยะ'),
            subtitle: const Text('ดูและกู้คืนไฟล์ที่ลบ'),
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

          const Divider(),

          // About Section
          _buildSectionHeader('เกี่ยวกับ'),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('เวอร์ชัน'),
            subtitle: const Text('1.0.0'),
          ),

          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('ความปลอดภัย'),
            subtitle: const Text('AES-256-GCM + Argon2id (หรือ PBKDF2)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSecurityFeatures(),
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('นโยบายความเป็นส่วนตัว'),
            subtitle: const Text('ข้อมูลถูกเข้ารหัสและเก็บในเครื่องของคุณเท่านั้น'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyInfo(),
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

  String _getTimeoutLabel(int seconds) {
    if (seconds < 60) {
      return '$seconds วินาที';
    } else if (seconds < 3600) {
      return '${seconds ~/ 60} นาที';
    } else {
      return '${seconds ~/ 3600} ชั่วโมง';
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

  void _showRestartHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('การเปลี่ยนแปลงจะมีผลหลังจากรีสตาร์ทแอป'),
        duration: Duration(seconds: 3),
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

  Widget _buildSecurityStatusTile() {
    final status = _securityStatus!;
    final isSecure = status.isSecure;

    return ListTile(
      leading: Icon(
        isSecure ? Icons.shield : Icons.warning_amber,
        color: isSecure ? Colors.green : Colors.orange,
      ),
      title: const Text('สถานะอุปกรณ์'),
      subtitle: Text(
        isSecure
            ? 'อุปกรณ์ปลอดภัย'
            : status.isRooted
                ? 'อุปกรณ์ถูก Root/Jailbreak'
                : 'Developer Mode เปิดอยู่',
        style: TextStyle(
          color: isSecure ? Colors.green : Colors.orange,
        ),
      ),
      trailing: TextButton(
        onPressed: () => _showSecurityDetails(),
        child: const Text('รายละเอียด'),
      ),
    );
  }

  Widget _buildIntegrityStatusTile() {
    final result = _integrityResult!;
    final isSafe = result.isSafe;

    return ListTile(
      leading: Icon(
        isSafe ? Icons.verified_user : Icons.gpp_maybe,
        color: isSafe ? Colors.green : Colors.amber,
      ),
      title: const Text('ความสมบูรณ์ของแอป'),
      subtitle: Text(
        isSafe
            ? 'แอปทำงานในสภาพแวดล้อมปลอดภัย'
            : 'พบ ${result.warnings.length} คำเตือน',
        style: TextStyle(
          color: isSafe ? Colors.green : Colors.amber,
        ),
      ),
    );
  }

  void _showSecurityDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security),
            SizedBox(width: 8),
            Expanded(child: Text('รายละเอียดความปลอดภัย')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusRow('Root/Jailbreak', _securityStatus?.isRooted ?? false),
              _buildStatusRow('Developer Mode', _securityStatus?.isDeveloperModeEnabled ?? false),
              _buildStatusRow('Emulator', _integrityResult?.isEmulator ?? false),
              _buildStatusRow('Debug Mode', _integrityResult?.isDebugMode ?? false),
              if (_integrityResult?.warnings.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                const Text(
                  'คำเตือน:',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool hasIssue) {
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
            hasIssue ? 'พบ' : 'ไม่พบ',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 8),
            Text('ฟีเจอร์ความปลอดภัย'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'การเข้ารหัส:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• AES-256-GCM (มาตรฐานทหาร)'),
              Text('• Argon2id Key Derivation (ทนทานต่อ GPU attack)'),
              Text('• PBKDF2 100,000 iterations (สำหรับ vault เก่า)'),
              SizedBox(height: 16),
              Text(
                'การป้องกัน:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• ตรวจจับ Root/Jailbreak'),
              Text('• ตรวจจับ Emulator และ Debug mode'),
              Text('• ป้องกันการ Screenshot'),
              Text('• ล้าง Clipboard อัตโนมัติ'),
              Text('• ล็อคเมื่อออกจากแอป'),
              SizedBox(height: 16),
              Text(
                'การจัดเก็บ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Hardware Keystore (Android/iOS)'),
              Text('• Encrypted Shared Preferences'),
              Text('• ไม่ส่งข้อมูลไปยัง server'),
              SizedBox(height: 16),
              Text(
                'ฟีเจอร์พิเศษ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Secure Keyboard (ไม่บันทึกการพิมพ์)'),
              Text('• Decoy Vault (vault ปลอม)'),
              Text('• Code Obfuscation'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip),
            SizedBox(width: 8),
            Text('ความเป็นส่วนตัว'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Secure Vault ออกแบบมาเพื่อความเป็นส่วนตัวสูงสุด:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• ไฟล์ทั้งหมดถูกเข้ารหัสด้วย AES-256-GCM'),
              SizedBox(height: 8),
              Text('• รหัสผ่านถูกประมวลผลด้วย PBKDF2 100,000 รอบ'),
              SizedBox(height: 8),
              Text('• ข้อมูลทั้งหมดเก็บในเครื่องของคุณเท่านั้น'),
              SizedBox(height: 8),
              Text('• ไม่มีการส่งข้อมูลไปยัง server'),
              SizedBox(height: 8),
              Text('• ไม่มีการติดตามหรือวิเคราะห์พฤติกรรม'),
              SizedBox(height: 8),
              Text('• ไม่มีโฆษณา'),
              SizedBox(height: 16),
              Text(
                'หากลืมรหัสผ่าน จะไม่สามารถกู้คืนข้อมูลได้',
                style: TextStyle(
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
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }
}

