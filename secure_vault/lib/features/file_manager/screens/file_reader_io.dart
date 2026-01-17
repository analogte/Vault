import 'dart:io';
import 'dart:typed_data';
import '../../../core/utils/logger.dart';

const String _tag = 'FileReaderIO';

/// Read file bytes from path (mobile/desktop only)
Future<Uint8List?> readFileFromPath(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  } catch (e) {
    AppLogger.error('Error reading file', tag: _tag, error: e);
    return null;
  }
}
