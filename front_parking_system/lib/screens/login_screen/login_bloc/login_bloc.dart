import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

import '../../../../shared/core/models/user.dart';
import '../../../shared/core/exceptions/app_exception.dart';
import '../../../shared/core/models/auth/login/login_dto.dart';
import '../../../shared/core/services/repository/auth_repository.dart';

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
    // TODO: Implémenter la vérification du statut d'authentification
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<LoginState> emit,
      ) async {
    final storage = FlutterSecureStorage();
    await storage.deleteAll();

    emit(LoginState());
  }
}
