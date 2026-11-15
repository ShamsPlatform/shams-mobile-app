import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/complete_sign_up_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/get_current_auth_user_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:shams_mobile_app/features/auth/domain/usecases/watch_auth_state_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required WatchAuthStateUseCase watchAuthState,
    required GetCurrentAuthUserUseCase getCurrentAuthUser,
    required SignInWithEmailUseCase signInWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required CompleteSignUpUseCase completeSignUp,
    required SignOutUseCase signOut,
  })  : _watchAuthState = watchAuthState,
        _getCurrentAuthUser = getCurrentAuthUser,
        _signInWithEmail = signInWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _completeSignUp = completeSignUp,
        _signOut = signOut;

  final WatchAuthStateUseCase _watchAuthState;
  final GetCurrentAuthUserUseCase _getCurrentAuthUser;
  final SignInWithEmailUseCase _signInWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final CompleteSignUpUseCase _completeSignUp;
  final SignOutUseCase _signOut;

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _currentUser;
  ViewStatus _actionStatus = ViewStatus.initial;
  String? _errorMessage;
  List<String> _warnings = const [];

  StreamSubscription<AuthUser?>? _authSub;
  bool _bufferingAuthEvents = false;
  bool _hasBufferedAuthEvent = false;
  AuthUser? _bufferedAuthUser;
  bool _disposed = false;

  AuthStatus get status => _status;
  AuthUser? get currentUser => _currentUser;
  ViewStatus get actionStatus => _actionStatus;
  bool get isBusy => _actionStatus == ViewStatus.loading;
  String? get errorMessage => _errorMessage;
  List<String> get warnings => _warnings;

  void start() {
    if (_authSub != null) return;
    _authSub = _watchAuthState(const NoParams()).listen(
      _onAuthUserChanged,
      onError: (_) {
        if (!_bufferingAuthEvents) {
          _applyAuthUser(_getCurrentAuthUser());
        }
      },
    );
  }

  void _onAuthUserChanged(AuthUser? user) {
    if (_bufferingAuthEvents) {
      _hasBufferedAuthEvent = true;
      _bufferedAuthUser = user;
      return;
    }
    _applyAuthUser(user);
  }

  void _applyAuthUser(AuthUser? user) {
    final nextStatus =
        user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    if (_status == nextStatus && _currentUser == user) return;
    _currentUser = user;
    _status = nextStatus;
    _safeNotify();
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _beginAction();
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: email, password: password),
    );
    return switch (result) {
      Ok(:final data) => () {
          _actionStatus = ViewStatus.success;
          _applyAuthUser(data);
          _safeNotify();
          return true;
        }(),
      Err(:final failure) => () {
          _actionStatus = ViewStatus.failure;
          _errorMessage = failure.message;
          _safeNotify();
          return false;
        }(),
    };
  }

  Future<bool> signInWithGoogle() async {
    _beginAction();
    final result = await _signInWithGoogle(const NoParams());
    return switch (result) {
      Ok() => () {
          _actionStatus = ViewStatus.success;
          _safeNotify();
          return true;
        }(),
      Err(:final failure) => () {
          _actionStatus = ViewStatus.failure;
          _errorMessage = failure.message;
          _safeNotify();
          return false;
        }(),
    };
  }

  Future<bool> completeSignUp(SignUpParams params) async {
    _beginAction();
    _bufferingAuthEvents = true;
    _hasBufferedAuthEvent = false;
    _bufferedAuthUser = null;

    try {
      final result = await _completeSignUp(params);
      return switch (result) {
        Ok(:final data) => () {
            _actionStatus = ViewStatus.success;
            _warnings = data.warnings;
            _bufferingAuthEvents = false;
            final userToApply =
                _hasBufferedAuthEvent ? _bufferedAuthUser : data.user;
            _hasBufferedAuthEvent = false;
            _bufferedAuthUser = null;
            _applyAuthUser(userToApply);
            _safeNotify();
            return true;
          }(),
        Err(:final failure) => () {
            _actionStatus = ViewStatus.failure;
            _errorMessage = failure.message;
            _bufferingAuthEvents = false;
            if (_hasBufferedAuthEvent) {
              final buffered = _bufferedAuthUser;
              _hasBufferedAuthEvent = false;
              _bufferedAuthUser = null;
              _applyAuthUser(buffered);
            }
            _safeNotify();
            return false;
          }(),
      };
    } finally {
      _bufferingAuthEvents = false;
      _hasBufferedAuthEvent = false;
      _bufferedAuthUser = null;
    }
  }

  Future<bool> signOut() async {
    _beginAction();
    final result = await _signOut(const NoParams());
    return switch (result) {
      Ok() => () {
          _actionStatus = ViewStatus.success;
          _applyAuthUser(null);
          _safeNotify();
          return true;
        }(),
      Err(:final failure) => () {
          _actionStatus = ViewStatus.failure;
          _errorMessage = failure.message;
          _safeNotify();
          return false;
        }(),
    };
  }

  void clearFeedback() {
    _errorMessage = null;
    _warnings = const [];
    if (_actionStatus != ViewStatus.initial) {
      _actionStatus = ViewStatus.initial;
    }
    _safeNotify();
  }

  void _beginAction() {
    _errorMessage = null;
    _warnings = const [];
    _actionStatus = ViewStatus.loading;
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authSub?.cancel();
    _authSub = null;
    super.dispose();
  }
}
