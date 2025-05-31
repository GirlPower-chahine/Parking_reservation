import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../../models/reservation/reservation_history_dto.dart';

class ReservationHistoryRepository {
  final ApiService _apiService;

  ReservationHistoryRepository(this._apiService);

  Future<List<ReservationHistoryDTO>> getAllReservationsHistory({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/reservations/history',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      print('✅ Historique URL: ${response.requestOptions.uri}');
      print('✅ Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          print('📦 Données reçues: ${data.length} réservations');

          final List<ReservationHistoryDTO> reservations = [];

          for (int i = 0; i < data.length; i++) {
            try {
              if (data[i] is Map<String, dynamic>) {
                final reservation = ReservationHistoryDTO.fromJson(data[i]);
                reservations.add(reservation);

                if (i < 3) {
                  print('📋 Réservation $i: ${reservation.userName} - ${reservation.status}');
                }
              }
            } catch (e) {
              print('⚠️ Erreur parsing item $i: $e');
              print('📄 Data: ${data[i]}');
            }
          }

          return reservations;
        } else {
          throw Exception('Format de réponse invalide: attendu List, reçu ${data.runtimeType}');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erreur Historique:');
      print('🔗 URL: ${e.requestOptions.uri}');
      print('📊 Status: ${e.response?.statusCode}');
      print('📝 Response: ${e.response?.data}');

      if (e.response?.statusCode == 500) {
        final responseData = e.response?.data;
        if (responseData is Map && responseData.containsKey('message')) {
          throw Exception('Erreur serveur: ${responseData['message']}');
        } else {
          throw Exception('Erreur serveur interne (500). Vérifiez que l\'endpoint /api/reservations/history existe et fonctionne.');
        }
      } else if (e.response?.statusCode == 404) {
        throw Exception('Endpoint non trouvé (404). Vérifiez l\'URL: ${e.requestOptions.uri}');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    }
  }

  Future<List<ReservationHistoryDTO>> getReservationsHistoryByStatus({
    required String startDate,
    required String endDate,
    required String status,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/reservations/history',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
          'status': status,
        },
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .map((json) => ReservationHistoryDTO.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Format de réponse invalide');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du filtrage: $e');
    }
  }

  Future<List<ReservationHistoryDTO>> getActiveReservations() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return getReservationsHistoryByStatus(
      startDate: todayStr,
      endDate: todayStr,
      status: 'ACTIVE',
    );
  }

  Future<List<ReservationHistoryDTO>> getCompletedReservations() async {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    return getReservationsHistoryByStatus(
      startDate: '${monthAgo.year}-${monthAgo.month.toString().padLeft(2, '0')}-${monthAgo.day.toString().padLeft(2, '0')}',
      endDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      status: 'COMPLETED',
    );
  }

  Future<List<ReservationHistoryDTO>> getCancelledReservations() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return getReservationsHistoryByStatus(
      startDate: '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}',
      endDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      status: 'CANCELLED_BY_USER',
    );
  }

  Future<List<ReservationHistoryDTO>> getYearlyReservations() async {
    final now = DateTime.now();
    return getAllReservationsHistory(
      startDate: '${now.year}-01-01',
      endDate: '${now.year}-12-31',
    );
  }
}