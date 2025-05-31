part of 'reservation_history_bloc.dart';

abstract class ReservationHistoryEvent {}

class LoadAllReservationsHistory extends ReservationHistoryEvent {
  final String startDate;
  final String endDate;

  LoadAllReservationsHistory({
    required this.startDate,
    required this.endDate,
  });
}

class LoadReservationsHistoryByStatus extends ReservationHistoryEvent {
  final String startDate;
  final String endDate;
  final String status;

  LoadReservationsHistoryByStatus({
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}

class LoadLastMonthHistory extends ReservationHistoryEvent {}

class LoadCancelledReservationsThisWeek extends ReservationHistoryEvent {}

class LoadCompletedReservationsToday extends ReservationHistoryEvent {}

class LoadYearlyReservations extends ReservationHistoryEvent {}

class FilterReservationsByDate extends ReservationHistoryEvent {
  final DateTime startDate;
  final DateTime endDate;

  FilterReservationsByDate({
    required this.startDate,
    required this.endDate,
  });
}

class FilterReservationsByStatus extends ReservationHistoryEvent {
  final String status;

  FilterReservationsByStatus({required this.status});
}

class SearchReservations extends ReservationHistoryEvent {
  final String searchTerm;

  SearchReservations({required this.searchTerm});
}

class ResetFilters extends ReservationHistoryEvent {}
