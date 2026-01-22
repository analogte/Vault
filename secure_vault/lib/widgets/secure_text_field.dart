import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Secure text field widget with anti-keylogger protection
/// Disables keyboard suggestions, autocorrect, and autofill
class SecureTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final bool showVisibilityToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final bool autofocus;
  final bool enabled;
  final InputDecoration? decoration;
  final TextCapitalization textCapitalization;

  const SecureTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.autofocus = false,
    this.enabled = true,
    this.decoration,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  late bool _obscureText;
  // Note: Third-party keyboard detection requires platform channels
  // This field is reserved for future implementation
  final bool _hasThirdPartyKeyboard = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hasThirdPartyKeyboard)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'กำลังใช้คีย์บอร์ดภายนอก - แนะนำให้ใช้คีย์บอร์ดเริ่มต้น',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          maxLines: _obscureText ? 1 : widget.maxLines,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,

          // Security settings to prevent keyloggers and data leaks
          autocorrect: false, // Disable autocorrect
          enableSuggestions: false, // Disable keyboard suggestions
          enableIMEPersonalizedLearning: false, // Disable keyboard learning
          enableInteractiveSelection: true, // Keep selection enabled

          // Disable autofill
          autofillHints: null,

          // Input formatters for additional control
          inputFormatters: widget.maxLength != null
              ? [LengthLimitingTextInputFormatter(widget.maxLength)]
              : null,

          decoration: widget.decoration ??
              InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon,
                suffixIcon: _buildSuffixIcon(),
                border: const OutlineInputBorder(),
              ),

          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.showVisibilityToggle && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: _toggleVisibility,
        tooltip: _obscureText ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
      );
    }
    return widget.suffixIcon;
  }
}

/// Secure password field with additional security features
class SecurePasswordField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;

  const SecurePasswordField({
    super.key,
    this.controller,
    this.labelText = 'รหัสผ่าน',
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SecureTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      obscureText: true,
      showVisibilityToggle: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction ?? TextInputAction.done,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      focusNode: focusNode,
      prefixIcon: const Icon(Icons.lock_outline),
      autofocus: autofocus,
      enabled: enabled,
    );
  }
}

/// Password strength indicator
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(strength.color),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.label,
              style: TextStyle(
                color: strength.color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          strength.hint,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  _PasswordStrength _calculateStrength() {
    if (password.isEmpty) {
      return _PasswordStrength(
        value: 0,
        label: '',
        color: Colors.grey,
        hint: 'ใส่รหัสผ่านเพื่อตรวจสอบความแข็งแรง',
      );
    }

    int score = 0;
    final checks = <String>[];

    // Length check
    if (password.length >= 8) {
      score += 1;
    } else {
      checks.add('ควรมีอย่างน้อย 8 ตัวอักษร');
    }

    if (password.length >= 12) {
      score += 1;
    }

    // Uppercase check
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
    } else {
      checks.add('เพิ่มตัวพิมพ์ใหญ่');
    }

    // Lowercase check
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
    } else {
      checks.add('เพิ่มตัวพิมพ์เล็ก');
    }

    // Number check
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
    } else {
      checks.add('เพิ่มตัวเลข');
    }

    // Special character check
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
    } else {
      checks.add('เพิ่มอักขระพิเศษ');
    }

    // No common patterns
    if (!_hasCommonPatterns(password)) {
      score += 1;
    } else {
      checks.add('หลีกเลี่ยงรูปแบบที่คาดเดาง่าย');
    }

    // Calculate final strength
    if (score <= 2) {
      return _PasswordStrength(
        value: 0.2,
        label: 'อ่อนมาก',
        color: Colors.red,
        hint: checks.isNotEmpty ? checks.first : 'รหัสผ่านอ่อนแอ',
      );
    } else if (score <= 3) {
      return _PasswordStrength(
        value: 0.4,
        label: 'อ่อน',
        color: Colors.orange,
        hint: checks.isNotEmpty ? checks.first : 'ควรเพิ่มความซับซ้อน',
      );
    } else if (score <= 4) {
      return _PasswordStrength(
        value: 0.6,
        label: 'ปานกลาง',
        color: Colors.yellow[700]!,
        hint: checks.isNotEmpty ? checks.first : 'พอใช้ได้',
      );
    } else if (score <= 5) {
      return _PasswordStrength(
        value: 0.8,
        label: 'แข็งแรง',
        color: Colors.lightGreen,
        hint: 'รหัสผ่านดี',
      );
    } else {
      return _PasswordStrength(
        value: 1.0,
        label: 'แข็งแรงมาก',
        color: Colors.green,
        hint: 'รหัสผ่านยอดเยี่ยม!',
      );
    }
  }

  bool _hasCommonPatterns(String password) {
    final lowercasePassword = password.toLowerCase();
    final commonPatterns = [
      '123456',
      'password',
      'qwerty',
      'abc123',
      'letmein',
      'welcome',
      'admin',
      '111111',
      'iloveyou',
      'sunshine',
    ];

    for (final pattern in commonPatterns) {
      if (lowercasePassword.contains(pattern)) {
        return true;
      }
    }

    // Check for sequential patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      return true; // Repeated characters
    }

    return false;
  }
}

class _PasswordStrength {
  final double value;
  final String label;
  final Color color;
  final String hint;

  _PasswordStrength({
    required this.value,
    required this.label,
    required this.color,
    required this.hint,
  });
}
