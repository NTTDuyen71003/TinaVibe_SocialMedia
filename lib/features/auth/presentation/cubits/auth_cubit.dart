/*
States Management : quản lý trạng thái cho quá trình xác thực, sử dụng Bloc
*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/entities/app_user.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter_firebase_mxh_tinavibe/features/auth/presentation/cubits/auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AppUser? _currentUser;
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  // kiểm tra xem người dùng xác thực(đăng nhập) hay chưa ?
  void checkAuth() async {
    final AppUser? user = await authRepository.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  // lấy thông tin người dùng hiện tại
  AppUser? get currentUser => _currentUser;

  // đăng nhập với email + mật khẩu.
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepository.loginWithEmailPassword(email, password);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // đăng ký người dùng mới với tên, email và mật khẩu.
  Future<void> register(String name, String email, String password) async {
    try {
      emit(AuthLoading());
      final user =
          await authRepository.registerWithEmailPassword(name, email, password);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // logout
  Future<void> logout() async {
    authRepository.logout();
    emit(Unauthenticated());
  }

  // Đăng nhập bằng Google
  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      final user = await authRepository.signInWithGoogle();

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}
