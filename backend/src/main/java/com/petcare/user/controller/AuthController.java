package com.petcare.user.controller;

import com.petcare.common.dto.ApiResponse;
import com.petcare.user.dto.AuthResponse;
import com.petcare.user.dto.LoginRequest;
import com.petcare.user.dto.RefreshRequest;
import com.petcare.user.dto.SignupRequest;
import com.petcare.user.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Endpoints publics d'authentification (/auth).
 */
@RestController
@RequestMapping("/auth")
@Tag(name = "Auth", description = "Inscription, connexion et rafraîchissement de token")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/signup")
    @Operation(summary = "Inscription d'un propriétaire ou d'un vétérinaire")
    public ResponseEntity<ApiResponse<AuthResponse>> signup(@Valid @RequestBody SignupRequest request) {
        AuthResponse response = authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(response, "Account created"));
    }

    @PostMapping("/login")
    @Operation(summary = "Connexion — renvoie les jetons JWT")
    public ApiResponse<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Renouvelle l'access token à partir du refresh token")
    public ApiResponse<AuthResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        return ApiResponse.ok(authService.refresh(request.refreshToken()));
    }
}
