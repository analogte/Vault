import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../core/utils/logger.dart';

/// Service for cloud backup to Google Drive
class CloudBackupService extends ChangeNotifier {
  static const String _tag = 'CloudBackupService';
  static const String _backupFolderName = 'SecureVault Backups';
  static const String _mimeTypeFolder = 'application/vnd.google-apps.folder';
  static const String _mimeTypeBackup = 'application/octet-stream';

  static final List<String> _scopes = [
    drive.DriveApi.driveFileScope,
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  bool _isSignedIn = false;
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  double _downloadProgress = 0.0;
  String? _statusMessage;

  // Getters
  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;
  double get downloadProgress => _downloadProgress;
  String? get statusMessage => _statusMessage;
  String? get userEmail => _currentUser?.email;
  String? get userDisplayName => _currentUser?.displayName;
  String? get userPhotoUrl => _currentUser?.photoUrl;

  CloudBackupService() {
    _initializeAndCheckSignIn();
  }

  /// Initialize GoogleSignIn and check if user is already signed in
  Future<void> _initializeAndCheckSignIn() async {
    try {
      // Initialize GoogleSignIn first (required in 7.x)
      if (!_isInitialized) {
        await _googleSignIn.initialize();
        _isInitialized = true;
      }

      // Check for existing sign-in
      _currentUser = await _googleSignIn.attemptLightweightAuthentication();
      if (_currentUser != null) {
        await _initDriveApi();
        _isSignedIn = true;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Initialize/check sign in error', tag: _tag, error: e);
    }
  }

  /// Initialize Drive API with user credentials
  Future<void> _initDriveApi() async {
    if (_currentUser == null) return;

    try {
      // Get authorization for Drive API scope
      final authClient = _currentUser!.authorizationClient;
      final authorization = await authClient.authorizeScopes(_scopes);

      final client = GoogleAuthClient(authorization.accessToken);
      _driveApi = drive.DriveApi(client);
    } catch (e) {
      AppLogger.error('Failed to initialize Drive API', tag: _tag, error: e);
      throw Exception('Failed to get access token');
    }
  }

  /// Sign in to Google
  Future<bool> signIn() async {
    try {
      _setLoading(true);
      _statusMessage = 'กำลังเข้าสู่ระบบ...';
      notifyListeners();

      // Ensure initialized
      if (!_isInitialized) {
        await _googleSignIn.initialize();
        _isInitialized = true;
      }

      // Check if authenticate is supported on this platform
      if (!_googleSignIn.supportsAuthenticate()) {
        _statusMessage = 'แพลตฟอร์มนี้ไม่รองรับ Google Sign-In';
        _setLoading(false);
        return false;
      }

      _currentUser = await _googleSignIn.authenticate(scopeHint: _scopes);
      await _initDriveApi();
      _isSignedIn = true;
      _statusMessage = null;
      _setLoading(false);

      AppLogger.log('Signed in: ${_currentUser?.email}', tag: _tag);
      return true;
    } on GoogleSignInException catch (e) {
      AppLogger.error('Sign in error: ${e.code}', tag: _tag, error: e);
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _statusMessage = null;
      } else {
        _statusMessage = 'เข้าสู่ระบบไม่สำเร็จ: ${e.description ?? e.code.name}';
      }
      _setLoading(false);
      return false;
    } catch (e) {
      AppLogger.error('Sign in error', tag: _tag, error: e);
      _statusMessage = 'เข้าสู่ระบบไม่สำเร็จ: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _driveApi = null;
      _isSignedIn = false;
      notifyListeners();
      AppLogger.log('Signed out', tag: _tag);
    } catch (e) {
      AppLogger.error('Sign out error', tag: _tag, error: e);
    }
  }

  /// Get or create backup folder in Drive
  Future<String> _getOrCreateBackupFolder() async {
    if (_driveApi == null) throw Exception('Not signed in');

    // Search for existing folder
    final query = "name = '$_backupFolderName' and mimeType = '$_mimeTypeFolder' and trashed = false";
    final fileList = await _driveApi!.files.list(q: query);

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first.id!;
    }

    // Create new folder
    final folder = drive.File()
      ..name = _backupFolderName
      ..mimeType = _mimeTypeFolder;

    final createdFolder = await _driveApi!.files.create(folder);
    return createdFolder.id!;
  }

