class ReservationRequestDTO {
  final String reservationDate;
  final String timeSlot;
  final String spotId;
  final bool needsElectricCharge;

  ReservationRequestDTO({
    required this.reservationDate,
    required this.timeSlot,
    required this.spotId,
    required this.needsElectricCharge,
  });

  Map<String, dynamic> toJson() => {
    'reservationDate': reservationDate,
    'timeSlot': timeSlot,
    'spotId': spotId,
    'needsElectricCharge': needsElectricCharge,
  };
}