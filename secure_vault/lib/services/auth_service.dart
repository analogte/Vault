import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../core/models/user.dart';

/// Service for managing authentication
class AuthService {
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
      _token = await _storage.read(key: _tokenKey);
      if (_token != null) {
        _apiService.setToken(_token);
        final userJson = await _storage.read(key: _userKey);
        if (userJson != null) {
          try {
            final userMap = json.decode(userJson) as Map<String, dynamic>;
            _currentUser = User.fromJson(userMap);
          } catch (e) {
            // If parsing fails, clear storage
            await logout();
          }
        }
      }
    } catch (e) {
      // Ignore errors during initialization
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
