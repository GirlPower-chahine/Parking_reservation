part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class LoginRequested extends LoginEvent {
  final LoginDTO loginDTO;

  LoginRequested(this.loginDTO);
}

class CheckAuthStatus extends LoginEvent {}

class LogoutRequested extends LoginEvent {}

