part of 'reservation_history_bloc.dart';

enum ReservationHistoryStatus { initial, loading, success, error }

class ReservationHistoryState {
  final ReservationHistoryStatus status;
  final List<ReservationHistoryDTO> reservations;
  final List<ReservationHistoryDTO> filteredReservations;
  final String? error;
  final String? currentFilter;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String? searchTerm;

  const ReservationHistoryState({
    this.status = ReservationHistoryStatus.initial,
    this.reservations = const [],
    this.filteredReservations = const [],
    this.error,
    this.currentFilter,
    this.filterStartDate,
    this.filterEndDate,
    this.searchTerm,
  });

  ReservationHistoryState copyWith({
    ReservationHistoryStatus? status,
    List<ReservationHistoryDTO>? reservations,
    List<ReservationHistoryDTO>? filteredReservations,
    String? error,
    String? currentFilter,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? searchTerm,
  }) {
    return ReservationHistoryState(
      status: status ?? this.status,
      reservations: reservations ?? this.reservations,
      filteredReservations: filteredReservations ?? this.filteredReservations,
      error: error ?? this.error,
      currentFilter: currentFilter ?? this.currentFilter,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  // Getters pour les statistiques avec vrais statuts
  int get totalReservations => reservations.length;
  int get activeReservations => reservations.where((r) => r.status.toUpperCase() == 'ACTIVE').length;
  int get completedReservations => reservations.where((r) => r.status.toUpperCase() == 'COMPLETED').length;
  int get cancelledReservations => reservations.where((r) =>
  r.status.toUpperCase() == 'CANCELLED_BY_USER' ||
      r.status.toUpperCase() == 'CANCELLED' ||
      r.status.toUpperCase() == 'CANCELLED_AUTO'
  ).length;
  int get checkedInReservations => reservations.where((r) => r.status.toUpperCase() == 'CHECKED_IN').length;
  int get expiredReservations => reservations.where((r) => r.status.toUpperCase() == 'EXPIRED').length;
}