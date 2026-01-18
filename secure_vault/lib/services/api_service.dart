import 'package:dio/dio.dart';
import '../core/models/user.dart';

/// API Service for communicating with backend
class ApiService {
  late final Dio _dio;
  String? _token;

  ApiService({String baseUrl = 'http://localhost:3000'}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Add interceptor for adding token to requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          _token = null;
        }
        return handler.next(error);
      },
    ));
  }

  /// Set authentication token
  void setToken(String? token) {
    _token = token;
  }

  /// Get current token
  String? getToken() => _token;

  /// Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          if (username != null) 'username': username,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/api/health');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all vaults
  Future<List<Map<String, dynamic>>> getVaults() async {
    try {
      final response = await _dio.get('/api/vaults');
      return List<Map<String, dynamic>>.from(response.data['vaults'] as List);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get single vault
  Future<Map<String, dynamic>> getVault(String id) async {
    try {
      final response = await _dio.get('/api/vaults/$id');
      return response.data['vault'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create vault
  Future<Map<String, dynamic>> createVault({
    required String name,
    required String encryptedMasterKey,
    required String salt,
  }) async {
    try {
      final response = await _dio.post(
        '/api/vaults',
        data: {
          'name': name,
          'encryptedMasterKey': encryptedMasterKey,
          'salt': salt,
        },
      );
      return response.data['vault'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update vault
  Future<void> updateVault(String id, {String? name, DateTime? lastAccessed}) async {
    try {
      await _dio.put(
        '/api/vaults/$id',
        data: {
          if (name != null) 'name': name,
          if (lastAccessed != null) 'lastAccessed': lastAccessed.toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete vault
  Future<void> deleteVault(String id) async {
    try {
      await _dio.delete('/api/vaults/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _dio.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/api/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'] as String;
      }
      return 'Server error: ${error.response?.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check if the server is running.';
    }
    return 'An error occurred: ${error.message}';
  }
}

/// Authentication response model
class AuthResponse {
  final String token;
  final User user;
  final String message;

  AuthResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String? ?? 'Success',
    );
  }
}
