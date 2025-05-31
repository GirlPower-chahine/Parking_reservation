part of 'reservation_list_bloc.dart';

enum ReservationListStatus { initial, loading, success, error }

class ReservationListState {
  final ReservationListStatus status;
  final List<ReservationDTO> reservations;
  final String? error;

  const ReservationListState({
    this.status = ReservationListStatus.initial,
    this.reservations = const [],
    this.error,
  });

  ReservationListState copyWith({
    ReservationListStatus? status,
    List<ReservationDTO>? reservations,
    String? error,
  }) {
    return ReservationListState(
      status: status ?? this.status,
      reservations: reservations ?? this.reservations,
      error: error ?? this.error,
    );
  }
}