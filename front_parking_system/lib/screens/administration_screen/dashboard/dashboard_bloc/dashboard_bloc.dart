import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/core/models/analytics/dashboard_summary_dto.dart';
import '../../../../shared/core/models/analytics/historical_analytics_dto.dart';
import '../../../../shared/core/models/analytics/monthly_analytics_dto.dart';
import '../../../../shared/core/models/analytics/parking_spot_analytics_dto.dart';
import '../../../../shared/core/services/repository/analytics_repository.dart';

part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final AnalyticsRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadDashboardSummary>(_onLoadDashboardSummary);
    on<LoadMonthlyAnalytics>(_onLoadMonthlyAnalytics);
    on<LoadHistoricalAnalytics>(_onLoadHistoricalAnalytics);
    on<LoadParkingSpotAnalytics>(_onLoadParkingSpotAnalytics);
    on<ExportMonthlyReport>(_onExportMonthlyReport);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<SelectDateRange>(_onSelectDateRange);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      // Charger toutes les données en parallèle
      final results = await Future.wait([
        repository.getDashboardSummary(),
        repository.getMonthlyAnalytics(),
        repository.getLast6MonthsAnalytics(),
      ]);

      emit(state.copyWith(
        status: DashboardStatus.success,
        summary: results[0] as DashboardSummaryDTO,
        monthlyAnalytics: results[1] as MonthlyAnalyticsDTO,
        historicalData: results[2] as List<HistoricalAnalyticsDTO>,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadDashboardSummary(
    LoadDashboardSummary event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final summary = await repository.getDashboardSummary();
      emit(state.copyWith(summary: summary));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMonthlyAnalytics(
    LoadMonthlyAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final analytics = await repository.getMonthlyAnalytics();
      emit(state.copyWith(monthlyAnalytics: analytics));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadHistoricalAnalytics(
    LoadHistoricalAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final historical = await repository.getHistoricalAnalytics(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(historicalData: historical));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadParkingSpotAnalytics(
    LoadParkingSpotAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final spotAnalytics = await repository.getParkingSpotAnalytics(
        spotId: event.spotId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(
        selectedSpotAnalytics: spotAnalytics,
        selectedSpotId: event.spotId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onExportMonthlyReport(
    ExportMonthlyReport event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isExporting: true));

    try {
      final reportBytes = await repository.exportMonthlyReport(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      // Ici, vous pourriez sauvegarder le fichier ou déclencher un téléchargement
      // Pour l'instant, on émet juste le succès
      emit(state.copyWith(isExporting: false));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.error,
        error: e.toString(),
        isExporting: false,
      ));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    add(LoadDashboardData());
  }

  void _onSelectDateRange(
    SelectDateRange event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(
      selectedStartDate: event.startDate,
      selectedEndDate: event.endDate,
    ));

    // Recharger les données historiques avec la nouvelle plage de dates
    add(LoadHistoricalAnalytics(
      startDate:
          '${event.startDate.year}-${event.startDate.month.toString().padLeft(2, '0')}-${event.startDate.day.toString().padLeft(2, '0')}',
      endDate:
          '${event.endDate.year}-${event.endDate.month.toString().padLeft(2, '0')}-${event.endDate.day.toString().padLeft(2, '0')}',
    ));
  }
}
