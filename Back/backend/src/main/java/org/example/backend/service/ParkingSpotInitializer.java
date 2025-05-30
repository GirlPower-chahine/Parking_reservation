package org.example.backend.service;

import org.example.backend.entity.ParkingSpot;
import org.example.backend.entity.User;
import org.example.backend.repository.ParkingSpotRepository;
import org.example.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ParkingSpotInitializer implements CommandLineRunner {

    private final ParkingSpotRepository parkingSpotRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (parkingSpotRepository.count() == 0) {
            initializeParkingSpots();
        }

        if (userRepository.count() == 0) {
            initializeDefaultUsers();
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

    private void initializeDefaultUsers() {
        User employee = new User();
        employee.setUsername("employee@test.com");
        employee.setPassword(passwordEncoder.encode("password123"));
        employee.setFirstName("John");
        employee.setRole("EMPLOYEE");
        employee.setIsActive(true);
        userRepository.save(employee);

        User manager = new User();
        manager.setUsername("manager@test.com");
        manager.setPassword(passwordEncoder.encode("password123"));
        manager.setFirstName("Sarah");
        manager.setRole("MANAGER");
        manager.setIsActive(true);
        userRepository.save(manager);

        User secretary = new User();
        secretary.setUsername("secretary@test.com");
        secretary.setPassword(passwordEncoder.encode("password123"));
        secretary.setFirstName("Marie");
        secretary.setRole("SECRETARY");
        secretary.setIsActive(true);
        userRepository.save(secretary);
    }
}