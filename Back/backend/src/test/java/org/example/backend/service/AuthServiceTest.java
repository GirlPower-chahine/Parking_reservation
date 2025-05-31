package org.example.backend.service;

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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.example.backend.configuration.JwtUtils; // Assurez-vous d'importer JwtUtils

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
        authDTO.setUsername("testuser");
        authDTO.setPassword("password");
        // Le rôle ne doit PAS être défini pour l'enregistrement dans le DTO,
        // car il est attribué par défaut dans le service.

        testUser = new User();
        testUser.setUserId(UUID.randomUUID());
        testUser.setUsername("testuser");
        testUser.setPassword("encodedPassword");
        testUser.setRole("EMPLOYEE");
    }

    @Test
    void isUsernameAvailable_shouldReturnTrue_whenUsernameDoesNotExist() {
        when(userRepository.findByUsername("testuser")).thenReturn(null);
        assertTrue(authService.isUsernameAvailable("testuser"));
        verify(userRepository, times(1)).findByUsername("testuser");
    }

    @Test
    void isUsernameAvailable_shouldReturnFalse_whenUsernameExists() {
        when(userRepository.findByUsername("testuser")).thenReturn(testUser);
        assertFalse(authService.isUsernameAvailable("testuser"));
        verify(userRepository, times(1)).findByUsername("testuser");
    }

    @Test
    void registerUser_shouldRegisterNewUserSuccessfully() {
        when(userRepository.findByUsername(authDTO.getUsername())).thenReturn(null);
        when(passwordEncoder.encode(authDTO.getPassword())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        User registeredUser = authService.registerUser(authDTO);

        assertNotNull(registeredUser);
        assertEquals("testuser", registeredUser.getUsername());
        assertEquals("encodedPassword", registeredUser.getPassword());
        assertEquals("EMPLOYEE", registeredUser.getRole()); // Vérifie le rôle par défaut
        verify(userRepository, times(1)).findByUsername(authDTO.getUsername());
        verify(passwordEncoder, times(1)).encode(authDTO.getPassword());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void registerUser_shouldThrowException_whenUsernameAlreadyExists() {
        when(userRepository.findByUsername(authDTO.getUsername())).thenReturn(testUser);

        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            authService.registerUser(authDTO);
        });

        assertEquals("Username is already in use", exception.getMessage());
        verify(userRepository, times(1)).findByUsername(authDTO.getUsername());
        verify(passwordEncoder, never()).encode(anyString());
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void authenticateUser_shouldReturnToken_onSuccessfulAuthentication() {
        Authentication authentication = mock(Authentication.class);
        when(authentication.isAuthenticated()).thenReturn(true);
        when(authentication.getName()).thenReturn("testuser");

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(authentication);
        when(jwtUtils.generateToken("testuser")).thenReturn("mocked_jwt_token");
        when(userRepository.findByUsername("testuser")).thenReturn(testUser);

        String token = authService.authenticateUser(authDTO);

        assertNotNull(token);
        assertEquals("mocked_jwt_token", token);
        verify(authenticationManager, times(1)).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(jwtUtils, times(1)).generateToken("testuser");
    }

    @Test
    void authenticateUser_shouldThrowException_onFailedAuthentication() {
        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenThrow(new BadCredentialsException("Invalid credentials"));

        BadCredentialsException exception = assertThrows(BadCredentialsException.class, () -> {
            authService.authenticateUser(authDTO);
        });

        assertEquals("Invalid credentials", exception.getMessage());
        verify(authenticationManager, times(1)).authenticate(any(UsernamePasswordAuthenticationToken.class));
        verify(jwtUtils, never()).generateToken(anyString());
    }
}