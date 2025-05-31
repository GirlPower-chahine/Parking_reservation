part of 'dashboard_bloc.dart';

abstract class DashboardEvent {
  const DashboardEvent();
}

class LoadDashboardData extends DashboardEvent {}

class LoadDashboardSummary extends DashboardEvent {}

class LoadMonthlyAnalytics extends DashboardEvent {}

class LoadHistoricalAnalytics extends DashboardEvent {
  final String startDate;
  final String endDate;

  const LoadHistoricalAnalytics({
    required this.startDate,
    required this.endDate,
  });
}

class LoadParkingSpotAnalytics extends DashboardEvent {
  final String spotId;
  final String startDate;
  final String endDate;

  const LoadParkingSpotAnalytics({
    required this.spotId,
    required this.startDate,
    required this.endDate,
  });
}

class RefreshDashboard extends DashboardEvent {}