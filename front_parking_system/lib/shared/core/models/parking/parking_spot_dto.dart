class ParkingSpotDTO {
  final String spotId;
  final String rowIdentifier;
  final int spotNumber;
  final bool hasElectricCharger;
  final bool isAvailable;
  final String createdAt;
  final String updatedAt;

  ParkingSpotDTO({
    required this.spotId,
    required this.rowIdentifier,
    required this.spotNumber,
    required this.hasElectricCharger,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParkingSpotDTO.fromJson(Map<String, dynamic> json) {
    return ParkingSpotDTO(
      spotId: json['spotId'],
      rowIdentifier: json['rowIdentifier'],
      spotNumber: json['spotNumber'],
      hasElectricCharger: json['hasElectricCharger'],
      isAvailable: json['isAvailable'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotId': spotId,
      'rowIdentifier': rowIdentifier,
      'spotNumber': spotNumber,
      'hasElectricCharger': hasElectricCharger,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}