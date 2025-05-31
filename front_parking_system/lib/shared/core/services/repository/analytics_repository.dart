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
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final summary = DashboardSummaryDTO.fromJson(response.data as Map<String, dynamic>);
        return summary;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return _getDefaultSummary();
      }
      return _getDefaultSummary();
    } catch (e) {
      return _getDefaultSummary();
    }
  }

  Future<MonthlyAnalyticsDTO> getMonthlyAnalytics() async {
    try {
      final response = await _apiService.dio.get(
        '/analytics/dashboard/monthly',
        options: Options(
          validateStatus: (status) => status != null && status >= 200 && status < 300,
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        return MonthlyAnalyticsDTO.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.response?.statusCode == 404) {
      } else {
        print('⚠️ [REPO] Erreur API Monthly: ${e.message}');
      }
    }

    try {
      final summaryResponse = await _apiService.dio.get(
        '/analytics/dashboard/summary',
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final monthly = MonthlyAnalyticsDTO.fromSummaryData(summaryResponse.data as Map<String, dynamic>);
      return monthly;
    } catch (e) {
      return _getDefaultMonthly();
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
          receiveTimeout: const Duration(seconds: 20), // Plus long pour historical
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> historicalList;

        if (data is Map<String, dynamic> && data.containsKey('historicalData')) {
          historicalList = data['historicalData'] as List<dynamic>;
        } else if (data is List) {
          historicalList = data;
        } else {
          throw Exception('Format de réponse invalide');
        }

        final result = historicalList
            .map((item) => HistoricalAnalyticsDTO.fromJson(item as Map<String, dynamic>))
            .toList();
        return result;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return [];
      }
      return [];
    } catch (e) {
      return [];
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
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final spotAnalytics = ParkingSpotAnalyticsDTO.fromJson(response.data as Map<String, dynamic>);
        return spotAnalytics;
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return _getDefaultSpotAnalytics(spotId);
      }
      return _getDefaultSpotAnalytics(spotId);
    } catch (e) {
      return _getDefaultSpotAnalytics(spotId);
    }
  }

  Future<List<HistoricalAnalyticsDTO>> getLast6MonthsAnalytics() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);
    final startDate = '${sixMonthsAgo.year}-${sixMonthsAgo.month.toString().padLeft(2, '0')}-01';
    final endDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return getHistoricalAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  DashboardSummaryDTO _getDefaultSummary() {
    return const DashboardSummaryDTO(
      checkedInReservations: 0,
      totalReservations: 60,
      usageByDayOfWeek: {
        'MONDAY': 0,
        'TUESDAY': 0,
        'WEDNESDAY': 0,
        'THURSDAY': 0,
        'FRIDAY': 0,
        'SATURDAY': 0,
        'SUNDAY': 0,
      },
      noShows: 0,
    );
  }

  MonthlyAnalyticsDTO _getDefaultMonthly() {
    return const MonthlyAnalyticsDTO(
      averageOccupancyRate: 0.0,
      noShowRate: 0.0,
      electricChargerUsageRate: 0.0,
      dailyStats: {},
      totalReservationsThisMonth: 0,
      activeReservationsToday: 0,
    );
  }

  ParkingSpotAnalyticsDTO _getDefaultSpotAnalytics(String spotId) {
    return const ParkingSpotAnalyticsDTO(
      checkedInReservations: 0,
      totalReservations: 0,
      usageByDayOfWeek: {},
      noShows: 0,
    );
  }

  Future<bool> testConnection() async {
    try {
      final response = await _apiService.dio.get(
        '/analytics/dashboard/summary',
        options: Options(
          receiveTimeout: const Duration(seconds: 3),

        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}