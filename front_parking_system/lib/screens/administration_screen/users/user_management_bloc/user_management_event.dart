part of 'user_management_bloc.dart';



@immutable
sealed class UserManagementEvent {}

class LoadUsersRequested extends UserManagementEvent {
  final String? role;

  LoadUsersRequested({this.role});
}

class UpdateUserRequested extends UserManagementEvent {
  final String userId;
  final Map<String, dynamic> data;

  UpdateUserRequested({
    required this.userId,
    required this.data,
  });
}

class DeleteUserRequested extends UserManagementEvent {
  final String userId;

  DeleteUserRequested({required this.userId});
}