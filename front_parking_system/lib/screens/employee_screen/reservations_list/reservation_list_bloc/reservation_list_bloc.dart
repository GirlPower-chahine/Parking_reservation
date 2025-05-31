// lib/screens/employee_screen/reservation_list_bloc/reservation_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/core/models/reservation/reservation_dto.dart';
import '../../../../shared/core/services/repository/parking_repository.dart';


part 'reservation_list_event.dart';
part 'reservation_list_state.dart';

class ReservationListBloc extends Bloc<ReservationListEvent, ReservationListState> {
  final ParkingRepository repository;

  ReservationListBloc({required this.repository}) : super(const ReservationListState()) {
    on<LoadReservations>(_onLoadReservations);
  }

  Future<void> _onLoadReservations(
      LoadReservations event,
      Emitter<ReservationListState> emit,
      ) async {
    emit(state.copyWith(status: ReservationListStatus.loading));
    try {
      final reservations = await repository.getMyReservations();
      emit(state.copyWith(
        status: ReservationListStatus.success,
        reservations: reservations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReservationListStatus.error,
        error: e.toString(),
      ));
    }
  }
}
