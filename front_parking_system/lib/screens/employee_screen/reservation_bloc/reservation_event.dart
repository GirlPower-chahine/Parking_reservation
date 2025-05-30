part of 'reservation_bloc.dart';

abstract class ReservationEvent {}

class CreateReservation extends ReservationEvent {
  final String userId;
  final String date;
  final String timeSlot;
  final String spotId;
  final bool needsElectricCharge;

  CreateReservation({
    required this.userId,
    required this.date,
    required this.timeSlot,
    required this.spotId,
    required this.needsElectricCharge,
  });
}
