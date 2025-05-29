package org.example.backend.dto;

import lombok.Data;

@Data
public class AuthDTO {
    private String username;
    private String password;
    private String role; // SECRETARY ou MANAGER
}
