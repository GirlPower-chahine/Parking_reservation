class DashboardSummaryDTO {
  final int checkedInReservations; // = occupiedSpots (places actuellement occupées)
  final int totalReservations;     // = totalSpots (total des places de parking)
  final Map<String, int> usageByDayOfWeek;
  final int noShows;

  const DashboardSummaryDTO({
    required this.checkedInReservations,
    required this.totalReservations,
    required this.usageByDayOfWeek,
    required this.noShows,
  });

  factory DashboardSummaryDTO.fromJson(Map<String, dynamic> json) {
    print('🔄 [DTO] Parsing summary avec les clés: ${json.keys.toList()}');

    // Mapping logique depuis votre API
    final occupiedSpots = _parseToInt(json['occupiedSpots']); // Places actuellement occupées
    final totalSpots = _parseToInt(json['totalSpots']);       // Total des places disponibles
    final noShowRate = _parseToDouble(json['todayNoShowRate']); // Taux de no-show aujourd'hui

    // Conversion du taux en nombre (approximatif)
    final estimatedNoShows = (noShowRate * totalSpots / 100).round();

    final usageByDay = _parseTopUsedSpots(json['topUsedSpots']);

    print('🎯 [DTO] Summary mappé logiquement:');
    print('   - Places occupées: $occupiedSpots');
    print('   - Total places: $totalSpots');
    print('   - No-shows estimés: $estimatedNoShows');

    return DashboardSummaryDTO(
      checkedInReservations: occupiedSpots,    // Places occupées maintenant
      totalReservations: totalSpots,           // Total des places parking
      usageByDayOfWeek: usageByDay,
      noShows: estimatedNoShows,
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

  static Map<String, int> _parseTopUsedSpots(dynamic value) {
    // Retourner une map vide car pas de données historiques d'usage
    return {
      'MONDAY': 0,
      'TUESDAY': 0,
      'WEDNESDAY': 0,
      'THURSDAY': 0,
      'FRIDAY': 0,
      'SATURDAY': 0,
      'SUNDAY': 0,
    };
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