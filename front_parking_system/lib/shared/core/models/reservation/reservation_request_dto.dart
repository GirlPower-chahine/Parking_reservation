class ReservationRequestDTO {
  final String startDate;
  final String endDate;
  final String timeSlot;
  final String spotId;
  final bool needsElectricCharger;

  ReservationRequestDTO({
    required this.startDate,
    required this.endDate,
    required this.timeSlot,
    required this.spotId,
    required this.needsElectricCharger,
  });

  Map<String, dynamic> toJson() => {
    'startDate': startDate,
    'endDate': endDate,
    'timeSlot': timeSlot,
    'spotId': spotId,
    'needsElectricCharge': needsElectricCharger,
  };
}