import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/core/models/parking/parking_spot_dto.dart';
import '../../../shared/core/services/repository/parking_repository.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository repository;

  ParkingBloc({required this.repository}) : super(const ParkingState()) {
    on<LoadParkingSpots>(_onLoadParkingSpots);
  }

  Future<void> _onLoadParkingSpots(
      LoadParkingSpots event,
      Emitter<ParkingState> emit,
      ) async {
    emit(state.copyWith(status: ParkingStatus.loading));
    try {
      final spots = await repository.getParkingSpots();
      final spotsDTO = spots
          .map((spot) => ParkingSpotDTO(
        spotId: spot.spotId,
        rowIdentifier: spot.rowIdentifier,
        spotNumber: spot.spotNumber,
        hasElectricCharger: spot.hasElectricCharger,
        isAvailable: spot.isAvailable,
        version: spot.version,
      ))
          .toList();

      emit(state.copyWith(
        status: ParkingStatus.success,
        parkingSpots: spotsDTO,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ParkingStatus.error,
        error: e.toString(),
      ));
    }
  }
}