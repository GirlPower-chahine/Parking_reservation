package org.example.backend.service;

import org.example.backend.dto.UpdateUserDTO;
import org.example.backend.entity.User;
import org.example.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    private User employeeUser;
    private User secretaryUser;
    private User managerUser;
    private UUID employeeId;

    @BeforeEach
    void setUp() {
        employeeId = UUID.randomUUID();

        // Employee user
        employeeUser = new User();
        employeeUser.setUserId(employeeId);
        employeeUser.setUsername("employee@test.com");
        employeeUser.setFirstName("John");
        employeeUser.setRole("EMPLOYEE");
        employeeUser.setIsActive(true);

        // Secretary user
        secretaryUser = new User();
        secretaryUser.setUserId(UUID.randomUUID());
        secretaryUser.setUsername("secretary@test.com");
        secretaryUser.setFirstName("Marie");
        secretaryUser.setRole("SECRETARY");
        secretaryUser.setIsActive(true);

        // Manager user
        managerUser = new User();
        managerUser.setUserId(UUID.randomUUID());
        managerUser.setUsername("manager@test.com");
        managerUser.setFirstName("Sarah");
        managerUser.setRole("MANAGER");
        managerUser.setIsActive(true);
    }

    @Test
    void getAllUsers_shouldReturnAllUsers() {
        // GIVEN
        when(userRepository.findAll()).thenReturn(Arrays.asList(employeeUser, secretaryUser, managerUser));

        // WHEN
        List<User> users = userService.getAllUsers();

        // THEN
        assertNotNull(users);
        assertEquals(3, users.size());
        assertTrue(users.contains(employeeUser));
        assertTrue(users.contains(secretaryUser));
        assertTrue(users.contains(managerUser));
        verify(userRepository, times(1)).findAll();
    }

    @Test
    void getUsersByRole_shouldReturnUsersWithGivenRole() {
        // GIVEN
        List<User> allUsers = Arrays.asList(employeeUser, secretaryUser, managerUser);
        when(userRepository.findAll()).thenReturn(allUsers);

        // WHEN
        List<User> employees = userService.getUsersByRole("EMPLOYEE");

        // THEN
        assertNotNull(employees);
        assertEquals(1, employees.size());
        assertTrue(employees.contains(employeeUser));
        assertFalse(employees.contains(secretaryUser));
        assertFalse(employees.contains(managerUser));
        verify(userRepository, times(1)).findAll();
    }

    @Test
    void getUsersByRole_shouldReturnEmptyList_whenNoUsersWithRole() {
        // GIVEN
        when(userRepository.findAll()).thenReturn(Arrays.asList(employeeUser, secretaryUser));

        // WHEN
        List<User> managers = userService.getUsersByRole("MANAGER");

        // THEN
        assertNotNull(managers);
        assertTrue(managers.isEmpty());
        verify(userRepository, times(1)).findAll();
    }

    @Test
    void getUsersByRole_shouldReturnMultipleUsers_whenMultipleUsersWithSameRole() {
        // GIVEN
        User anotherEmployee = new User();
        anotherEmployee.setUserId(UUID.randomUUID());
        anotherEmployee.setUsername("employee2@test.com");
        anotherEmployee.setFirstName("Jane");
        anotherEmployee.setRole("EMPLOYEE");
        anotherEmployee.setIsActive(true);

        when(userRepository.findAll()).thenReturn(Arrays.asList(employeeUser, anotherEmployee, secretaryUser));

        // WHEN
        List<User> employees = userService.getUsersByRole("EMPLOYEE");

        // THEN
        assertNotNull(employees);
        assertEquals(2, employees.size());
        assertTrue(employees.contains(employeeUser));
        assertTrue(employees.contains(anotherEmployee));
        assertFalse(employees.contains(secretaryUser));
    }

    @Test
    void getUserById_shouldReturnUser_whenUserExists() {
        // GIVEN
        when(userRepository.findById(employeeId)).thenReturn(Optional.of(employeeUser));

        // WHEN
        Optional<User> foundUser = userService.getUserById(employeeId);

        // THEN
        assertTrue(foundUser.isPresent());
        assertEquals(employeeUser, foundUser.get());
        assertEquals("employee@test.com", foundUser.get().getUsername());
        assertEquals("John", foundUser.get().getFirstName());
        assertEquals("EMPLOYEE", foundUser.get().getRole());
        verify(userRepository, times(1)).findById(employeeId);
    }

    @Test
    void getUserById_shouldReturnEmptyOptional_whenUserDoesNotExist() {
        // GIVEN
        UUID nonExistentId = UUID.randomUUID();
        when(userRepository.findById(nonExistentId)).thenReturn(Optional.empty());

        // WHEN
        Optional<User> foundUser = userService.getUserById(nonExistentId);

        // THEN
        assertFalse(foundUser.isPresent());
        verify(userRepository, times(1)).findById(nonExistentId);
    }

    @Test
    void deleteUser_shouldDeleteUser() {
        // GIVEN
        doNothing().when(userRepository).deleteById(employeeId);

        // WHEN
        userService.deleteUser(employeeId);

        // THEN
        verify(userRepository, times(1)).deleteById(employeeId);
    }

    @Test
    void updateUser_shouldUpdateUserSuccessfully() {
        // GIVEN
        UpdateUserDTO updateDTO = new UpdateUserDTO();
        updateDTO.setFirstName("UpdatedJohn");
        updateDTO.setUsername("updated.employee@test.com");

        when(userRepository.findById(employeeId)).thenReturn(Optional.of(employeeUser));
        when(userRepository.findByUsername("updated.employee@test.com")).thenReturn(null); // Username available
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User userToSave = invocation.getArgument(0);
            userToSave.setFirstName("UpdatedJohn");
            userToSave.setUsername("updated.employee@test.com");
            return userToSave;
        });

        // WHEN
        Optional<User> updatedUser = userService.updateUser(employeeId, updateDTO);

        // THEN
        assertTrue(updatedUser.isPresent());
        assertEquals("UpdatedJohn", updatedUser.get().getFirstName());
        assertEquals("updated.employee@test.com", updatedUser.get().getUsername());
        assertEquals("EMPLOYEE", updatedUser.get().getRole()); // Role unchanged

        verify(userRepository, times(1)).findById(employeeId);
        verify(userRepository, times(1)).findByUsername("updated.employee@test.com");
        verify(userRepository, times(1)).save(employeeUser);
    }

    @Test
    void updateUser_shouldReturnEmptyOptional_whenUserDoesNotExist() {
        // GIVEN
        UUID nonExistentId = UUID.randomUUID();
        UpdateUserDTO updateDTO = new UpdateUserDTO();
        updateDTO.setFirstName("UpdatedName");

        when(userRepository.findById(nonExistentId)).thenReturn(Optional.empty());

        // WHEN
        Optional<User> updatedUser = userService.updateUser(nonExistentId, updateDTO);

        // THEN
        assertFalse(updatedUser.isPresent());
        verify(userRepository, times(1)).findById(nonExistentId);
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void updateUser_shouldThrowException_whenUsernameAlreadyExists() {
        // GIVEN
        UpdateUserDTO updateDTO = new UpdateUserDTO();
        updateDTO.setFirstName("UpdatedJohn");
        updateDTO.setUsername("secretary@test.com"); // Username déjà pris par secretaryUser

        when(userRepository.findById(employeeId)).thenReturn(Optional.of(employeeUser));
        when(userRepository.findByUsername("secretary@test.com")).thenReturn(secretaryUser); // Username taken

        // WHEN & THEN
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.updateUser(employeeId, updateDTO);
        });

        assertEquals("Cet username est déjà utilisé", exception.getMessage());
        verify(userRepository, times(1)).findById(employeeId);
        verify(userRepository, times(1)).findByUsername("secretary@test.com");
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void updateUser_shouldAllowSameUsername_whenUpdatingOwnUsername() {
        // GIVEN
        UpdateUserDTO updateDTO = new UpdateUserDTO();
        updateDTO.setFirstName("UpdatedJohn");
        updateDTO.setUsername("employee@test.com"); // Same username as current

        when(userRepository.findById(employeeId)).thenReturn(Optional.of(employeeUser));
        when(userRepository.findByUsername("employee@test.com")).thenReturn(employeeUser); // Same user
        when(userRepository.save(any(User.class))).thenReturn(employeeUser);

        // WHEN
        Optional<User> updatedUser = userService.updateUser(employeeId, updateDTO);

        // THEN
        assertTrue(updatedUser.isPresent());
        assertEquals("UpdatedJohn", updatedUser.get().getFirstName());
        assertEquals("employee@test.com", updatedUser.get().getUsername());

        verify(userRepository, times(1)).findById(employeeId);
        verify(userRepository, times(1)).findByUsername("employee@test.com");
        verify(userRepository, times(1)).save(employeeUser);
    }

    @Test
    void updateUser_shouldUpdateOnlyFirstName_whenUsernameIsNull() {
        // GIVEN
        UpdateUserDTO updateDTO = new UpdateUserDTO();
        updateDTO.setFirstName("UpdatedJohn");
        updateDTO.setUsername(null); // Only update firstName

        when(userRepository.findById(employeeId)).thenReturn(Optional.of(employeeUser));
        when(userRepository.save(any(User.class))).thenReturn(employeeUser);

        // WHEN
        Optional<User> updatedUser = userService.updateUser(employeeId, updateDTO);

        // THEN
        assertTrue(updatedUser.isPresent());
        assertEquals("UpdatedJohn", updatedUser.get().getFirstName());
        assertEquals("employee@test.com", updatedUser.get().getUsername()); // Unchanged

        verify(userRepository, times(1)).findById(employeeId);
        verify(userRepository, never()).findByUsername(anyString()); // Should not check username
        verify(userRepository, times(1)).save(employeeUser);
    }

    @Test
    void updateUser_shouldUpdateOnlyUsername_whenFirstNameIsNull() {
        // GIVEN
        UpdateUserDTO updateDTO = new UpdateUserDTO();
        updateDTO.setFirstName(null); // Only update username
        updateDTO.setUsername("new.employee@test.com");

        when(userRepository.findById(employeeId)).thenReturn(Optional.of(employeeUser));
        when(userRepository.findByUsername("new.employee@test.com")).thenReturn(null); // Available
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User userToSave = invocation.getArgument(0);
            userToSave.setUsername("new.employee@test.com");
            return userToSave;
        });

        // WHEN
        Optional<User> updatedUser = userService.updateUser(employeeId, updateDTO);

        // THEN
        assertTrue(updatedUser.isPresent());
        assertEquals("John", updatedUser.get().getFirstName()); // Unchanged
        assertEquals("new.employee@test.com", updatedUser.get().getUsername());

        verify(userRepository, times(1)).findById(employeeId);
        verify(userRepository, times(1)).findByUsername("new.employee@test.com");
        verify(userRepository, times(1)).save(employeeUser);
    }
}