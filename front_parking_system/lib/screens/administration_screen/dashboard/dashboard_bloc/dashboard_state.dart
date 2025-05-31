part of 'dashboard_bloc.dart';


enum DashboardStatus { initial, loading, success, error }

class DashboardState {
  final DashboardStatus status;
  final DashboardSummaryDTO? summary;
  final MonthlyAnalyticsDTO? monthlyAnalytics;
  final List<HistoricalAnalyticsDTO> historicalData;
  final ParkingSpotAnalyticsDTO? selectedSpotAnalytics;
  final String? selectedSpotId;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final String? error;
  final bool isExporting;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.summary,
    this.monthlyAnalytics,
    this.historicalData = const [],
    this.selectedSpotAnalytics,
    this.selectedSpotId,
    this.selectedStartDate,
    this.selectedEndDate,
    this.error,
    this.isExporting = false,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummaryDTO? summary,
    MonthlyAnalyticsDTO? monthlyAnalytics,
    List<HistoricalAnalyticsDTO>? historicalData,
    ParkingSpotAnalyticsDTO? selectedSpotAnalytics,
    String? selectedSpotId,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    String? error,
    bool? isExporting,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      monthlyAnalytics: monthlyAnalytics ?? this.monthlyAnalytics,
      historicalData: historicalData ?? this.historicalData,
      selectedSpotAnalytics: selectedSpotAnalytics ?? this.selectedSpotAnalytics,
      selectedSpotId: selectedSpotId ?? this.selectedSpotId,
      selectedStartDate: selectedStartDate ?? this.selectedStartDate,
      selectedEndDate: selectedEndDate ?? this.selectedEndDate,
      error: error ?? this.error,
      isExporting: isExporting ?? this.isExporting,
    );
  }

  // Getters pour les calculs dérivés
  double get occupancyRatePercentage =>
      summary != null && summary!.totalReservations > 0
          ? (summary!.checkedInReservations / summary!.totalReservations * 100)
          : 0.0;

  int get totalDailyReservations =>
      monthlyAnalytics?.dailyStats.values.fold(0, (sum, value) => sum! + value.toInt()) ?? 0;

  String get mostUsedDay =>
      summary?.usageByDayOfWeek.entries
          .reduce((a, b) => a.value > b.value ? a : b).key ?? 'N/A';
}
