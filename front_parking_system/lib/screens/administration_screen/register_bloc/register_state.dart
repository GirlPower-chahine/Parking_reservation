part of 'register_bloc.dart';

enum RegisterStatus {
  initial,
  loading,
  success,
  error,
}

class RegisterState {
  final RegisterStatus status;
  final AppException? exception;

  RegisterState({
    this.status = RegisterStatus.initial,
    this.exception,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    AppException? exception,
  }) {
    return RegisterState(
      status: status ?? this.status,
      exception: exception,
    );
  }
}
