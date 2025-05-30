package org.example.backend.controller;

import lombok.RequiredArgsConstructor;
import org.example.backend.dto.*;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import org.example.backend.service.AnalyticsService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;
    private final UserRepository userRepository;

    @GetMapping("/dashboard/summary")
    @PreAuthorize("hasAnyRole('MANAGER', 'SECRETARY')")
    public ResponseEntity<DashboardSummaryDTO> getDashboardSummary() {
        DashboardSummaryDTO summary = analyticsService.getDashboardSummary();
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/dashboard/monthly")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<AnalyticsDTO> getMonthlyAnalytics() {
        AnalyticsDTO analytics = analyticsService.getMonthlyAnalytics();
        return ResponseEntity.ok(analytics);
    }

    @GetMapping("/dashboard/historical")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<List<HistoricalDataPointDTO>> getHistoricalData(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        if (endDate.isBefore(startDate)) {
            return ResponseEntity.badRequest().build();
        }

        List<HistoricalDataPointDTO> data = analyticsService.getHistoricalData(startDate, endDate);
        return ResponseEntity.ok(data);
    }

    @GetMapping("/parking-spot/{spotId}")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<Map<String, Object>> getSpotAnalytics(
            @PathVariable String spotId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        Map<String, Object> analytics = analyticsService.getSpotUtilizationAnalytics(spotId, startDate, endDate);
        return ResponseEntity.ok(analytics);
    }

    @GetMapping("/export")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<Map<String, Object>> exportAnalytics(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        Map<String, Object> exportData = Map.of(
                "period", Map.of("start", startDate, "end", endDate),
                "monthlyStats", analyticsService.getMonthlyAnalytics(),
                "historicalData", analyticsService.getHistoricalData(startDate, endDate),
                "generatedAt", LocalDate.now()
        );

        return ResponseEntity.ok(exportData);
    }

    @GetMapping("/dashboard/completion-metrics")
    @PreAuthorize("hasRole('MANAGER')")
    public ResponseEntity<Map<String, Object>> getCompletionMetrics(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        Map<String, Object> metrics = analyticsService.getCompletionMetrics(startDate, endDate);
        return ResponseEntity.ok(metrics);
    }
}