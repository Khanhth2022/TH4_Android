import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService(),
        _user = authService?.currentUser {
    _user ??= _authService.currentUser;
    _subscription = _authService.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthService _authService;
  StreamSubscription<User?>? _subscription;

  User? _user;
  bool _isSubmitting = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _runAuthAction(() {
      return _authService.signInWithEmail(email: email, password: password);
    });
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _runAuthAction(() {
      return _authService.registerWithEmail(email: email, password: password);
    });
  }

  Future<bool> signInWithGoogle() {
    return _runAuthAction(_authService.signInWithGoogle);
  }

  Future<void> signOut() async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signOut();
    } on FirebaseAuthException catch (e) {
      _error = _firebaseErrorToMessage(e);
    } catch (_) {
      _error = 'Đăng xuất thất bại, vui lòng thử lại.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> _runAuthAction(
    Future<UserCredential> Function() action,
  ) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _firebaseErrorToMessage(e);
      return false;
    } on GoogleSignInException catch (e) {
      _error = _googleErrorToMessage(e);
      return false;
    } catch (e) {
      final raw = e.toString();
      if (raw.contains('ApiException: 10')) {
        _error =
            'Google Sign-In chưa được cấu hình đúng SHA-1/SHA-256 trên Firebase.';
      } else if (raw.contains('network')) {
        _error = 'Mất kết nối mạng, vui lòng thử lại.';
      } else {
        _error = 'Có lỗi xảy ra, vui lòng thử lại.';
      }
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  String _firebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (ít nhất 6 ký tự).';
      case 'network-request-failed':
        return 'Mất kết nối mạng, vui lòng thử lại.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật trên Firebase Authentication.';
      case 'account-exists-with-different-credential':
        return 'Email này đã tồn tại với phương thức đăng nhập khác.';
      case 'popup-closed-by-user':
        return 'Bạn đã đóng cửa sổ đăng nhập Google.';
      case 'too-many-requests':
        return 'Thao tác quá nhiều lần, vui lòng thử lại sau.';
      default:
        return e.message ?? 'Xác thực thất bại, vui lòng thử lại.';
    }
  }

  String _googleErrorToMessage(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Bạn đã hủy đăng nhập Google.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google Sign-In chưa cấu hình đúng. Kiểm tra SHA-1/SHA-256 và file google-services.json.';
      default:
        return 'Đăng nhập Google thất bại: ${e.description ?? e.code.name}';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
