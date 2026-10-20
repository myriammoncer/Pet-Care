package com.petcare.user.service;

import com.petcare.user.dto.AuthResponse;
import com.petcare.user.dto.LoginRequest;
import com.petcare.user.dto.SignupRequest;

/**
 * Cas d'usage d'authentification.
 */
public interface AuthService {

    AuthResponse signup(SignupRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse refresh(String refreshToken);
}
