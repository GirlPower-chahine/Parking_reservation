import '../../models/parking/parking_spot.dart';
import '../../models/parking/parking_spot_dto.dart';
import '../../models/reservation/reservation_request_dto.dart';
import '../api/api_service.dart';

class ParkingRepository {
  final ApiService apiService;

  ParkingRepository(this.apiService);

  Future<List<ParkingSpot>> getParkingSpots() async {
    try {
      final response = await apiService.get('/parking/spots');
      if (response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => ParkingSpot.fromDTO(ParkingSpotDTO.fromJson(json)))
            .toList();
      } else {
        throw Exception('Unexpected response format: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createReservation(ReservationRequestDTO request) async {
    try {
      final response = await apiService.post('/reservations', request.toJson());
      if (response.statusCode == 201) {
        return 'Réservation créée avec succès';
      } else {
        throw Exception('Échec de la création de la réservation');
      }
    } catch (e) {
      rethrow;
    }
  }
}