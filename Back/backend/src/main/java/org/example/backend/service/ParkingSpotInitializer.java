package org.example.backend.service;

import org.example.backend.entity.ParkingSpot;
import org.example.backend.repository.ParkingSpotRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ParkingSpotInitializer implements CommandLineRunner {

    private final ParkingSpotRepository parkingSpotRepository;

    @Override
    public void run(String... args) throws Exception {
        if (parkingSpotRepository.count() == 0) {
            initializeParkingSpots();
        }
    }

    private void initializeParkingSpots() {
        String[] rows = {"A", "B", "C", "D", "E", "F"};

        for (String row : rows) {
            for (int number = 1; number <= 10; number++) {
                ParkingSpot spot = new ParkingSpot();
                spot.setSpotId(row + String.format("%02d", number));
                spot.setRowIdentifier(row);
                spot.setSpotNumber(number);
                spot.setHasElectricCharger(row.equals("A") || row.equals("F"));
                spot.setIsAvailable(true);

                parkingSpotRepository.save(spot);
            }
        }
    }
}