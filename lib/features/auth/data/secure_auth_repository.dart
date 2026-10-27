import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskflow/features/auth/domain/auth_repository.dart';
import 'package:taskflow/features/auth/domain/auth_user.dart';

/// Concrete [AuthRepository] storing credentials in hardware-backed encrypted vault.
class SecureAuthRepository implements AuthRepository {
  SecureAuthRepository(this._storage);

  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'taskflow_auth_token';
  static const String _userKey = 'taskflow_auth_user';

  @override
  Future<AuthUser?> getCurrentUser() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;

    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      return AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    // In our client-first strategy, we validate credentials
    if (email.trim().isEmpty || password.length < 6) {
      throw const FormatException(
        'Invalid email or password (min 6 characters).',
      );
    }

    // Generate mock JWT token & authenticated user
    final token = 'jwt_secure_${DateTime.now().millisecondsSinceEpoch}';
    final user = AuthUser(
      id: 'usr_${email.hashCode.abs()}',
      email: email,
      displayName: email.split('@').first,
    );

    // Save into encrypted hardware vault
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _tokenKey);
  }
}
