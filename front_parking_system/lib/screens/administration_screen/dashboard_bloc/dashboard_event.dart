part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {}

class LoadDashboardSummary extends DashboardEvent {}

class LoadMonthlyAnalytics extends DashboardEvent {}

class LoadHistoricalAnalytics extends DashboardEvent {
  final String startDate;
  final String endDate;

  LoadHistoricalAnalytics({
    required this.startDate,
    required this.endDate,
  });
}

class LoadParkingSpotAnalytics extends DashboardEvent {
  final String spotId;
  final String startDate;
  final String endDate;

  LoadParkingSpotAnalytics({
    required this.spotId,
    required this.startDate,
    required this.endDate,
  });
}

class ExportMonthlyReport extends DashboardEvent {
  final String startDate;
  final String endDate;

  ExportMonthlyReport({
    required this.startDate,
    required this.endDate,
  });
}

class RefreshDashboard extends DashboardEvent {}

class SelectDateRange extends DashboardEvent {
  final DateTime startDate;
  final DateTime endDate;

  SelectDateRange({
    required this.startDate,
    required this.endDate,
  });
}
