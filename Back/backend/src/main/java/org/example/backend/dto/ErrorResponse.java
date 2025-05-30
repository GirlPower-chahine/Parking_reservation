package org.example.backend.dto;

import lombok.Data;
import lombok.AllArgsConstructor;

@Data
@AllArgsConstructor
public class ErrorResponse {
    private String message;
    private String code;
}