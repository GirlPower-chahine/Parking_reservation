// analytics_repository.dart
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../../models/analytics/dashboard_summary_dto.dart';
import '../../models/analytics/monthly_analytics_dto.dart';
import '../../models/analytics/historical_analytics_dto.dart';
import '../../models/analytics/parking_spot_analytics_dto.dart';

class AnalyticsRepository {
  final ApiService _apiService;

  AnalyticsRepository(this._apiService);

  Future<DashboardSummaryDTO> getDashboardSummary() async {
    try {
      final response = await _apiService.dio.get(
        '/analytics/dashboard/summary',
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        return DashboardSummaryDTO.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erreur lors de la récupération du résumé: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la récupération du résumé');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<MonthlyAnalyticsDTO> getMonthlyAnalytics() async {
    try {
      final response = await _apiService.dio.get(
        '/analytics/dashboard/monthly',
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        return MonthlyAnalyticsDTO.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erreur lors de la récupération des analytics mensuelles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la récupération des analytics mensuelles');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<List<HistoricalAnalyticsDTO>> getHistoricalAnalytics({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/analytics/dashboard/historical',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Based on your API response, the data comes wrapped in a "historicalData" key
        List<dynamic> historicalList;
        if (data is Map<String, dynamic> && data.containsKey('historicalData')) {
          historicalList = data['historicalData'] as List<dynamic>;
        } else if (data is List) {
          historicalList = data;
        } else {
          throw Exception('Format de réponse invalide pour l\'historique');
        }

        return historicalList
            .map((item) => HistoricalAnalyticsDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la récupération de l\'historique');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue lors de la récupération de l\'historique: $e');
    }
  }

  Future<ParkingSpotAnalyticsDTO> getParkingSpotAnalytics({
    required String spotId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/analytics/parking-spot/$spotId',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        return ParkingSpotAnalyticsDTO.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erreur lors de la récupération des analytics de place: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la récupération des analytics de place');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<List<int>> exportMonthlyReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/analytics/export',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          receiveTimeout: const Duration(seconds: 30),
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception('Erreur lors de l\'export: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de l\'export');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<List<HistoricalAnalyticsDTO>> getLast6MonthsAnalytics() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);
    return getHistoricalAnalytics(
      startDate: '${sixMonthsAgo.year}-${sixMonthsAgo.month.toString().padLeft(2, '0')}-01',
      endDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    );
  }
}