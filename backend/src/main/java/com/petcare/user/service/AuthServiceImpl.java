package com.petcare.user.service;

import com.petcare.common.exception.ConflictException;
import com.petcare.common.exception.ResourceNotFoundException;
import com.petcare.common.security.JwtService;
import com.petcare.user.domain.Role;
import com.petcare.user.domain.User;
import com.petcare.user.dto.AuthResponse;
import com.petcare.user.dto.LoginRequest;
import com.petcare.user.dto.SignupRequest;
import com.petcare.user.dto.UserResponse;
import com.petcare.user.repository.UserRepository;
import io.jsonwebtoken.Claims;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;

@Service
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Override
    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new ConflictException("Email already in use: " + request.email());
        }
        // Un utilisateur ne peut s'auto-attribuer que PET_OWNER ou VET.
        Role role = request.role() == Role.ADMIN ? Role.PET_OWNER : request.role();

        User user = User.builder()
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .firstName(request.firstName())
                .lastName(request.lastName())
                .phone(request.phone())
                .roles(Set.of(role))
                .enabled(true)
                .build();

        user = userRepository.save(user);
        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new BadCredentialsException("Invalid email or password"));

        if (!user.isEnabled()) {
            throw new BadCredentialsException("Account disabled");
        }
        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new BadCredentialsException("Invalid email or password");
        }
        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse refresh(String refreshToken) {
        if (!jwtService.isValid(refreshToken)) {
            throw new BadCredentialsException("Invalid or expired refresh token");
        }
        Claims claims = jwtService.parse(refreshToken);
        User user = userRepository.findById(claims.getSubject())
                .orElseThrow(() -> new ResourceNotFoundException("User", claims.getSubject()));
        return buildAuthResponse(user);
    }

    private AuthResponse buildAuthResponse(User user) {
        List<String> roleNames = user.getRoles().stream().map(Enum::name).toList();
        String access = jwtService.generateAccessToken(user.getId(), user.getEmail(), roleNames);
        String refresh = jwtService.generateRefreshToken(user.getId(), user.getEmail());
        return AuthResponse.of(access, refresh, UserResponse.from(user));
    }
}
