import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/core/models/reservation/reservation_request_dto.dart';
import '../../../shared/core/services/repository/parking_repository.dart';

part 'reservation_event.dart';
part 'reservation_state.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ParkingRepository repository;

  ReservationBloc({required this.repository}) : super(const ReservationState()) {
    on<CreateReservation>(_onCreateReservation);
  }

  Future<void> _onCreateReservation(
      CreateReservation event,
      Emitter<ReservationState> emit,
      ) async {
    emit(state.copyWith(status: ReservationStatus.loading));
    try {
      final confirmationCode = await repository.createReservation(
        ReservationRequestDTO(
          reservationDate: event.date,
          timeSlot: event.timeSlot,
          spotId: event.spotId,
          needsElectricCharge: event.needsElectricCharge,
        ),
      );
      emit(state.copyWith(
        status: ReservationStatus.success,
        confirmationCode: confirmationCode,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReservationStatus.error,
        error: e.toString(),
      ));
    }
  }
}
