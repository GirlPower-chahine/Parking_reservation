class ReservationDTO {
  final String reservationId;
  final String spotId;
  final String reservationDate;
  final String timeSlot;
  final String status;
  final String? checkInTime;
  final String createdAt;
  final String userName;
  final String groupId;

  ReservationDTO({
    required this.reservationId,
    required this.spotId,
    required this.reservationDate,
    required this.timeSlot,
    required this.status,
    this.checkInTime,
    required this.createdAt,
    required this.userName,
    required this.groupId,
  });

  factory ReservationDTO.fromJson(Map<String, dynamic> json) {
    return ReservationDTO(
      reservationId: json['reservationId'],
      spotId: json['spotId'],
      reservationDate: json['reservationDate'],
      timeSlot: json['timeSlot'],
      status: json['status'],
      checkInTime: json['checkInTime'],
      createdAt: json['createdAt'],
      userName: json['userName'],
      groupId: json['groupId'],
    );
  }
}