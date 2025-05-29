package org.example.backend.service;

import org.example.backend.dto.UpdateUserDTO;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public Optional<User> getUserById(UUID id) {
        return userRepository.findById(id);
    }

    @Transactional
    public void deleteUser(UUID id) {
        userRepository.deleteById(id);
    }

    @Transactional
    public Optional<User> updateUser(UUID id, UpdateUserDTO dto) {
        return userRepository.findById(id)
                .map(user -> {
                    if (dto.getFirstName() != null) user.setFirstName(dto.getFirstName());
                    if (dto.getUsername() != null) {
                        User existingUser = userRepository.findByUsername(dto.getUsername());
                        if (existingUser == null || existingUser.getUserId().equals(id)) {
                            user.setUsername(dto.getUsername());
                        } else {
                            throw new RuntimeException("Cet username est déjà utilisé");
                        }
                    }
                    return userRepository.save(user);
                });
    }
    public List<User> getUsersByRole(String role) {
        return userRepository.findAll()
                .stream()
                .filter(user -> role.equals(user.getRole()))
                .collect(Collectors.toList());
    }
}