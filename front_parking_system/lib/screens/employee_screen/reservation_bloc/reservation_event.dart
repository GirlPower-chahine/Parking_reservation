part of 'reservation_bloc.dart';

abstract class ReservationEvent {}

class CreateReservation extends ReservationEvent {
  final String startDate;
  final String endDate;
  final String timeSlot;
  final String spotId;
  final bool needsElectricCharge;

  CreateReservation({
    required this.startDate,
    required this.endDate,
    required this.timeSlot,
    required this.spotId,
    required this.needsElectricCharge,
  });
}

class CancelReservation extends ReservationEvent {
  final String reservationId;

  CancelReservation(this.reservationId);
}
