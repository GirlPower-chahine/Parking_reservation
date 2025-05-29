part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterRequested extends RegisterEvent {
  final RegisterDTO registerDTO;

  RegisterRequested(this.registerDTO);
}