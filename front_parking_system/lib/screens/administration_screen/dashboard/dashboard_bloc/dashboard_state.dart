part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, success, error }

class DashboardState {
  final DashboardStatus status;
  final DashboardSummaryDTO? summary;
  final MonthlyAnalyticsDTO? monthlyAnalytics;
  final List<HistoricalAnalyticsDTO> historicalData;
  final ParkingSpotAnalyticsDTO? selectedSpotAnalytics;
  final String? selectedSpotId;
  final String? error;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary,
    this.monthlyAnalytics,
    this.historicalData = const [],
    this.selectedSpotAnalytics,
    this.selectedSpotId,
    this.error,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummaryDTO? summary,
    MonthlyAnalyticsDTO? monthlyAnalytics,
    List<HistoricalAnalyticsDTO>? historicalData,
    ParkingSpotAnalyticsDTO? selectedSpotAnalytics,
    String? selectedSpotId,
    String? error,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      monthlyAnalytics: monthlyAnalytics ?? this.monthlyAnalytics,
      historicalData: historicalData ?? this.historicalData,
      selectedSpotAnalytics: selectedSpotAnalytics ?? this.selectedSpotAnalytics,
      selectedSpotId: selectedSpotId ?? this.selectedSpotId,
      error: error ?? this.error,
    );
  }
}