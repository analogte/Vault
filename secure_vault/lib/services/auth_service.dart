import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../core/models/user.dart';
import '../core/utils/logger.dart';

/// Service for managing authentication
class AuthService {
  static const String _tag = 'AuthService';
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  User? _currentUser;
  String? _token;

  AuthService(this._apiService);

  /// Get current user
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _token != null && _currentUser != null;

  /// Initialize - load token and user from storage
  Future<void> initialize() async {
    try {
      AppLogger.log('Starting auth initialization...', tag: _tag);

      // Try to read token with very short timeout
      try {
        _token = await _storage.read(key: _tokenKey).timeout(
          const Duration(milliseconds: 500),
          onTimeout: () {
            AppLogger.log('Token read timeout - assuming not logged in', tag: _tag);
            return null;
          },
        );
      } catch (e) {
        AppLogger.error('Token read error - assuming not logged in', tag: _tag, error: e);
        _token = null;
      }

      if (_token != null && _token!.isNotEmpty) {
        AppLogger.log('Token found, reading user data...', tag: _tag);
        _apiService.setToken(_token);

        try {
          final userJson = await _storage.read(key: _userKey).timeout(
            const Duration(milliseconds: 500),
            onTimeout: () {
              AppLogger.log('User data read timeout', tag: _tag);
              return null;
            },
          );

          if (userJson != null && userJson.isNotEmpty) {
            try {
              final userMap = json.decode(userJson) as Map<String, dynamic>;
              _currentUser = User.fromJson(userMap);
              AppLogger.log('User data loaded successfully', tag: _tag);
            } catch (e) {
              // If parsing fails, clear storage
              AppLogger.error('User data parse error - clearing auth', tag: _tag, error: e);
              _token = null;
              _currentUser = null;
            }
          } else {
            // If no user data but have token, clear token
            AppLogger.log('No user data found, clearing token', tag: _tag);
            _token = null;
            _currentUser = null;
          }
        } catch (e) {
          AppLogger.error('User data read error - clearing auth', tag: _tag, error: e);
          _token = null;
          _currentUser = null;
        }
      } else {
        AppLogger.log('No token found - user not logged in', tag: _tag);
        _token = null;
        _currentUser = null;
      }

      AppLogger.log('Auth initialization completed. isLoggedIn: $isLoggedIn', tag: _tag);
    } catch (e) {
      // Log error but don't block - assume not logged in
      AppLogger.error('Auth initialization error - assuming not logged in', tag: _tag, error: e);
      _token = null;
      _currentUser = null;
    }
  }

  /// Register new user
  Future<User> register({
    required String email,
    required String password,
    String? username,
  }) async {
    final response = await _apiService.register(
      email: email,
      password: password,
      username: username,
    );

    await _saveAuth(response.token, response.user);
    return response.user;
  }

  /// Login user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.login(
      email: email,
      password: password,
    );

    await _saveAuth(response.token, response.user);
    return response.user;
  }

  /// Logout user
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _apiService.setToken(null);
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  /// Save authentication data
  Future<void> _saveAuth(String token, User user) async {
    _token = token;
    _currentUser = user;
    _apiService.setToken(token);
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(
      key: _userKey,
      value: json.encode(user.toJson()),
    );
  }

  /// Check if server is available
  Future<bool> checkServerHealth() async {
    try {
      await _apiService.healthCheck();
      return true;
    } catch (e) {
      return false;
    }
  }
}
