class HistoricalAnalyticsDTO {
  final String date;
  final int totalReservations;
  final double occupancyRate;
  final double noShowRate;

  const HistoricalAnalyticsDTO({
    required this.date,
    required this.totalReservations,
    required this.occupancyRate,
    required this.noShowRate,
  });

  factory HistoricalAnalyticsDTO.fromJson(Map<String, dynamic> json) {
    return HistoricalAnalyticsDTO(
      date: json['date'] as String,
      totalReservations: _parseToInt(json['totalReservations']),
      occupancyRate: _parseToDouble(json['occupancyRate']),
      noShowRate: _parseToDouble(json['noShowRate']),
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

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'totalReservations': totalReservations,
      'occupancyRate': occupancyRate,
      'noShowRate': noShowRate,
    };
  }

  @override
  String toString() {
    return 'HistoricalAnalyticsDTO(date: $date, totalReservations: $totalReservations, occupancyRate: $occupancyRate, noShowRate: $noShowRate)';
  }
}
