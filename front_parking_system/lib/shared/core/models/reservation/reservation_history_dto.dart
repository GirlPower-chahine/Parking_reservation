class ReservationHistoryDTO {
  final String reservationId;
  final String spotId;
  final String reservationDate;
  final String timeSlot;
  final String status;
  final String? checkInTime;
  final String createdAt;
  final String userName;
  final String groupId;

  const ReservationHistoryDTO({
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

  factory ReservationHistoryDTO.fromJson(Map<String, dynamic> json) {
    return ReservationHistoryDTO(
      reservationId: json['reservationId'] as String,
      spotId: json['spotId'] as String,
      reservationDate: json['reservationDate'] as String,
      timeSlot: json['timeSlot'] as String,
      status: json['status'] as String,
      checkInTime: json['checkInTime'] as String?,
      createdAt: json['createdAt'] as String,
      userName: json['userName'] as String,
      groupId: json['groupId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservationId': reservationId,
      'spotId': spotId,
      'reservationDate': reservationDate,
      'timeSlot': timeSlot,
      'status': status,
      'checkInTime': checkInTime,
      'createdAt': createdAt,
      'userName': userName,
      'groupId': groupId,
    };
  }
}

