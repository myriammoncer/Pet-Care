package com.petcare.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/** Corps de POST /auth/forgot-password. */
public record ForgotPasswordRequest(
        @NotBlank @Email String email
) {}