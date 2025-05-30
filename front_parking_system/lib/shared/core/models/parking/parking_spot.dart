import 'package:parking_system/shared/core/models/parking/parking_spot_dto.dart';

class ParkingSpot {
  final String spotId;
  final String rowIdentifier;
  final int spotNumber;
  final bool hasElectricCharger;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingSpot({
    required this.spotId,
    required this.rowIdentifier,
    required this.spotNumber,
    required this.hasElectricCharger,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParkingSpot.fromDTO(ParkingSpotDTO dto) {
    return ParkingSpot(
      spotId: dto.spotId,
      rowIdentifier: dto.rowIdentifier,
      spotNumber: dto.spotNumber,
      hasElectricCharger: dto.hasElectricCharger,
      isAvailable: dto.isAvailable,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }
}