import 'dart:typed_data';

/// Stub for web - file path reading not supported
Future<Uint8List?> readFileFromPath(String path) async {
  // Web doesn't support reading from file paths
  // Files should be picked with bytes loaded via FilePicker
  return null;
}

/// Web stub - File class wrapper that mimics dart:io File for web
class WebFileMock {
  Future<bool> exists() async => false;
  Future<void> delete() async {}
}

/// Stub for web - file deletion not supported
Future<WebFileMock?> getFileFromPath(String path) async {
  // Web doesn't support file deletion from local storage
  return null;
}
