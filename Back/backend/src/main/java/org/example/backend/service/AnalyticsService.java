package org.example.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.backend.dto.AnalyticsDTO;
import org.example.backend.dto.DashboardSummaryDTO;
import org.example.backend.dto.HistoricalDataPointDTO;
import org.example.backend.entity.Reservation;
import org.example.backend.entity.ReservationStatus;
import org.example.backend.repository.ReservationRepository;
import org.example.backend.repository.ParkingSpotRepository;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AnalyticsService {

    private final ReservationRepository reservationRepository;
    private final ParkingSpotRepository parkingSpotRepository;

    @Cacheable(value = "monthlyAnalytics", key = "#root.method.name")
    public AnalyticsDTO getMonthlyAnalytics() {
        LocalDate startOfMonth = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth());
        LocalDate endOfMonth = LocalDate.now().with(TemporalAdjusters.lastDayOfMonth());

        AnalyticsDTO analytics = new AnalyticsDTO();

        // Taux d'occupation moyen
        analytics.setAverageOccupancyRate(calculateAverageOccupancy(startOfMonth, endOfMonth));

        // Taux de no-show (réservations sans check-in)
        analytics.setNoShowRate(calculateNoShowRate(startOfMonth, endOfMonth));

        // Utilisation des bornes électriques
        analytics.setElectricChargerUsageRate(calculateElectricChargerUsage(startOfMonth, endOfMonth));

        // Statistiques par jour de la semaine
        analytics.setDailyStats(calculateDailyStats(startOfMonth, endOfMonth));

        // Statistiques additionnelles pour le dashboard
        analytics.setTotalReservationsThisMonth(
                reservationRepository.countReservationsInPeriod(startOfMonth, endOfMonth)
        );

        analytics.setActiveReservationsToday(
                reservationRepository.countReservationsByDate(LocalDate.now())
        );

        return analytics;
    }

    public DashboardSummaryDTO getDashboardSummary() {
        DashboardSummaryDTO summary = new DashboardSummaryDTO();
        LocalDate today = LocalDate.now();

        // Occupation actuelle
        Long totalSpots = parkingSpotRepository.count();
        Long occupiedMorning = reservationRepository.countReservationsByDate(today);
        summary.setCurrentOccupancyRate((double) occupiedMorning / totalSpots * 100);
        summary.setOccupiedSpots(occupiedMorning.intValue());
        summary.setTotalSpots(totalSpots.intValue());

        // Taux de no-show aujourd'hui
        summary.setTodayNoShowRate(calculateDailyNoShowRate(today));

        // Top 5 des places les plus utilisées ce mois
        summary.setTopUsedSpots(getTopUsedSpots(5));

        // Tendance hebdomadaire
        summary.setWeeklyTrend(calculateWeeklyTrend());

        // Prévisions basées sur les patterns historiques
        summary.setPredictedOccupancyTomorrow(predictOccupancy(today.plusDays(1)));

        return summary;
    }

    public List<HistoricalDataPointDTO> getHistoricalData(LocalDate startDate, LocalDate endDate) {
        List<HistoricalDataPointDTO> historicalData = new ArrayList<>();

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            if (date.getDayOfWeek() != DayOfWeek.SATURDAY && date.getDayOfWeek() != DayOfWeek.SUNDAY) {
                HistoricalDataPointDTO dataPoint = new HistoricalDataPointDTO();
                dataPoint.setDate(date);

                Long totalReservations = reservationRepository.countReservationsByDate(date);
                dataPoint.setTotalReservations(totalReservations);

                // Calculer le taux d'occupation pour cette date
                Long totalSpots = parkingSpotRepository.count();
                dataPoint.setOccupancyRate((double) totalReservations / (totalSpots * 2) * 100); // *2 pour matin/après-midi

                // Taux de no-show pour cette date
                dataPoint.setNoShowRate(calculateDailyNoShowRate(date));

                historicalData.add(dataPoint);
            }
        }

        return historicalData;
    }

    public Map<String, Object> getSpotUtilizationAnalytics(String spotId, LocalDate startDate, LocalDate endDate) {
        Map<String, Object> analytics = new HashMap<>();

        List<Reservation> spotReservations = reservationRepository.findAll().stream()
                .filter(r -> r.getParkingSpot().getSpotId().equals(spotId))
                .filter(r -> !r.getStartDateTime().toLocalDate().isBefore(startDate))
                .filter(r -> !r.getStartDateTime().toLocalDate().isAfter(endDate))
                .collect(Collectors.toList());

        analytics.put("totalReservations", spotReservations.size());
        analytics.put("checkedInReservations", spotReservations.stream()
                .filter(r -> r.getCheckInTime() != null).count());
        analytics.put("noShows", spotReservations.stream()
                .filter(r -> r.getStatus() == ReservationStatus.EXPIRED).count());

        // Pattern d'utilisation par jour de la semaine
        Map<DayOfWeek, Long> usageByDayOfWeek = spotReservations.stream()
                .collect(Collectors.groupingBy(
                        r -> r.getStartDateTime().getDayOfWeek(),
                        Collectors.counting()
                ));
        analytics.put("usageByDayOfWeek", usageByDayOfWeek);

        return analytics;
    }

    private Double calculateAverageOccupancy(LocalDate start, LocalDate end) {
        Long totalSpots = parkingSpotRepository.count();
        Long totalReservations = reservationRepository.countReservationsInPeriod(start, end);

        // Calculer le nombre de jours ouvrables
        long workingDays = start.datesUntil(end.plusDays(1))
                .filter(date -> date.getDayOfWeek() != DayOfWeek.SATURDAY
                        && date.getDayOfWeek() != DayOfWeek.SUNDAY)
                .count();

        Long totalPossibleSlots = totalSpots * 2 * workingDays; // 2 créneaux par jour

        return totalPossibleSlots > 0 ? (double) totalReservations / totalPossibleSlots * 100 : 0.0;
    }

    private Double calculateNoShowRate(LocalDate start, LocalDate end) {
        Long totalReservations = reservationRepository.countReservationsInPeriod(start, end);
        Long checkedInReservations = reservationRepository.countCheckedInReservationsInPeriod(start, end);

        return totalReservations > 0 ?
                (double) (totalReservations - checkedInReservations) / totalReservations * 100 : 0.0;
    }

    private Double calculateElectricChargerUsage(LocalDate start, LocalDate end) {
        Long electricSpots = parkingSpotRepository.countElectricSpots();
        Long electricReservations = reservationRepository.countElectricReservationsInPeriod(start, end);

        long workingDays = start.datesUntil(end.plusDays(1))
                .filter(date -> date.getDayOfWeek() != DayOfWeek.SATURDAY
                        && date.getDayOfWeek() != DayOfWeek.SUNDAY)
                .count();

        Long totalPossibleElectricSlots = electricSpots * 2 * workingDays;

        return totalPossibleElectricSlots > 0 ?
                (double) electricReservations / totalPossibleElectricSlots * 100 : 0.0;
    }

    private Map<String, Double> calculateDailyStats(LocalDate start, LocalDate end) {
        Map<String, Double> dailyStats = new HashMap<>();

        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
            if (date.getDayOfWeek() != DayOfWeek.SATURDAY && date.getDayOfWeek() != DayOfWeek.SUNDAY) {
                Long dayReservations = reservationRepository.countReservationsByDate(date);
                dailyStats.put(date.toString(), dayReservations.doubleValue());
            }
        }

        return dailyStats;
    }

    private Double calculateDailyNoShowRate(LocalDate date) {
        List<Reservation> dayReservations = reservationRepository.findAll().stream()
                .filter(r -> r.getStartDateTime().toLocalDate().equals(date))
                .collect(Collectors.toList());

        long total = dayReservations.size();
        long noShows = dayReservations.stream()
                .filter(r -> r.getStatus() == ReservationStatus.EXPIRED ||
                        (r.getStatus() == ReservationStatus.ACTIVE && r.getCheckInTime() == null))
                .count();

        return total > 0 ? (double) noShows / total * 100 : 0.0;
    }

    private List<Map<String, Object>> getTopUsedSpots(int limit) {
        LocalDate startOfMonth = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth());
        LocalDate endOfMonth = LocalDate.now().with(TemporalAdjusters.lastDayOfMonth());

        Map<String, Long> spotUsage = reservationRepository.findAll().stream()
                .filter(r -> !r.getStartDateTime().toLocalDate().isBefore(startOfMonth))
                .filter(r -> !r.getStartDateTime().toLocalDate().isAfter(endOfMonth))
                .collect(Collectors.groupingBy(
                        r -> r.getParkingSpot().getSpotId(),
                        Collectors.counting()
                ));

        return spotUsage.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(limit)
                .map(entry -> {
                    Map<String, Object> spot = new HashMap<>();
                    spot.put("spotId", entry.getKey());
                    spot.put("usageCount", entry.getValue());
                    return spot;
                })
                .collect(Collectors.toList());
    }

    private Map<String, Object> calculateWeeklyTrend() {
        Map<String, Object> trend = new HashMap<>();
        LocalDate today = LocalDate.now();

        // Cette semaine vs semaine dernière
        Long thisWeek = reservationRepository.countReservationsInPeriod(
                today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)),
                today
        );

        Long lastWeek = reservationRepository.countReservationsInPeriod(
                today.minusWeeks(1).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)),
                today.minusWeeks(1).with(TemporalAdjusters.nextOrSame(DayOfWeek.FRIDAY))
        );

        trend.put("thisWeek", thisWeek);
        trend.put("lastWeek", lastWeek);
        trend.put("changePercent", lastWeek > 0 ?
                ((double) thisWeek - lastWeek) / lastWeek * 100 : 0.0);

        return trend;
    }

    private Double predictOccupancy(LocalDate targetDate) {
        // Simple prédiction basée sur la moyenne des mêmes jours des 4 dernières semaines
        DayOfWeek targetDayOfWeek = targetDate.getDayOfWeek();

        List<Long> historicalData = new ArrayList<>();
        for (int i = 1; i <= 4; i++) {
            LocalDate historicalDate = targetDate.minusWeeks(i);
            historicalData.add(reservationRepository.countReservationsByDate(historicalDate));
        }

        double average = historicalData.stream()
                .mapToLong(Long::longValue)
                .average()
                .orElse(0.0);

        Long totalSpots = parkingSpotRepository.count();
        return (average / (totalSpots * 2)) * 100; // *2 pour matin/après-midi
    }

    public Map<String, Object> getCompletionMetrics(LocalDate startDate, LocalDate endDate) {
        Map<String, Object> metrics = new HashMap<>();

        // Total des réservations
        Long totalReservations = reservationRepository.countReservationsInPeriod(startDate, endDate);

        // Réservations complétées (check-in effectué ET créneau terminé)
        Long completedReservations = reservationRepository.countCompletedReservationsInPeriod(startDate, endDate);

        // Réservations avec check-in mais pas encore terminées
        Long checkedInReservations = reservationRepository.countCheckedInReservationsInPeriod(startDate, endDate);

        // Taux de complétion = réservations complètement terminées / total
        Double completionRate = totalReservations > 0 ?
                (double) completedReservations / totalReservations * 100 : 0.0;

        metrics.put("totalReservations", totalReservations);
        metrics.put("completedReservations", completedReservations);
        metrics.put("checkedInReservations", checkedInReservations);
        metrics.put("completionRate", completionRate);

        // Temps moyen entre check-in et completion
        metrics.put("averageUsageDuration", calculateAverageUsageDuration(startDate, endDate));

        return metrics;
    }

    private Double calculateAverageUsageDuration(LocalDate startDate, LocalDate endDate) {
        List<Reservation> completedReservations = reservationRepository.findAll().stream()
                .filter(r -> r.getStatus() == ReservationStatus.COMPLETED)
                .filter(r -> !r.getStartDateTime().toLocalDate().isBefore(startDate))
                .filter(r -> !r.getStartDateTime().toLocalDate().isAfter(endDate))
                .filter(r -> r.getCheckInTime() != null)
                .collect(Collectors.toList());

        if (completedReservations.isEmpty()) {
            return 0.0;
        }

        double totalMinutes = completedReservations.stream()
                .mapToDouble(r -> {
                    LocalDateTime checkIn = r.getCheckInTime();
                    LocalDateTime end = r.getEndDateTime();
                    return java.time.Duration.between(checkIn, end).toMinutes();
                })
                .sum();

        return totalMinutes / completedReservations.size();
    }

}