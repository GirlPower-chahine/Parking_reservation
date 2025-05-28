import 'package:bloc/bloc.dart';
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
    // TODO: Implémenter la logique de connexion
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
    // TODO: Implémenter la logique de déconnexion
  }
}
