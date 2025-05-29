package org.example.backend.service;

import org.example.backend.configuration.JwtUtils;
import org.example.backend.dto.AuthDTO;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final AuthenticationManager authenticationManager;

    public boolean isUsernameAvailable(String username) {
        return userRepository.findByUsername(username) == null;
    }

    @Transactional
    public User registerUser(AuthDTO authDTO) throws Exception {
        String role = authDTO.getRole().toUpperCase();
        if (!role.equals("EMPLOYEE") && !role.equals("SECRETARY") && !role.equals("MANAGER")) {
            throw new IllegalArgumentException("Role must be 'EMPLOYEE', 'SECRETARY', or 'MANAGER'");
        }

        User user = new User();
        user.setUsername(authDTO.getUsername());
        user.setPassword(passwordEncoder.encode(authDTO.getPassword()));
        user.setFirstName(authDTO.getUsername().split("@")[0]);
        user.setRole(role);

        return userRepository.save(user);
    }

    public Map<String, Object> authenticateUser(AuthDTO authDTO) throws AuthenticationException {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(authDTO.getUsername(), authDTO.getPassword())
        );

        if (authentication.isAuthenticated()) {
            User user = userRepository.findByUsername(authDTO.getUsername());

            Map<String, Object> authData = new HashMap<>();
            authData.put("token", jwtUtils.generateToken(authDTO.getUsername()));
            authData.put("type", "Bearer");
            authData.put("role", user.getRole());
            authData.put("userId", user.getUserId());

            return authData;
        }

        throw new AuthenticationException("Authentication failed") {};
    }
}
