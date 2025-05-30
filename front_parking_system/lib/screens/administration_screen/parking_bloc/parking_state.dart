part of 'parking_bloc.dart';

enum ParkingStatus { initial, loading, success, error }

@immutable
class ParkingState {
  final List<ParkingSpotDTO> parkingSpots;
  final ParkingStatus status;
  final String? error;

  const ParkingState({
    this.parkingSpots = const [],
    this.status = ParkingStatus.initial,
    this.error,
  });

  ParkingState copyWith({
    List<ParkingSpotDTO>? parkingSpots,
    ParkingStatus? status,
    String? error,
  }) {
    return ParkingState(
      parkingSpots: parkingSpots ?? this.parkingSpots,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}