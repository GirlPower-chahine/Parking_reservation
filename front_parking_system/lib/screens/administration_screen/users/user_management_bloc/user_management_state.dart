part of 'user_management_bloc.dart';

enum UserManagementStatus {
  initial,
  loading,
  success,
  error,
  updating,
  deleting,
}

class UserManagementState {
  final UserManagementStatus status;
  final List<User> users;
  final String? currentRole;
  final String? message;
  final AppException? exception;

  UserManagementState({
    this.status = UserManagementStatus.initial,
    this.users = const [],
    this.currentRole,
    this.message,
    this.exception,
  });

  UserManagementState copyWith({
    UserManagementStatus? status,
    List<User>? users,
    String? currentRole,
    String? message,
    AppException? exception,
  }) {
    return UserManagementState(
      status: status ?? this.status,
      users: users ?? this.users,
      currentRole: currentRole ?? this.currentRole,
      message: message ?? this.message,
      exception: exception,
    );
  }
}
