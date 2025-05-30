import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../shared/core/exceptions/app_exception.dart';
import '../../../../shared/core/models/user.dart';
import '../../../../shared/core/services/repository/user_repository.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';

class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final UserRepository userRepository;

  UserManagementBloc({required this.userRepository}) : super(UserManagementState()) {
    on<LoadUsersRequested>(_onLoadUsersRequested);
    on<UpdateUserRequested>(_onUpdateUserRequested);
    on<DeleteUserRequested>(_onDeleteUserRequested);
  }

  Future<void> _onLoadUsersRequested(
      LoadUsersRequested event,
      Emitter<UserManagementState> emit,
      ) async {
    emit(state.copyWith(status: UserManagementStatus.loading));

    try {
      final users = await userRepository.fetchUsers(role: event.role);

      if (users.isEmpty) {
        final roleLabel = _getRoleLabel(event.role);
        emit(state.copyWith(
          status: UserManagementStatus.success,
          users: [],
          currentRole: event.role,
          message: 'Aucun $roleLabel trouvé.',
        ));
      } else {
        emit(state.copyWith(
          status: UserManagementStatus.success,
          users: users,
          currentRole: event.role,
          message: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: UserManagementStatus.error,
        exception: AppException(e.toString()),
      ));
    }
  }

  Future<void> _onUpdateUserRequested(
      UpdateUserRequested event,
      Emitter<UserManagementState> emit,
      ) async {
    emit(state.copyWith(status: UserManagementStatus.updating));

    try {
      final updatedUser = await userRepository.updateUser(event.userId, event.data);

      // Update the user in the current list
      final updatedUsers = state.users.map((user) {
        return user.id == event.userId ? updatedUser : user;
      }).toList();

      emit(state.copyWith(
        status: UserManagementStatus.success,
        users: updatedUsers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserManagementStatus.error,
        exception: AppException(e.toString()),
      ));
    }
  }

  Future<void> _onDeleteUserRequested(
      DeleteUserRequested event,
      Emitter<UserManagementState> emit,
      ) async {
    emit(state.copyWith(status: UserManagementStatus.deleting));

    try {
      await userRepository.deleteUser(event.userId);

      // Remove the user from the current list
      final updatedUsers = state.users.where((user) => user.id != event.userId).toList();

      emit(state.copyWith(
        status: UserManagementStatus.success,
        users: updatedUsers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserManagementStatus.error,
        exception: AppException(e.toString()),
      ));
    }
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'managers':
        return 'manager';
      case 'employees':
        return 'employé';
      case 'secretaries':
        return 'secrétaire';
      default:
        return 'utilisateur';
    }
  }
}