import 'dart:typed_data';

/// Stub for web - file path reading not supported
Future<Uint8List?> readFileFromPath(String path) async {
  // Web doesn't support reading from file paths
  // Files should be picked with bytes loaded via FilePicker
  return null;
}
