part of 'reservation_bloc.dart';

enum ReservationStatus { initial, loading, success, error }

class ReservationState {
  final ReservationStatus status;
  final String? error;

  const ReservationState({
    this.status = ReservationStatus.initial,
    this.error,
  });

  ReservationState copyWith({
    ReservationStatus? status,
    String? error,
  }) {
    return ReservationState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}