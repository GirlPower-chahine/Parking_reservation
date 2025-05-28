part of 'login_bloc.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

class LoginState {
  final LoginStatus status;
  final User? user;
  final String? token;
  final AppException? exception;

  LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.token,
    this.exception,
  });

  LoginState copyWith({
    LoginStatus? status,
    User? user,
    String? token,
    AppException? exception,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      exception: exception ?? this.exception,
    );
  }
}


