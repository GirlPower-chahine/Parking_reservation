part of 'reservation_bloc.dart';

enum ReservationStatus { initial, loading, success, error }

class ReservationState {
  final ReservationStatus status;
  final String? error;
  final String? confirmationCode;

  const ReservationState({
    this.status = ReservationStatus.initial,
    this.error,
    this.confirmationCode,
  });

  ReservationState copyWith({
    ReservationStatus? status,
    String? error,
    String? confirmationCode,
  }) {
    return ReservationState(
      status: status ?? this.status,
      error: error ?? this.error,
      confirmationCode: confirmationCode ?? this.confirmationCode,
    );
  }
}