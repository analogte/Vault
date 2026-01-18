import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/app_lock_service.dart';
import '../../../services/biometric_service.dart';
import 'pin_lock_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final AppLockService _appLockService = AppLockService();
  final BiometricService _biometricService = BiometricService();

  bool _isLoading = true;
  bool _isPinSet = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  int _autoLockTimeout = 5;
  String _biometricTypeName = 'Biometric';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final isPinSet = await _appLockService.isPinSet();
    final isBiometricAvailable = await _biometricService.isBiometricAvailable();
    final isBiometricEnabled = await _appLockService.isBiometricForAppEnabled();
    final autoLockTimeout = await _appLockService.getAutoLockTimeout();
    final biometricTypes = await _biometricService.getAvailableBiometrics();
    final biometricTypeName = _biometricService.getBiometricTypeName(biometricTypes);

    if (mounted) {
      setState(() {
        _isPinSet = isPinSet;
        _isBiometricAvailable = isBiometricAvailable;
        _isBiometricEnabled = isBiometricEnabled;
        _autoLockTimeout = autoLockTimeout;
        _biometricTypeName = biometricTypeName;
        _isLoading = false;
      });
    }
  }

  Future<void> _setupPin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PinLockScreen(
          mode: PinScreenMode.setup,
          onSuccess: () => Navigator.pop(context, true),
        ),
      ),
    );

    if (result == true) {
      _loadSettings();
    }
  }

  Future<void> _changePin() async {
    final l10n = S.of(context);
    // First verify current PIN
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PinLockScreen(
          mode: PinScreenMode.verify,
          title: l10n?.verifyCurrentPin ?? 'ยืนยัน PIN เดิม',
          subtitle: l10n?.enterCurrentPinToChange ?? 'ใส่ PIN ปัจจุบันเพื่อเปลี่ยน',
          onSuccess: () => Navigator.pop(context, true),
        ),
      ),
    );

    if (verified == true && mounted) {
      // Now setup new PIN
      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PinLockScreen(
            mode: PinScreenMode.setup,
            title: l10n?.setNewPin ?? 'ตั้ง PIN ใหม่',
            subtitle: l10n?.createNew6DigitPin ?? 'สร้างรหัส PIN 6 หลักใหม่',
            onSuccess: () => Navigator.pop(context, true),
          ),
        ),
      );

      if (changed == true) {
        _loadSettings();
      }
    }
  }

  Future<void> _removePin() async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
        title: Text(l10n?.disableAppLockConfirm ?? 'ปิดการล็อคแอป?'),
        content: Text(
          l10n?.disableAppLockWarning ??
          'การปิดการล็อคแอปจะทำให้ทุกคนสามารถเข้าถึงข้อมูลในแอปได้ '
          'คุณแน่ใจหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n?.disableLock ?? 'ปิดการล็อค'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Verify PIN before removing
      final verified = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PinLockScreen(
            mode: PinScreenMode.verify,
            title: l10n?.verifyPinTitle ?? 'ยืนยัน PIN',
            subtitle: l10n?.enterPinToDisableLock ?? 'ใส่ PIN เพื่อปิดการล็อคแอป',
            onSuccess: () => Navigator.pop(context, true),
          ),
        ),
      );

      if (verified == true && mounted) {
        // Get PIN to remove
        final pin = await _showPinInputDialog();
        if (pin != null) {
          final success = await _appLockService.removePin(pin);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.appLockDisabled ?? 'ปิดการล็อคแอปแล้ว'),
                backgroundColor: Colors.orange,
              ),
            );
            _loadSettings();
          }
        }
      }
    }
  }

  Future<String?> _showPinInputDialog() async {
    final l10n = S.of(context);
    String pin = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.enterPinToConfirm ?? 'ใส่ PIN เพื่อยืนยัน'),
        content: TextField(
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'PIN',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => pin = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, pin),
            child: Text(l10n?.confirm ?? 'ยืนยัน'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    final l10n = S.of(context);
    if (value) {
      // Enable biometric
      final authenticated = await _biometricService.authenticate(
        localizedReason: l10n?.authenticateToEnable(_biometricTypeName) ??
            'ยืนยันตัวตนเพื่อเปิดใช้ $_biometricTypeName',
      );

      if (authenticated) {
        final success = await _appLockService.setBiometricForApp(true);
        if (success && mounted) {
          setState(() => _isBiometricEnabled = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.biometricEnabled(_biometricTypeName) ??
                  'เปิดใช้ $_biometricTypeName แล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      // Disable biometric
      await _appLockService.setBiometricForApp(false);
      if (mounted) {
        setState(() => _isBiometricEnabled = false);
      }
    }
  }

  Future<void> _setAutoLockTimeout(int minutes) async {
    await _appLockService.setAutoLockTimeout(minutes);
    setState(() => _autoLockTimeout = minutes);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showAutoLockPicker() {
    final l10n = S.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n?.selectLockAfter ?? 'ล็อคอัตโนมัติหลังจาก',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...AppLockService.autoLockOptions.map((minutes) {
              final label = minutes == 0
                  ? (l10n?.immediately ?? 'ทันที')
                  : (l10n?.minutes(minutes) ?? '$minutes นาที');
              return ListTile(
                leading: Icon(
                  _autoLockTimeout == minutes
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _autoLockTimeout == minutes
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(label),
                onTap: () => _setAutoLockTimeout(minutes),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.security ?? 'ความปลอดภัย'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Security header
                _buildSecurityHeader(theme, l10n),

                const SizedBox(height: 24),

                // App Lock section
                _buildSectionTitle(l10n?.appLockSettings ?? 'การล็อคแอป', theme),
                const SizedBox(height: 8),
                _buildAppLockCard(theme, l10n),

                const SizedBox(height: 24),

                // Biometric section
                if (_isBiometricAvailable && _isPinSet) ...[
                  _buildSectionTitle(l10n?.authenticationSection ?? 'การยืนยันตัวตน', theme),
                  const SizedBox(height: 8),
                  _buildBiometricCard(theme, l10n),
                  const SizedBox(height: 24),
                ],

                // Auto-lock section
                if (_isPinSet) ...[
                  _buildSectionTitle(l10n?.autoLock ?? 'ล็อคอัตโนมัติ', theme),
                  const SizedBox(height: 8),
                  _buildAutoLockCard(theme, l10n),
                  const SizedBox(height: 24),
                ],

                // Security tips
                _buildSecurityTips(theme, l10n),
              ],
            ),
    );
  }

  Widget _buildSecurityHeader(ThemeData theme, S? l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isPinSet ? Icons.verified_user : Icons.shield_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPinSet
                      ? (l10n?.appProtected ?? 'แอปได้รับการปกป้อง')
                      : (l10n?.appNotLocked ?? 'แอปยังไม่ได้ล็อค'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPinSet
                      ? (l10n?.yourDataIsSafe ?? 'ข้อมูลของคุณปลอดภัย')
                      : (l10n?.setupPinForSecurity ?? 'ตั้งค่า PIN เพื่อความปลอดภัย'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppLockCard(ThemeData theme, S? l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (!_isPinSet)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(l10n?.setupPin ?? 'ตั้งค่า PIN'),
              subtitle: Text(l10n?.create6DigitPin ?? 'สร้างรหัส PIN 6 หลักเพื่อล็อคแอป'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _setupPin,
            )
          else ...[
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.green,
                ),
              ),
              title: Text(l10n?.pinIsSet ?? 'PIN ถูกตั้งค่าแล้ว'),
              subtitle: Text(l10n?.appWillBeLocked ?? 'แอปจะถูกล็อคทุกครั้งที่เปิด'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n?.enabled ?? 'เปิดใช้งาน',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n?.changePin ?? 'เปลี่ยน PIN'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePin,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.lock_open, color: Colors.red),
              title: Text(
                l10n?.disableAppLock ?? 'ปิดการล็อคแอป',
                style: const TextStyle(color: Colors.red),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: _removePin,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBiometricCard(ThemeData theme, S? l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isBiometricEnabled
                ? Colors.green[50]
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fingerprint,
            color: _isBiometricEnabled
                ? Colors.green
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(l10n?.useBiometric(_biometricTypeName) ?? 'ใช้ $_biometricTypeName'),
        subtitle: Text(
          _isBiometricEnabled
              ? (l10n?.unlockAppWith(_biometricTypeName) ?? 'ปลดล็อคแอปด้วย $_biometricTypeName')
              : (l10n?.enableBiometricToUnlock(_biometricTypeName) ?? 'เปิดใช้ $_biometricTypeName เพื่อปลดล็อคแอป'),
        ),
        value: _isBiometricEnabled,
        onChanged: _toggleBiometric,
      ),
    );
  }

  Widget _buildAutoLockCard(ThemeData theme, S? l10n) {
    final label = _autoLockTimeout == 0
        ? (l10n?.immediately ?? 'ทันที')
        : (l10n?.minutes(_autoLockTimeout) ?? '$_autoLockTimeout นาที');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.timer,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(l10n?.autoLock ?? 'ล็อคอัตโนมัติ'),
        subtitle: Text(l10n?.lockAfterInactivity(label) ?? 'ล็อคแอปหลังไม่ใช้งาน $label'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: _showAutoLockPicker,
      ),
    );
  }

  Widget _buildSecurityTips(ThemeData theme, S? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.securityTips ?? 'เคล็ดลับความปลอดภัย',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip(l10n?.securityTip1 ?? 'ใช้ PIN ที่ไม่ซ้ำกับแอปอื่น', theme),
          _buildTip(l10n?.securityTip2 ?? 'หลีกเลี่ยง PIN ที่เดาง่าย เช่น 123456', theme),
          _buildTip(l10n?.securityTip3 ?? 'เปิดใช้ Biometric เพื่อความสะดวก', theme),
          _buildTip(l10n?.securityTip4 ?? 'ตั้งค่าล็อคอัตโนมัติเพื่อความปลอดภัย', theme),
        ],
      ),
    );
  }

  Widget _buildTip(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.green[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
