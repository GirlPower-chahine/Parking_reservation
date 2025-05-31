class DashboardSummaryDTO {
  final int checkedInReservations;
  final int totalReservations;
  final Map<String, int> usageByDayOfWeek;
  final int noShows;

  const DashboardSummaryDTO({
    required this.checkedInReservations,
    required this.totalReservations,
    required this.usageByDayOfWeek,
    required this.noShows,
  });

  factory DashboardSummaryDTO.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryDTO(
      checkedInReservations: _parseToInt(json['checkedInReservations']),
      totalReservations: _parseToInt(json['totalReservations']),
      usageByDayOfWeek: _parseUsageByDayOfWeek(json['usageByDayOfWeek']),
      noShows: _parseToInt(json['noShows']),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Map<String, int> _parseUsageByDayOfWeek(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, int>.from(
          value.map((key, val) => MapEntry(key.toString(), _parseToInt(val)))
      );
    }
    return {};
  }

  Map<String, dynamic> toJson() {
    return {
      'checkedInReservations': checkedInReservations,
      'totalReservations': totalReservations,
      'usageByDayOfWeek': usageByDayOfWeek,
      'noShows': noShows,
    };
  }
}