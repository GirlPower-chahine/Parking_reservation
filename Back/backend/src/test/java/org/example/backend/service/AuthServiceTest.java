package org.example.backend.service;

import org.example.backend.configuration.JwtUtils;
import org.example.backend.dto.AuthDTO;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Map;
import java.util.UUID; // ✅ IMPORT AJOUTÉ

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AuthServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private PasswordEncoder passwordEncoder;
    @Mock
    private AuthenticationManager authenticationManager;
    @Mock
    private JwtUtils jwtUtils;

    @InjectMocks
    private AuthService authService;

    private AuthDTO authDTO;
    private User testUser;

    @BeforeEach
    void setUp() {
        authDTO = new AuthDTO();
        authDTO.setUsername("testuser@test.com");
        authDTO.setPassword("password123");
        authDTO.setRole("EMPLOYEE"); // ✅ Rôle requis

        testUser = new User();
        testUser.setUserId(UUID.randomUUID());
        testUser.setUsername("testuser@test.com");
        testUser.setPassword("encodedPassword");
        testUser.setRole("EMPLOYEE");
        testUser.setFirstName("testuser");
    }

    @Test
    void isUsernameAvailable_shouldReturnTrue_whenUsernameDoesNotExist() {
        // GIVEN
        when(userRepository.findByUsername("testuser@test.com")).thenReturn(null);

        // WHEN
        boolean isAvailable = authService.isUsernameAvailable("testuser@test.com");

        // THEN
        assertTrue(isAvailable);
        verify(userRepository, times(1)).findByUsername("testuser@test.com");
    }

    @Test
    void isUsernameAvailable_shouldReturnFalse_whenUsernameExists() {
        // GIVEN
        when(userRepository.findByUsername("testuser@test.com")).thenReturn(testUser);

        // WHEN
        boolean isAvailable = authService.isUsernameAvailable("testuser@test.com");

        // THEN
        assertFalse(isAvailable);
        verify(userRepository, times(1)).findByUsername("testuser@test.com");
    }

    @Test
    void registerUser_shouldRegisterNewUserSuccessfully() throws Exception {
        // GIVEN
        when(passwordEncoder.encode(authDTO.getPassword())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // WHEN
        User registeredUser = authService.registerUser(authDTO);

        // THEN
        assertNotNull(registeredUser);
        assertEquals("testuser@test.com", registeredUser.getUsername());
        assertEquals("encodedPassword", registeredUser.getPassword());
        assertEquals("EMPLOYEE", registeredUser.getRole());
        verify(passwordEncoder, times(1)).encode(authDTO.getPassword());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void registerUser_shouldThrowException_whenInvalidRole() {
        // GIVEN
        authDTO.setRole("INVALID_ROLE");

        // WHEN & THEN
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            authService.registerUser(authDTO);
        });

        assertEquals("Role must be 'EMPLOYEE', 'SECRETARY', or 'MANAGER'", exception.getMessage());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void authenticateUser_shouldReturnTokenData_onSuccessfulAuthentication() throws AuthenticationException {
        // GIVEN
        Authentication authentication = mock(Authentication.class);
        when(authentication.isAuthenticated()).thenReturn(true);

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(authentication);
        when(jwtUtils.generateToken("testuser@test.com")).thenReturn("mocked_jwt_token");
        when(userRepository.findByUsername("testuser@test.com")).thenReturn(testUser);

        // WHEN
        // ✅ CORRIGÉ : authenticateUser retourne Map<String, Object>
        Map<String, Object> authData = authService.authenticateUser(authDTO);

        // THEN
        assertNotNull(authData);
        assertEquals("mocked_jwt_token", authData.get("token"));
        assertEquals("Bearer", authData.get("type"));
        assertEquals("EMPLOYEE", authData.get("role"));
        assertEquals(testUser.getUserId(), authData.get("userId"));

        verify(authenticationManager, times(1)).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(jwtUtils, times(1)).generateToken("testuser@test.com");
        verify(userRepository, times(1)).findByUsername("testuser@test.com");
    }

    @Test
    void authenticateUser_shouldThrowException_onFailedAuthentication() {
        // GIVEN
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenThrow(new BadCredentialsException("Invalid credentials"));

        // WHEN & THEN
        AuthenticationException exception = assertThrows(AuthenticationException.class, () -> {
            authService.authenticateUser(authDTO);
        });

        assertEquals("Invalid credentials", exception.getMessage());
        verify(authenticationManager, times(1)).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(jwtUtils, never()).generateToken(anyString());
    }
}