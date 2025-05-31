class ParkingSpotDTO {
  final String spotId;
  final String rowIdentifier;
  final int spotNumber;
  final bool hasElectricCharger;
  final bool isAvailable;
  final int version;

  ParkingSpotDTO({
    required this.spotId,
    required this.rowIdentifier,
    required this.spotNumber,
    required this.hasElectricCharger,
    required this.isAvailable,
    required this.version,
  });

  factory ParkingSpotDTO.fromJson(Map<String, dynamic> json) {
    return ParkingSpotDTO(
      spotId: json['spotId'],
      rowIdentifier: json['rowIdentifier'],
      spotNumber: json['spotNumber'],
      hasElectricCharger: json['hasElectricCharger'],
      isAvailable: json['isAvailable'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotId': spotId,
      'rowIdentifier': rowIdentifier,
      'spotNumber': spotNumber,
      'hasElectricCharger': hasElectricCharger,
      'isAvailable': isAvailable,
      'version': version,
    };
  }
}