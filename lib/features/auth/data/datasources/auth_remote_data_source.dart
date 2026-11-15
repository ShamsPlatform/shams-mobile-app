import 'package:shams_mobile_app/core/config/env.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

abstract interface class AuthRemoteDataSource {
  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final sb.SupabaseClient _client;

  AuthUser _toAuthUser(sb.User user) {
    final fullName = user.userMetadata?['full_name'];
    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: fullName is String ? fullName : null,
    );
  }

  @override
  AuthUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _toAuthUser(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield currentUser;
    yield* _client.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      return user == null ? null : _toAuthUser(user);
    });
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const AppAuthException('فشل تسجيل الدخول');
      }
      return _toAuthUser(user);
    } on sb.AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw const AppAuthException('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }
      if (e.message.contains('Email not confirmed')) {
        throw const AppAuthException('يرجى تأكيد بريدك الإلكتروني أولاً');
      }
      throw AppAuthException('حدث خطأ أثناء تسجيل الدخول: ${e.message}');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final launched = await _client.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: Env.oauthRedirectUrl,
      );
      if (!launched) {
        throw const AppAuthException('فشل تسجيل الدخول عبر جوجل');
      }
    } on sb.AuthException catch (e) {
      throw AppAuthException('حدث خطأ أثناء التسجيل: ${e.message}');
    }
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      final user = res.user;
      if (user == null) {
        throw const AppAuthException('فشل إنشاء الحساب');
      }
      return _toAuthUser(user);
    } on sb.AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        throw const AppAuthException(
          'هذا البريد الإلكتروني مسجل مسبقاً، حاول تسجيل الدخول من الشاشة السابقة',
        );
      }
      throw AppAuthException('حدث خطأ أثناء إكمال الحساب: ${e.message}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on sb.AuthException catch (e) {
      throw AppAuthException(e.message);
    }
  }
}
