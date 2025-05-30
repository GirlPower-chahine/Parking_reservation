import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../shared/core/models/user.dart';
import '../../../shared/core/exceptions/app_exception.dart';
import '../../../shared/core/models/auth/login/login_dto.dart';
import '../../../shared/core/services/repository/auth_repository.dart';
import '../../../shared/core/services/storage/local_storage.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginState()) {
    on<LoginRequested>(_onLoginRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<LoginState> emit,
      ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final loginResponse = await authRepository.login(event.loginDTO);

      await LocalStorage.saveToken(loginResponse.token);
      await LocalStorage.saveUser(User(
        id: loginResponse.userId,
        role: loginResponse.role,
        username: event.loginDTO.username,
      ));

      emit(state.copyWith(
        status: LoginStatus.success,
        token: loginResponse.token,
        user: User(
          id: loginResponse.userId,
          role: loginResponse.role,
          username: event.loginDTO.username,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.error,
        exception: AppException(e.toString()),
      ));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event,
      Emitter<LoginState> emit,
      ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final token = await LocalStorage.getToken();
      final user = await LocalStorage.getUser();

      if (token != null && user != null) {
        emit(state.copyWith(
          status: LoginStatus.success,
          token: token,
          user: user,
        ));
      } else {
        emit(state.copyWith(status: LoginStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.error,
        exception: AppException(e.toString()),
      ));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<LoginState> emit,
      ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      await LocalStorage.clearAll();
      emit(LoginState());
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.error,
        exception: AppException('Erreur lors de la déconnexion: ${e.toString()}'),
      ));
    }
  }
}