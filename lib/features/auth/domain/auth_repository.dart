import 'package:taskflow/features/auth/domain/auth_user.dart';

/// Abstract contract for authentication and session token management.
abstract interface class AuthRepository {
  /// Returns the currently authenticated [AuthUser], or `null` if unauthenticated.
  Future<AuthUser?> getCurrentUser();

  /// Authenticates using [email] and [password], returning the [AuthUser].
  Future<AuthUser> login({required String email, required String password});

  /// Logs the user out and clears all stored tokens.
  Future<void> logout();

  /// Retrieves the current encrypted access token, or `null` if unauthenticated.
  Future<String?> getAccessToken();
}