  /// Upload backup to Google Drive
  Future<bool> uploadBackup({
    required File backupFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    if (_driveApi == null) {
      _statusMessage = 'กรุณาเข้าสู่ระบบก่อน';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _uploadProgress = 0.0;
      _statusMessage = 'กำลังเตรียมอัปโหลด...';
      notifyListeners();

      // Get or create backup folder
      final folderId = await _getOrCreateBackupFolder();

      // Check if file with same name exists
      final query = "name = '$fileName' and '$folderId' in parents and trashed = false";
      final existing = await _driveApi!.files.list(q: query);

      // Delete existing backup with same name
      if (existing.files != null && existing.files!.isNotEmpty) {
        _statusMessage = 'กำลังลบไฟล์เก่า...';
        notifyListeners();
        for (final file in existing.files!) {
          await _driveApi!.files.delete(file.id!);
        }
      }

      // Prepare file metadata
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [folderId]
        ..mimeType = _mimeTypeBackup
        ..description = 'SecureVault Backup - ${DateTime.now().toIso8601String()}';

      // Read file content
      final fileLength = await backupFile.length();
      final stream = backupFile.openRead();

      _statusMessage = 'กำลังอัปโหลด...';
      notifyListeners();

      // Upload with progress tracking
      final media = drive.Media(
        stream,
        fileLength,
      );

      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      _uploadProgress = 1.0;
      _statusMessage = 'อัปโหลดสำเร็จ';
      notifyListeners();

      AppLogger.log('Uploaded backup: ${result.name}', tag: _tag);
      _setLoading(false);
      return true;
    } catch (e) {
      AppLogger.error('Upload error', tag: _tag, error: e);
      _statusMessage = 'อัปโหลดไม่สำเร็จ: $e';
      _setLoading(false);
      return false;
    }
  }

  /// List all backups from Google Drive
  Future<List<CloudBackupInfo>> listBackups() async {
    if (_driveApi == null) return [];

    try {
      final folderId = await _getOrCreateBackupFolder();
      final query = "'$folderId' in parents and trashed = false";
      final fileList = await _driveApi!.files.list(
        q: query,
        $fields: 'files(id,name,size,createdTime,modifiedTime)',
        orderBy: 'modifiedTime desc',
      );

      if (fileList.files == null) return [];

      return fileList.files!
          .where((f) => f.name?.endsWith('.svbackup') ?? false)
          .map((f) => CloudBackupInfo(
                id: f.id!,
                name: f.name!,
                size: int.tryParse(f.size ?? '0') ?? 0,
                createdAt: f.createdTime ?? DateTime.now(),
                modifiedAt: f.modifiedTime ?? DateTime.now(),
              ))
          .toList();
    } catch (e) {
      AppLogger.error('List backups error', tag: _tag, error: e);
      return [];
    }
  }

  /// Download backup from Google Drive
  Future<File?> downloadBackup({
    required String fileId,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    if (_driveApi == null) {
      _statusMessage = 'กรุณาเข้าสู่ระบบก่อน';
      notifyListeners();
      return null;
    }

    try {
      _setLoading(true);
      _downloadProgress = 0.0;
      _statusMessage = 'กำลังดาวน์โหลด...';
      notifyListeners();

      // Download file
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      final sink = tempFile.openWrite();

      await for (final data in media.stream) {
        sink.add(data);
      }
      await sink.close();

      _downloadProgress = 1.0;
      _statusMessage = 'ดาวน์โหลดสำเร็จ';
      notifyListeners();

      AppLogger.log('Downloaded backup: $fileName', tag: _tag);
      _setLoading(false);
      return tempFile;
    } catch (e) {
      AppLogger.error('Download error', tag: _tag, error: e);
      _statusMessage = 'ดาวน์โหลดไม่สำเร็จ: $e';
      _setLoading(false);
      return null;
    }
  }

  /// Delete backup from Google Drive
  Future<bool> deleteBackup(String fileId) async {
    if (_driveApi == null) return false;

    try {
      await _driveApi!.files.delete(fileId);
      AppLogger.log('Deleted backup: $fileId', tag: _tag);
      return true;
    } catch (e) {
      AppLogger.error('Delete backup error', tag: _tag, error: e);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) {
      _uploadProgress = 0.0;
      _downloadProgress = 0.0;
    }
    notifyListeners();
  }

  void clearStatus() {
    _statusMessage = null;
    notifyListeners();
  }
}

/// Custom HTTP client that uses Google auth token
class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }
}

/// Info about a cloud backup
class CloudBackupInfo {
  final String id;
  final String name;
  final int size;
  final DateTime createdAt;
  final DateTime modifiedAt;

  CloudBackupInfo({
    required this.id,
    required this.name,
    required this.size,
    required this.createdAt,
    required this.modifiedAt,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get formattedDate {
    return '${modifiedAt.day}/${modifiedAt.month}/${modifiedAt.year} ${modifiedAt.hour}:${modifiedAt.minute.toString().padLeft(2, '0')}';
  }
}
