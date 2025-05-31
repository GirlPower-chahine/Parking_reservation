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
        '/api/reservations/history',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => ReservationHistoryDTO.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }


  Future<List<ReservationHistoryDTO>> getReservationsHistoryByStatus({
    required String startDate,
    required String endDate,
    required String status,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/api/reservations/history',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => ReservationHistoryDTO.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique filtré');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }


  Future<List<ReservationHistoryDTO>> getLastMonthHistory() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);

    return getAllReservationsHistory(
      startDate: '${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}-${lastMonth.day.toString().padLeft(2, '0')}',
      endDate: '${endOfLastMonth.year}-${endOfLastMonth.month.toString().padLeft(2, '0')}-${endOfLastMonth.day.toString().padLeft(2, '0')}',
    );
  }


  Future<List<ReservationHistoryDTO>> getCancelledReservationsThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return getReservationsHistoryByStatus(
      startDate: '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}',
      endDate: '${endOfWeek.year}-${endOfWeek.month.toString().padLeft(2, '0')}-${endOfWeek.day.toString().padLeft(2, '0')}',
      status: 'CANCELLED_BY_USER',
    );
  }

  Future<List<ReservationHistoryDTO>> getCompletedReservationsToday() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return getReservationsHistoryByStatus(
      startDate: todayStr,
      endDate: todayStr,
      status: 'COMPLETED',
    );
  }

  Future<List<ReservationHistoryDTO>> getYearlyReservations() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    return getAllReservationsHistory(
      startDate: '${startOfYear.year}-01-01',
      endDate: '${endOfYear.year}-12-31',
    );
  }
}
