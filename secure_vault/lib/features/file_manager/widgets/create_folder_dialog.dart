import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.create_new_folder,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(l10n?.createFolder ?? 'สร้างโฟลเดอร์ใหม่'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n?.folderName ?? 'ชื่อโฟลเดอร์',
            hintText: l10n?.enterFolderName ?? 'กรอกชื่อโฟลเดอร์',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.folder_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n?.enterFolderName ?? 'กรุณากรอกชื่อโฟลเดอร์';
            }
            if (value.length > 50) {
              return l10n?.vaultNameMaxLength ?? 'ชื่อโฟลเดอร์ต้องไม่เกิน 50 ตัวอักษร';
            }
            // Check for invalid characters
            final invalidChars = RegExp(r'[<>:"/\\|?*]');
            if (invalidChars.hasMatch(value)) {
              return l10n?.error ?? 'ชื่อโฟลเดอร์ไม่สามารถมีอักขระพิเศษ';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
          textInputAction: TextInputAction.done,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'ยกเลิก'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check),
          label: Text(l10n?.confirm ?? 'สร้าง'),
        ),
      ],
    );
  }
}
