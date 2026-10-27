import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/auth/data/auth_interceptor.dart';
import 'package:taskflow/features/auth/domain/auth_repository.dart';
import 'package:taskflow/features/auth/domain/auth_user.dart';
import 'package:taskflow/features/auth/presentation/providers/auth_providers.dart';

/// Fake repository for fast headless testing
class FakeAuthRepository implements AuthRepository {
  AuthUser? _user;
  String? _token;

  @override
  Future<AuthUser?> getCurrentUser() async => _user;

  @override
  Future<String?> getAccessToken() async => _token;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    _token = 'fake_jwt_token_123';
    _user = AuthUser(id: 'u-1', email: email, displayName: 'Alice');
    return _user!;
  }

  @override
  Future<void> logout() async {
    _user = null;
    _token = null;
  }
}

void main() {
  group('Auth Feature Tests', () {
    test('AuthUser serialization and value equality', () {
      const user = AuthUser(
        id: 'u-42',
        email: 'alice@example.com',
        displayName: 'Alice',
      );

      final json = user.toJson();
      final reconstructed = AuthUser.fromJson(json);

      expect(reconstructed, equals(user));
      expect(reconstructed.id, 'u-42');
      expect(reconstructed.email, 'alice@example.com');
    });

    test('AuthNotifier updates state on login and logout', () async {
      final fakeRepo = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      // Initial state is unauthenticated
      expect(await container.read(authNotifierProvider.future), isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);

      // Login
      await container
          .read(authNotifierProvider.notifier)
          .login(email: 'alice@example.com', password: 'password123');

      final user = await container.read(authNotifierProvider.future);
      expect(user, isNotNull);
      expect(user?.email, 'alice@example.com');
      expect(container.read(isAuthenticatedProvider), isTrue);

      // Logout
      await container.read(authNotifierProvider.notifier).logout();
      expect(await container.read(authNotifierProvider.future), isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
    });

    test(
      'AuthInterceptor attaches Bearer token to Dio RequestOptions',
      () async {
        final fakeRepo = FakeAuthRepository();
        await fakeRepo.login(email: 'test@example.com', password: 'password');

        final interceptor = AuthInterceptor(fakeRepo);
        final options = RequestOptions(path: '/api/v1/tasks');

        await interceptor.onRequest(options, RequestInterceptorHandler());

        expect(options.headers['Authorization'], 'Bearer fake_jwt_token_123');
      },
    );
  });
}
