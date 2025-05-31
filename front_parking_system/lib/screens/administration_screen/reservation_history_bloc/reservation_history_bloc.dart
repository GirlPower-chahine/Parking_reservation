import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/core/models/reservation/reservation_history_dto.dart';
import '../../../shared/core/services/repository/reservation_history_repository.dart';

part 'reservation_history_event.dart';
part 'reservation_history_state.dart';

class ReservationHistoryBloc extends Bloc<ReservationHistoryEvent, ReservationHistoryState> {
  final ReservationHistoryRepository repository;

  ReservationHistoryBloc({required this.repository})
      : super(const ReservationHistoryState()) {
    on<LoadAllReservationsHistory>(_onLoadAllReservationsHistory);
    on<LoadReservationsHistoryByStatus>(_onLoadReservationsHistoryByStatus);
    on<LoadLastMonthHistory>(_onLoadLastMonthHistory);
    on<LoadCancelledReservationsThisWeek>(_onLoadCancelledReservationsThisWeek);
    on<LoadCompletedReservationsToday>(_onLoadCompletedReservationsToday);
    on<LoadYearlyReservations>(_onLoadYearlyReservations);
    on<FilterReservationsByDate>(_onFilterReservationsByDate);
    on<FilterReservationsByStatus>(_onFilterReservationsByStatus);
    on<SearchReservations>(_onSearchReservations);
    on<ResetFilters>(_onResetFilters);
  }

  Future<void> _onLoadAllReservationsHistory(LoadAllReservationsHistory event,
      Emitter<ReservationHistoryState> emit,) async {
    emit(state.copyWith(status: ReservationHistoryStatus.loading));
    try {
      final reservations = await repository.getAllReservationsHistory(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(state.copyWith(
        status: ReservationHistoryStatus.success,
        reservations: reservations,
        filteredReservations: reservations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReservationHistoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadReservationsHistoryByStatus(
      LoadReservationsHistoryByStatus event,
      Emitter<ReservationHistoryState> emit,) async {
    emit(state.copyWith(status: ReservationHistoryStatus.loading));
    try {
      final reservations = await repository.getReservationsHistoryByStatus(
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
      );
      emit(state.copyWith(
        status: ReservationHistoryStatus.success,
        reservations: reservations,
        filteredReservations: reservations,
        currentFilter: event.status,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReservationHistoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadLastMonthHistory(LoadLastMonthHistory event,
      Emitter<ReservationHistoryState> emit,) async {
    emit(state.copyWith(status: ReservationHistoryStatus.loading));
    try {
      final reservations = await repository.getLastMonthHistory();
      emit(state.copyWith(
        status: ReservationHistoryStatus.success,
        reservations: reservations,
        filteredReservations: reservations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReservationHistoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadCancelledReservationsThisWeek(
      LoadCancelledReservationsThisWeek event,
      Emitter<ReservationHistoryState> emit,) async {
    emit(state.copyWith(status: ReservationHistoryStatus.loading));
    try {
      final reservations = await repository.getCancelledReservationsThisWeek();
      emit(state.copyWith(
        status: ReservationHistoryStatus.success,
        reservations: reservations,
        filteredReservations: reservations,
        currentFilter: 'CANCELLED_BY_USER',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReservationHistoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadCompletedReservationsToday(
      LoadCompletedReservationsToday event,
      Emitter<ReservationHistoryState> emit,) async {
    emit(state.copyWith(status: ReservationHistoryStatus.loading));
    try {
      final reservations = await repository.getCompletedReservationsToday();
      emit(state.copyWith(
        status: ReservationHistoryStatus.success,
        reservations: reservations,
        filteredReservations: reservations,
        currentFilter: 'COMPLETED',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReservationHistoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadYearlyReservations(LoadYearlyReservations event,
      Emitter<ReservationHistoryState> emit,) async {
    emit(state.copyWith(status: ReservationHistoryStatus.loading));
    try {
      final reservations = await repository.getYearlyReservations();
      emit(state.copyWith(
        status: ReservationHistoryStatus.success,
        reservations: reservations,
        filteredReservations: reservations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReservationHistoryStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _onFilterReservationsByDate(FilterReservationsByDate event,
      Emitter<ReservationHistoryState> emit,) {
    final filtered = state.reservations.where((reservation) {
      final reservationDate = DateTime.parse(reservation.reservationDate);
      return reservationDate.isAfter(
          event.startDate.subtract(const Duration(days: 1))) &&
          reservationDate.isBefore(event.endDate.add(const Duration(days: 1)));
    }).toList();

    emit(state.copyWith(
      filteredReservations: filtered,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
    ));
  }

  void _onFilterReservationsByStatus(FilterReservationsByStatus event,
      Emitter<ReservationHistoryState> emit,) {
    final filtered = state.reservations
        .where((reservation) => reservation.status == event.status)
        .toList();

    emit(state.copyWith(
      filteredReservations: filtered,
      currentFilter: event.status,
    ));
  }

  void _onSearchReservations(SearchReservations event,
      Emitter<ReservationHistoryState> emit,) {
    if (event.searchTerm.isEmpty) {
      emit(state.copyWith(
        filteredReservations: state.reservations,
        searchTerm: null,
      ));
      return;
    }

    final searchLower = event.searchTerm.toLowerCase();
    final filtered = state.reservations.where((reservation) {
      return reservation.userName.toLowerCase().contains(searchLower) ||
          reservation.spotId.toLowerCase().contains(searchLower) ||
          reservation.reservationId.toLowerCase().contains(searchLower);
    }).toList();

    emit(state.copyWith(
      filteredReservations: filtered,
      searchTerm: event.searchTerm,
    ));
  }

  void _onResetFilters(ResetFilters event,
      Emitter<ReservationHistoryState> emit,) {
    emit(state.copyWith(
      filteredReservations: state.reservations,
      currentFilter: null,
      filterStartDate: null,
      filterEndDate: null,
      searchTerm: null,
    ));
  }
}
