import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../../models/analytics/dashboard_summary_dto.dart';
import '../../models/analytics/monthly_analytics_dto.dart';
import '../../models/analytics/historical_analytics_dto.dart';
import '../../models/analytics/parking_spot_analytics_dto.dart';

class AnalyticsRepository {
  final ApiService _apiService;

  AnalyticsRepository(this._apiService);

  // Historique pour graphiques avec gestion d'erreur améliorée
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

      print('Historical Analytics URL: ${response.requestOptions.uri}');
      print('Historical Analytics Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          print('Historical data count: ${data.length}');

          // Conversion avec gestion d'erreurs pour chaque élément
          final List<HistoricalAnalyticsDTO> historicalList = [];

          for (int i = 0; i < data.length; i++) {
            try {
              final item = data[i];
              if (item is Map<String, dynamic>) {
                final historical = HistoricalAnalyticsDTO.fromJson(item);
                historicalList.add(historical);

                // Log pour debug des premiers éléments
                if (i < 3) {
                  print('Historical item $i: $historical');
                }
              } else {
                print('Invalid item at index $i: $item (${item.runtimeType})');
              }
            } catch (e) {
              print('Error parsing historical item at index $i: $e');
              print('Item data: ${data[i]}');
              // Continuer avec les autres éléments
            }
          }

          return historicalList;
        } else {
          print('Unexpected response type: ${data.runtimeType}');
          throw Exception('Format de réponse invalide pour l\'historique: attendu List, reçu ${data.runtimeType}');
        }
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException Historical Analytics:');
      print('URL: ${e.requestOptions.uri}');
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');

      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la récupération de l\'historique');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in getHistoricalAnalytics: $e');
      throw Exception('Erreur inattendue lors de la récupération de l\'historique: $e');
    }
  }

  // Autres méthodes avec conversions sécurisées aussi
  Future<DashboardSummaryDTO> getDashboardSummary() async {
    try {
      final response = await _apiService.dio.get(
        '/analytics/dashboard/summary',
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      print('Dashboard Summary URL: ${response.requestOptions.uri}');
      print('Dashboard Summary Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return DashboardSummaryDTO.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erreur lors de la récupération du résumé: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Erreur Dashboard Summary: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la récupération du résumé');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
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

      print('Monthly Analytics URL: ${response.requestOptions.uri}');
      print('Monthly Analytics Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return MonthlyAnalyticsDTO.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erreur lors de la récupération des analytics mensuelles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Erreur Monthly Analytics: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la récupération des analytics mensuelles');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
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

      print('Parking Spot Analytics URL: ${response.requestOptions.uri}');
      print('Parking Spot Analytics Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ParkingSpotAnalyticsDTO.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erreur lors de la récupération des analytics de place: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Erreur Parking Spot Analytics: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de la récupération des analytics de place');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
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

      print('Export Report URL: ${response.requestOptions.uri}');
      print('Export Report Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception('Erreur lors de l\'export: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Erreur Export: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur lors de l\'export');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    }
  }

  // Méthode utilitaire pour obtenir les 6 derniers mois
  Future<List<HistoricalAnalyticsDTO>> getLast6MonthsAnalytics() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);

    return getHistoricalAnalytics(
      startDate: '${sixMonthsAgo.year}-${sixMonthsAgo.month.toString().padLeft(2, '0')}-01',
      endDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    );
  }
}