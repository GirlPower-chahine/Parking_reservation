import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../shared/core/exceptions/app_exception.dart';
import '../../../../shared/core/models/auth/register/register_dto.dart';
import '../../../../shared/core/services/repository/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc({required this.authRepository}) : super(RegisterState()) {
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<RegisterState> emit,
      ) async {
    emit(state.copyWith(status: RegisterStatus.loading));

    try {
      await authRepository.register(event.registerDTO);
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        exception: AppException(e.toString()),
      ));
    }
  }
}
