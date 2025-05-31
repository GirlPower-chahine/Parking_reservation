class MonthlyAnalyticsDTO {
  final double averageOccupancyRate;
  final double noShowRate;
  final double electricChargerUsageRate;
  final Map<String, double> dailyStats;
  final int totalReservationsThisMonth;
  final int activeReservationsToday;

  const MonthlyAnalyticsDTO({
    required this.averageOccupancyRate,
    required this.noShowRate,
    required this.electricChargerUsageRate,
    required this.dailyStats,
    required this.totalReservationsThisMonth,
    required this.activeReservationsToday,
  });

  // Factory pour créer depuis les données summary en attendant la vraie API monthly
  factory MonthlyAnalyticsDTO.fromSummaryData(Map<String, dynamic> summaryJson) {
    print('🔄 [DTO] Création monthly depuis summary data');

    final occupancyRate = _parseToDouble(summaryJson['currentOccupancyRate']);
    final noShowRate = _parseToDouble(summaryJson['todayNoShowRate']);
    final occupiedSpots = _parseToInt(summaryJson['occupiedSpots']);
    final totalSpots = _parseToInt(summaryJson['totalSpots']);

    // Calcul des réservations approximatives
    final currentReservations = (totalSpots * occupancyRate / 100).round();

    print('🎯 [DTO] Monthly calculé: occupancy=$occupancyRate%, noShow=$noShowRate%, active=$occupiedSpots');

    return MonthlyAnalyticsDTO(
      averageOccupancyRate: occupancyRate,
      noShowRate: noShowRate,
      electricChargerUsageRate: 0.0, // Pas de données pour ça dans votre API
      dailyStats: {}, // Vide pour l'instant
      totalReservationsThisMonth: currentReservations,
      activeReservationsToday: occupiedSpots,
    );
  }

  factory MonthlyAnalyticsDTO.fromJson(Map<String, dynamic> json) {
    return MonthlyAnalyticsDTO(
      averageOccupancyRate: _parseToDouble(json['averageOccupancyRate']),
      noShowRate: _parseToDouble(json['noShowRate']),
      electricChargerUsageRate: _parseToDouble(json['electricChargerUsageRate']),
      dailyStats: _parseDailyStats(json['dailyStats']),
      totalReservationsThisMonth: _parseToInt(json['totalReservationsThisMonth']),
      activeReservationsToday: _parseToInt(json['activeReservationsToday']),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Map<String, double> _parseDailyStats(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, double>.from(
          value.map((key, val) => MapEntry(key.toString(), _parseToDouble(val)))
      );
    }
    return {};
  }

  Map<String, dynamic> toJson() {
    return {
      'averageOccupancyRate': averageOccupancyRate,
      'noShowRate': noShowRate,
      'electricChargerUsageRate': electricChargerUsageRate,
      'dailyStats': dailyStats,
      'totalReservationsThisMonth': totalReservationsThisMonth,
      'activeReservationsToday': activeReservationsToday,
    };
  }
}
